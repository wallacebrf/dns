#!/bin/bash
# shellcheck disable=SC2219,SC2035
#Version 4/11/2025
#By Brian Wallace

#ingest file parameters
Working_Dir="/volume1/web/DNS_FG-91G"

#influxDB parameters
snmp_device_name="FG-91G"
measurement="fortigate_blocked_domains"
influxdb_host="localhost"
influxdb_port="8086"
influxdb_pass="xxxxxx"
influxdb_name="db_name"
influxdb_http_type="http"
influxdb_org="my_org"

#*************************************************************
#*************************************************************
#SCIPT START
#*************************************************************
#*************************************************************

##########################################################################
#create a lock file and temp directory directory to prevent more than one instance of this script from executing  at once
##########################################################################
if ! mkdir "$Working_Dir/tmp"; then
	echo -e "Failed to acquire lock\n" >&2
	exit 1
fi
trap 'rm -rf $Working_Dir/tmp/' EXIT #remove the lockdir on exit


##########################################################################
#create logging directory if does not exist and creating log file
##########################################################################
if [[ -d "$Working_Dir/log/" ]]; then
	echo "Log directory \"$Working_Dir/log/\" exists"
else
	if ! mkdir "$Working_Dir/log"; then
		echo -e "Failed to create log directory \"$Working_Dir/log/\"\n" >&2
		exit 1
	else
		echo "Created Log directory \"$Working_Dir/log/\""
	fi
fi
date=$(date '+%Y-%m-%d')
echo "Log Date: $date" > "$Working_Dir/log/$date.txt"
if [[ ! -w "$Working_Dir/log/$date.txt" ]]; then
	echo -e "Failed to create log file \"$Working_Dir/log/$date.txt\"\n" >&2
	exit 1
fi

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
#script main
#########################################################

##########################################################################
#download all of the Pie Hole Block List text files 
##########################################################################
if [[ ! -r "$Working_Dir/web_block_source.txt" ]]; then
	echo -e "Unable to read required file \"$Working_Dir/web_block_source.txt\"\n" >&2
	exit 1
fi

echo -e "\n\n***************************************"  |& tee -a "$Working_Dir/log/$date.txt" 
echo "download all of the Pie Hole Block List text files"  |& tee -a "$Working_Dir/log/$date.txt"
echo -e "***************************************\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

counter=1
	
while read -r line; do
	let counter=counter+1
	wget -q -O "$counter.txt" "${line//[$'\t\r\n ']}"
	mv "$Working_Dir/$counter.txt" "$Working_Dir/tmp/$counter.txt"
	num_lines=$(wc -l < "$Working_Dir/tmp/$counter.txt")
	if [ "$num_lines" -eq 0 ]; then
		#echo "$num_lines Subnets Downloaded from ${line//[$'\t\r\n ']}"  |& tee -a "$Working_Dir/log/$date.txt"
	#else
		echo -e "\nWARNING - ${line//[$'\t\r\n ']} Returned Zero Results\n"  |& tee -a "$Working_Dir/log/$date.txt"
	fi
	
done < "$Working_Dir/web_block_source.txt"


##########################################################################
# Combine all text files
##########################################################################
echo -e "\n\n***************************************"  |& tee -a "$Working_Dir/log/$date.txt"
echo "Combining all text files"  |& tee -a "$Working_Dir/log/$date.txt"
echo -e "***************************************\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

cd "$Working_Dir/tmp/" || exit 1
cat *.txt > "$Working_Dir/master.txt"
num_lines=$(wc -l < "$Working_Dir/master.txt")

echo -e "Total Lines Of Data Downloaded: $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"
	exit 1
fi

counter=1
echo -e "Processing data to be compatable with Fortigate External Threat Feeds\n" |& tee -a "$Working_Dir/log/$date.txt"
echo -e "Removing the following items: \"127.0.0.1 \", \"localhost\", \"::1 \", \"0.0.0.0 \", \"0.0.0.0\", \"127.0.0.1	\", \".localdomain\", \"255.255.255.255	broadcasthost\", \"::1\" , \"|\" , \"^\"\n\n" |& tee -a "$Working_Dir/log/$date.txt"
sed -i -e 's/\(127.0.0.1 \|localhost\|::1 \|0.0.0.0 \|0.0.0.0\|.localdomain\|255.255.255.255	broadcasthost\|::1\)//g' "$Working_Dir/master.txt"
num_lines=$(wc -l < "$Working_Dir/master.txt")
echo -e "Data Removed - Current blocked URLs is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

echo -e "Clearing all comment lines starting with \"#\""  |& tee -a "$Working_Dir/log/$date.txt"
sed -i 's/#.*$//' "$Working_Dir/master.txt" #delete lines starting with # as those are comments
num_lines=$(wc -l < "$Working_Dir/master.txt")
echo -e "Data Removed - Current blocked URLs is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"  |& tee -a "$Working_Dir/log/$date.txt"
	exit 1
fi

echo -e "Deleting all Empty/Cleared Lines"  |& tee -a "$Working_Dir/log/$date.txt"
sed -i '/^\s*$/d' "$Working_Dir/master.txt" #delete empty lines
num_lines=$(wc -l < "$Working_Dir/master.txt")
echo -e "Data Removed - Current blocked URLs is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"  |& tee -a "$Working_Dir/log/$date.txt"
	exit 1
fi

echo -e "Deleting all other instances of \"!\" \"|\" \"^\" \"?\" \"=\" and \" \" within the file as these are not allowable URL characters"  |& tee -a "$Working_Dir/log/$date.txt"
sed -i 's|[|!^?= },]||g' "$Working_Dir/master.txt"
num_lines=$(wc -l < "$Working_Dir/master.txt")
echo -e "Data Removed - Current blocked URLs is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"  |& tee -a "$Working_Dir/log/$date.txt"
	exit 1
fi

echo -e "Deleting all duplicate entries"  |& tee -a "$Working_Dir/log/$date.txt"
awk -i inplace '!seen[$0]++' "$Working_Dir/master.txt" # delete duplicates 
num_lines=$(wc -l < "$Working_Dir/master.txt")
echo -e "Duplicate lines removed. Final Total blocked URLs is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"  |& tee -a "$Working_Dir/log/$date.txt"
	exit 1
fi


echo -e "splitting results into separate files containing no more than 131,000 entries\n\n"  |& tee -a "$Working_Dir/log/$date.txt"
lines=0
file_name_counter=0
echo -e "saving entries to $Working_Dir/web_block0.txt\n"  |& tee -a "$Working_Dir/log/$date.txt"
echo "" > "$Working_Dir/web_block0.txt" #reset the contents if old contents were there before
while read -r line; do
	echo "$line" >> "$Working_Dir/web_block$file_name_counter.txt"
	let lines=lines+1
	if [[ $lines -gt 131000 ]]; then
		let file_name_counter=file_name_counter+1
		echo -e "saving entries to $Working_Dir/web_block$file_name_counter.txt\n"  |& tee -a "$Working_Dir/log/$date.txt"
		lines=0
		echo "" > "$Working_Dir/web_block$file_name_counter.txt" #reset the contents if old contents were there before
	fi
done < "$Working_Dir/master.txt"

echo -e "Web Block Processing Complete. Final Total blocked URLs is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

#Post stats to influxdb
post_url="$measurement,snmp_device_name=$snmp_device_name num_lines=$num_lines"
					
curl -XPOST "$influxdb_http_type://$influxdb_host:$influxdb_port/api/v2/write?bucket=$influxdb_name&org=$influxdb_org" -H "Authorization: Token $influxdb_pass" --data-raw "$post_url"
				