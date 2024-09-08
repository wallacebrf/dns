#!/bin/bash

#influxDB parameters
snmp_device_name="FG-91G"
measurement="fortigate_blocked_domains"
influxdb_host="localhost"
influxdb_port="8086"
influxdb_pass="your_password"
influxdb_name="db_name"
influxdb_http_type="http"
influxdb_org="home"

#Email parameters
email_address="email@email.com"
from_email_address="email@email.com"
notification_file_location="/volume1/web/logging/notifications"
enable_notifications=1

#*************************************************************
#*************************************************************
#SCIPT START
#*************************************************************
#*************************************************************


#########################################################
#this function pings google.com to confirm internet access is working prior to sending email notifications 
#########################################################
check_internet() {
ping -c1 "google.com" > /dev/null #ping google.com									
	local status=$?
	if ! (exit $status); then
		false
	else
		true
	fi
}
#########################################################
#this function is used to send notifications
#########################################################
function send_mail(){
#email_last_sent_log_file=${1}			this file contains the UNIX time stamp of when the email is sent so we can track how long ago an email was last sent
#message_text=${2}						this string of text contains the body of the email message
#email_subject=${3}						this string of text contains the email subject line
#email_contents_file=${4}				this file is where the contents of the email are saved prior to sending and it contains the log of the email transmission, either will indicated email sent successfully or will include the error details
#error_message=${5}						this string of text is only displayed when the script is executed from the CLI, it will be part of the error message if the email is not sent correctly
#email_interval=${6}					this numerical value will control how many minutes must pass before the next email is allowed to be sent
#use_mail_plus_server=${7}				this will control if mail plus server (IE sendmail) or ssmtp will be used to send emails. ssmtp is much slower to execute but does not require the installation of mail plus server
	if [[ $enable_notifications == 1 ]]; then
		local message_tracker=""
		local time_diff=0
		echo -e "${2}"
		echo ""
		if check_internet; then
			local current_time=$( date +%s )
			if [ -r "${1}" ]; then #file is available and readable 
				read message_tracker < "${1}"
				time_diff=$((( $current_time - $message_tracker ) / 60 ))
			else
				echo -n "$current_time" > "${1}"
				time_diff=$(( ${6} + 1 ))
			fi
					
			if [ $time_diff -ge ${6} ]; then
				local now=$(date +"%T")
				echo "the email has not been sent in over ${6} minutes, re-sending email"
				if [[ ${7} == 1 ]]; then #if this is a value of 1, use mail plus
					#verify MailPlus Server package is installed and running as the "sendmail" command is not installed in Synology by default. the MailPlus Server package is required
					local install_check=$(/usr/syno/bin/synopkg list | grep MailPlus-Server)
					if [ "$install_check" != "" ];then
						#"MailPlus Server is installed, verify it is running and not stopped"
						local status=$(/usr/syno/bin/synopkg is_onoff "MailPlus-Server")
						if [ "$status" = "package MailPlus-Server is turned on" ]; then
							echo "from: $from_email_address " > "${4}"
							echo "to: $email_address " >> "${4}"
							echo "subject: ${3}" >> "${4}"
							echo "" >> "${4}"
							echo -e "$now - ${2}" >> "${4}" #adding the mail-body text. 
							local email_response=$(sendmail -t < "${4}"  2>&1)
							if [[ "$email_response" == "" ]]; then
								echo "" |& tee -a "${4}"
								echo -e "Email to \"$email_address\" Sent Successfully\n" |& tee -a "${4}"
								message_tracker=$current_time
								time_diff=0
								echo -n "$message_tracker" > "${1}"
							else
								echo -e "Warning, an error occurred while sending the ${5} notification email. the error was: $email_response\n" |& tee -a "${4}"
							fi
						else
							echo -e "Warning Mail Plus Server is Installed but not running, unable to send email notification\n" |& tee -a "${4}"
						fi
					else
						echo -e "Mail Plus Server is not installed, unable to send email notification\n" |& tee -a "${4}"
					fi
				else #since the value is not equal to 1, use ssmtp command
					echo "From: $from_email_address " > "${4}"
					echo "Subject: ${3}" >> "${4}"
					echo "" >> "${4}"
					echo -e "\n$now - ${2}\n" >> "${4}" #adding the mail-body text. 
					
					#the "ssmtp" command can only take one email address destination at a time. so if there are more than one email addresses in the list, we need to send them one at a time
					address_explode=(`echo $email_address | sed 's/;/\n/g'`) #explode on the semicolon separating the different possible addresses
					local xx=0
					for xx in "${!address_explode[@]}"; do
						local email_response=$(ssmtp ${address_explode[$xx]} < "${4}"  2>&1)
						if [[ "$email_response" == "" ]]; then
							echo "" |& tee -a "${4}"
							echo -e "Email to \"${address_explode[$xx]}\" Sent Successfully\n" |& tee -a "${4}"
							message_tracker=$current_time
							time_diff=0
							echo -n "$message_tracker" > "${1}"
						else
							echo -e "Warning, an error occurred while sending the ${5} notification email. the error was: $email_response\n" |& tee -a "${4}"
						fi
					done
				fi
			else
				echo -e "Only $time_diff minuets have passed since the last notification, email will be sent every ${6} minutes. $(( ${6} - $time_diff )) Minutes Remaining Until Next Email\n"
			fi
		else
			echo -e "Internet is not available, skipping sending email\n" |& tee -a "${4}"
		fi
	else
		echo "Unable to send notifications, pleas enable notifications in the web-interface"
	fi
}

#########################################################
#script main
#########################################################

current_files=$(ls "/volume1/web/DNS_FG-91G" | grep 'web_block.*\.txt')

echo -e "Combining all downloaded files \"master1.txt master2.txt master3.txt master4.txt master5.txt master6.txt\" into file \"out.txt\"\n\n"

cat master1.txt master2.txt master3.txt master4.txt master5.txt master6.txt > out.txt
num_lines=$(wc -l out.txt)
num_lines=${num_lines::-8}
echo -e "Files combined. Current blocked URLs is $num_lines\n\n"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"
	exit 1
fi


echo -e "Clearing all comment lines starting with \"#\""
sed -i 's/#.*$//' out.txt #delete lines starting with # as those are comments
num_lines=$(wc -l out.txt)
num_lines=${num_lines::-8}
echo -e "Comments removed. Current blocked URLs is $num_lines\n\n"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"
	exit 1
fi

echo -e "Clearing all lines starting with \"!\""
sed -i 's/!.*$//' out.txt #delete lines starting with ! as those are comments
num_lines=$(wc -l out.txt)
num_lines=${num_lines::-8}
echo -e "lines starting with \"!\" removed. Current blocked URLs is $num_lines\n\n"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"
	exit 1
fi

echo -e "Clearing all lines starting with \"|\""
sed -i 's/|.*$//' out.txt #delete lines starting with | as those are comments
num_lines=$(wc -l out.txt)
num_lines=${num_lines::-8}
echo -e "lines starting with \"|\" removed. Current blocked URLs is $num_lines\n\n"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"
	exit 1
fi

echo -e "Deleting all Empty/Cleared Lines"
sed -i '/^\s*$/d' out.txt #delete empty lines
num_lines=$(wc -l out.txt)
num_lines=${num_lines::-8}
echo -e "Empty lines removed. Current blocked URLs is $num_lines\n\n"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"
	exit 1
fi

echo -e "Deleting all other instances of \"!\" \"|\" \"^\" \"?\" \"=\" and \" \" within the file as these are not allowable URL characters"
sed -i 's|[|!^?= ,]||g' out.txt
num_lines=$(wc -l out.txt)
num_lines=${num_lines::-8}
echo -e "Characters removed. Current blocked URLs is $num_lines\n\n"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"
	exit 1
fi

echo -e "Deleting all duplicate entries"
awk -i inplace '!seen[$0]++' out.txt # delete duplicates 
num_lines=$(wc -l out.txt)
num_lines=${num_lines::-8}
echo -e "Duplicate lines removed. Final Total blocked URLs is $num_lines\n\n"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"
	exit 1
fi


echo -e "splitting results into separate files containing no more than 131,000 entries\n\n"
lines=0
file_name_counter=0
echo -e "saving entries to web_block0.txt\n"
echo "" > "web_block0.txt" #reset the contents if old contents were there before
while read line; do
	echo "$line" >> "web_block$file_name_counter.txt"
	let lines=lines+1
	if [[ $lines -gt 131000 ]]; then
		let file_name_counter=file_name_counter+1
		echo -e "saving entries to web_block$file_name_counter.txt\n"
		file_check=$(echo "$current_files" | grep web_block$file_name_counter.txt)
		if [ "$file_check" == "" ];then
			echo -e "\nfile web_block$file_name_counter.txt is new!\n"
			send_mail "$notification_file_location/DNS_block_list_email_last_sent_tracker.txt" "File web_block$file_name_counter.txt is new!. Update the firewall settings to include this new file" "New web_block File Name Available" "$notification_file_location/DNS_blocklist_email_notification_file.txt" "" 0 1
		fi
		lines=0
		echo "" > "web_block$file_name_counter.txt" #reset the contents if old contents were there before
	fi
done < out.txt

#Post stats to influxdb
post_url="$measurement,snmp_device_name=$snmp_device_name num_lines=$num_lines"
					
curl -XPOST "$influxdb_http_type://$influxdb_host:$influxdb_port/api/v2/write?bucket=$influxdb_name&org=$influxdb_org" -H "Authorization: Token $influxdb_pass" --data-raw "$post_url"
				
