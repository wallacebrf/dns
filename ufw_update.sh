#!/bin/bash

#Note this script needs two external files
#ASN.txt   -->   This file contains the different ASNs this script will download and Block
#geoblock.txt  -->  This file contains the different country IP lists this script will download and Block

ipv6=0 #set to a 1 to add IPv6 addresses to the UFW configuration
test_mode=0 #set to a "1" to download and compare settings, but do NOT change any of the current settings on the system
block_ASN=1
block_geo=1
Working_Dir="/var/www"

##########################################################################
#create a lock file and temp directory directory to prevent more than one instance of this script from executing  at once
##########################################################################

if ! mkdir "$Working_Dir/tmp"; then
	echo "Failed to acquire lock and creating temp directory failed.\n" >&2
	exit 1
fi
trap 'rm -rf $Working_Dir/tmp' EXIT #remove the lockdir on exit

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

##########################################################################
#download all of the ASN text files 
##########################################################################
if [[ $block_ASN -eq 1 ]]; then
	if [[ ! -r "$Working_Dir/ASN.txt" ]]; then
		echo -e "Unable to read required file \"$Working_Dir/ASN.txt\"\n" |& tee -a "$Working_Dir/log/$date.txt" 
		exit 1
	fi

	echo -e "\n\n***************************************"  |& tee -a "$Working_Dir/log/$date.txt" 
	echo "download all of the ASN text files"  |& tee -a "$Working_Dir/log/$date.txt"
	echo -e "***************************************\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

	num_ASN=$(wc -l < "$Working_Dir/ASN.txt")
	counter=1
		
	while read -r line; do
		echo "ASN $counter/$num_ASN - Processing \"${line//[$'\t\r\n ']}\""  |& tee -a "$Working_Dir/log/$date.txt"
		let counter=counter+1
		curl -s "https://asn.ipinfo.app/api/text/list/${line//[$'\t\r\n ']}" > "$Working_Dir/tmp/ASN$counter.txt"
		num_lines=$(wc -l < "$Working_Dir/tmp/ASN$counter.txt")
		if [ "$num_lines" -gt 0 ]; then
			echo -e "\n$num_lines Subnets Downloaded from ${line//[$'\t\r\n ']}\n"  |& tee -a "$Working_Dir/log/$date.txt"
		else
			echo -e "\nWARNING - ${line//[$'\t\r\n ']} Returned Zero Subnets\n"  |& tee -a "$Working_Dir/log/$date.txt"
		fi
		
	done < "$Working_Dir/ASN.txt"

else
	echo -e "\n\n***************************************"  |& tee -a "$Working_Dir/log/$date.txt" 
	echo "Skipping ASN Block Lists"  |& tee -a "$Working_Dir/log/$date.txt" 
	echo -e "***************************************\n\n"  |& tee -a "$Working_Dir/log/$date.txt" 
fi

##########################################################################
#download GEOBLOCK text files 
#supply of IPs for different countries: https://github.com/herrbischoff/country-ip-blocks/tree/master/ipv4
#country codes: https://www.iban.com/country-codes
##########################################################################
if [[ $block_geo -eq 1 ]]; then

	if [[ ! -r "$Working_Dir/geoblock.txt" ]]; then
		echo -e "Unable to read required file \"$Working_Dir/geoblock.txt\"\n" |& tee -a "$Working_Dir/log/$date.txt" 
		exit 1
	fi

	echo -e "\n\n***************************************"  |& tee -a "$Working_Dir/log/$date.txt" 
	echo "download all of the geoblock text files"  |& tee -a "$Working_Dir/log/$date.txt"
	echo -e "***************************************\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

	num_geo=$(wc -l < "$Working_Dir/geoblock.txt")
	counter=1
		
	while read -r line; do
		echo "geoblock $counter/$num_geo - Processing"  |& tee -a "$Working_Dir/log/$date.txt"
		wget -q -O geo$counter.txt "${line//[$'\t\r\n ']}"
		mv "$Working_Dir/geo$counter.txt" "$Working_Dir/tmp/geo$counter.txt"
		num_lines=$(wc -l < "$Working_Dir/tmp/geo$counter.txt")
		if [ "$num_lines" -gt 0 ]; then
			echo -e "\n$num_lines Subnets Downloaded from ${line//[$'\t\r\n ']}\n"  |& tee -a "$Working_Dir/log/$date.txt"
		else
			echo -e "\nWARNING - ${line//[$'\t\r\n ']} Returned Zero Subnets\n"  |& tee -a "$Working_Dir/log/$date.txt"
		fi
		let counter=counter+1
	done < "$Working_Dir/geoblock.txt"

else
	echo -e "\n\n***************************************"
	echo "Skipping Geography Block Lists"
	echo -e "***************************************\n\n"
fi 

##########################################################################
# Combine all text files
##########################################################################
echo -e "\n\n***************************************"  |& tee -a "$Working_Dir/log/$date.txt"
echo "Combining all text files"  |& tee -a "$Working_Dir/log/$date.txt"
echo -e "***************************************\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

cd "$Working_Dir/tmp/" || exit 1
cat *.txt > "$Working_Dir/tmp/master.txt"
num_lines=$(wc -l < "$Working_Dir/tmp/master.txt")

echo -e "Total Lines Of Data Downloaded: $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong" |& tee -a "$Working_Dir/log/$date.txt"
	exit 1
fi

echo -e "Removing the following items: \"127.0.0.1 \", \"localhost\", \"::1 \", \"0.0.0.0 \", \"0.0.0.0\", \"127.0.0.1	\", \".localdomain\", \"255.255.255.255	broadcasthost\", \"::1\" , \"|\" , \"^\"\n\n" |& tee -a "$Working_Dir/log/$date.txt"
sed -i -e 's/\(127.0.0.1 \|localhost\|::1 \|0.0.0.0 \|0.0.0.0\|.localdomain\|255.255.255.255	broadcasthost\|::1\)//g' "$Working_Dir/tmp/master.txt"
num_lines=$(wc -l < "$Working_Dir/tmp/master.txt")
echo -e "Data Removed - Current blocked IP Address Objects is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

echo -e "Clearing all comment lines starting with \"#\""  |& tee -a "$Working_Dir/log/$date.txt"
sed -i 's/#.*$//' "$Working_Dir/tmp/master.txt" #delete lines starting with # as those are comments
num_lines=$(wc -l < "$Working_Dir/tmp/master.txt")
echo -e "Data Removed - Current blocked IP Address Objects is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"  |& tee -a "$Working_Dir/log/$date.txt"
	exit 1
fi

if [[ "$ipv6" -eq 0 ]]; then
	echo -e "IPv6 processing is disabled, removing IPv6 addresses"  |& tee -a "$Working_Dir/log/$date.txt"
	sed -i '/:/d' "$Working_Dir/tmp/master.txt"
fi

num_lines=$(wc -l < "$Working_Dir/tmp/master.txt")
echo -e "IPv6 Addresses Removed - Current blocked IP Address Objects is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"  |& tee -a "$Working_Dir/log/$date.txt"
	exit 1
fi


echo -e "Deleting all Empty/Cleared Lines"  |& tee -a "$Working_Dir/log/$date.txt"
sed -i '/^\s*$/d' "$Working_Dir/tmp/master.txt" #delete empty lines
num_lines=$(wc -l < "$Working_Dir/tmp/master.txt")
echo -e "Data Removed - Current blocked IP Address Objects is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"  |& tee -a "$Working_Dir/log/$date.txt"
	exit 1
fi

echo -e "Deleting all other instances of \"!\" \"|\" \"^\" \"?\" \"=\" and \" \" within the file as these are not allowable URL characters"  |& tee -a "$Working_Dir/log/$date.txt"
sed -i 's|[|!^?= },]||g' "$Working_Dir/tmp/master.txt"
num_lines=$(wc -l < "$Working_Dir/tmp/master.txt")
echo -e "Data Removed - Current blocked IP Address Objects is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"  |& tee -a "$Working_Dir/log/$date.txt"
	exit 1
fi

echo -e "Deleting all duplicate entries"  |& tee -a "$Working_Dir/log/$date.txt"
awk -i inplace '!seen[$0]++' "$Working_Dir/tmp/master.txt" # delete duplicates 
num_lines=$(wc -l < "$Working_Dir/tmp/master.txt")
echo -e "Duplicate lines removed. Final Total blocked IP Address Objects is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"  |& tee -a "$Working_Dir/log/$date.txt"
	exit 1
fi

##########################################################################
# Sort Addresses
##########################################################################
echo -e "\n\n***************************************"  |& tee -a "$Working_Dir/log/$date.txt"
echo "Sorting Addresses"  |& tee -a "$Working_Dir/log/$date.txt"
echo -e "***************************************\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n "$Working_Dir/tmp/master.txt" > "$Working_Dir/tmp/master_sorted.txt"

num_lines1=$(wc -l < "$Working_Dir/tmp/master_sorted.txt")
echo -e "Total Blocked Subnets: $num_lines1\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

echo -e "Aggregating Subnets"  |& tee -a "$Working_Dir/log/$date.txt"
#~/.local/bin# ./aggregate6 "/mnt/c/scripts/asn_block1.1.txt" > "/mnt/c/scripts/asn_block1.1_processed.txt"
aggregate6 "$Working_Dir/tmp/master_sorted.txt" > "$Working_Dir/tmp/master.txt"
num_lines=$(wc -l < "$Working_Dir/tmp/master.txt")
echo -e "Subnets Aggregated. Final Total blocked IP Address Objects is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

if [[ $num_lines -eq 0 ]]; then
	echo -e "number of lines is zero, something is wrong"  |& tee -a "$Working_Dir/log/$date.txt"
	exit 1
fi


##########################################################################
#export current ufw listing
##########################################################################
echo -e "\n\n***************************************" |& tee -a "$Working_Dir/log/$date.txt"
echo "export current ufw listing" |& tee -a "$Working_Dir/log/$date.txt"
echo -e "***************************************\n\n" |& tee -a "$Working_Dir/log/$date.txt"
ufw status numbered | tee "$Working_Dir/tmp/current_ufw.txt"

##########################################################################
#delete header of ufw status, which are the first four lines of the file
##########################################################################
echo -e "\n\n***************************************" |& tee -a "$Working_Dir/log/$date.txt"
echo "delete header of ufw status" |& tee -a "$Working_Dir/log/$date.txt"
echo -e "***************************************\n\n" |& tee -a "$Working_Dir/log/$date.txt"
sed -i 1,4d "$Working_Dir/tmp/current_ufw.txt"

##########################################################################
#search through all of the downloaded ASN entries to find ones not already in the UFW configuration
##########################################################################
echo -e "\n\n*********************************************************************************************" |& tee -a "$Working_Dir/log/$date.txt"
echo "search through all of the downloaded ASN entries to find ones not already in the UFW configuration" |& tee -a "$Working_Dir/log/$date.txt"
echo -e "*********************************************************************************************\n\n" |& tee -a "$Working_Dir/log/$date.txt"
counter=1

while IFS= read -r block
do
	echo -n "Adding Address - Processing $counter/$num_lines  ->  "
	if grep -wq "$block" "$Working_Dir/tmp/current_ufw.txt"; then 
		#if the ASN address exists in the current UFW configuration, do nothing
		echo "Skipping existing address \"$block\"" 
	else 
		#if the ASN address does NOT exist in the current UFW configuration, we need to add the new address
		if [[ "$block" == *":"* ]]; then
			if [[ "$ipv6" -eq 0 ]]; then
				echo "skipping IPv6 address \"$block\""
			else
				echo "Inserting NEW IPv6 address \"$block\""
				if [[ "$test_mode" -eq 0 ]]; then
					ufw insert 1 deny from "$block"
				else
					echo "Script in Test Mode"
				fi
			fi
		else
			echo "Inserting NEW IPv4 address \"$block\""
			if [[ "$test_mode" -eq 0 ]]; then
				ufw insert 1 deny from "$block"
			else
				echo "Script in Test Mode"
			fi
		fi
	fi
	let counter=counter+1
done < "$Working_Dir/tmp/master.txt"

counter=1
##########################################################################
#search through all of the UFW configuration, and remove entries not contained in the ASN list 
##########################################################################
echo -e "\n\n*********************************************************************************************"
echo "search through all of the UFW configuration, and remove entries not contained in the ASN list "
echo -e "*********************************************************************************************\n\n"
while IFS= read -r block2
do
	echo -n "Cleaning Address - Processing $counter/$num_lines  ->  "
	string=$(echo "${block2##*IN}" | xargs) #remove everything from the line except for the IP address
	if grep -wq "$string" "Working_Dir/$master.txt"; then 
		#if the address in the current UFW configuration exists in the current ASN list, do nothing
		echo "Line \"$block2\" still valid"
	else 
		#if the address in the current UFW configuration does NOT exist in the ASN list, then it has been removed from the list and needs to be removed from the UFW configuration
		if [[ "$block2" == *"ALLOW IN"* ]]; then #if the current UFW configuration line is for the ALLOWED IN lines, do not touch those. 
			echo "Skipping removal of line \"$block2\" as this is not part of the ASN blocking" 
		elif [[ "$block2" == *"DENY IN"* ]]; then
			echo "Removing un-needed UFW address \"$string\""
			if [[ "$test_mode" -eq 0 ]]; then
				ufw delete deny from $string
			else
				echo "Script in Test Mode"
			fi
		else
			echo "skipping unknown data \"$block2\""
		fi
	fi
	let counter=counter+1
done < "$Working_Dir/tmp/current_ufw.txt"





