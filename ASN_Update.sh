#!/bin/bash

Working_Dir="/volume1/web/ASN_List2"


##########################################################################
#create a lock file and temp directory directory to prevent more than one instance of this script from executing  at once
##########################################################################
if ! mkdir "$Working_Dir/tmp"; then
	echo "Failed to acquire lock and creating temp directory failed.\n" >&2
	#exit 1
fi
trap 'rm -rf $Working_Dir/tmp/' EXIT #remove the lockdir on exit

##########################################################################
#create logging directory if does not exist and creating log file
##########################################################################
if [[ -d "$Working_Dir/log/" ]]; then
	echo "Log directory \"$Working_Dir/log/\" exists"
else
	mkdir "$Working_Dir/log/"
	echo "Created Log directory \"$Working_Dir/log/\""
fi
date=$(date '+%Y-%m-%d')
echo "Log Date: $date" > "$Working_Dir/log/$date.txt"
##########################################################################
#download all of the ASN text files 
##########################################################################
echo -e "\n\n***************************************"  |& tee -a "$Working_Dir/log/$date.txt" 
echo "download all of the ASN text files"  |& tee -a "$Working_Dir/log/$date.txt"
echo -e "***************************************\n\n"  |& tee -a "$Working_Dir/log/$date.txt"
	
while read line; do
	echo "Processing \"${line//[$'\t\r\n ']}\""  |& tee -a "$Working_Dir/log/$date.txt"
	curl -s -d @filename https://asn.ipinfo.app/api/text/list/${line//[$'\t\r\n ']} > "$Working_Dir/tmp/${line//[$'\t\r\n ']}.txt"
	num_lines=$(wc -l < $Working_Dir/tmp/${line//[$'\t\r\n ']}.txt)
	if [ $num_lines -gt 0 ]; then
		echo "$num_lines Subnets Downloaded from ${line//[$'\t\r\n ']}"  |& tee -a "$Working_Dir/log/$date.txt"
	else
		echo -e "\nWARNING - ${line//[$'\t\r\n ']} Returned Zero Subnets\n"  |& tee -a "$Working_Dir/log/$date.txt"
	fi
	
done < "$Working_Dir/ASN.txt"


##########################################################################
# Combine all text files
##########################################################################
echo -e "\n\n***************************************"  |& tee -a "$Working_Dir/log/$date.txt"
echo "Combining all text files"  |& tee -a "$Working_Dir/log/$date.txt"
echo -e "***************************************\n\n"  |& tee -a "$Working_Dir/log/$date.txt"
cd "$Working_Dir/tmp/"
cat *.txt > "$Working_Dir/asn_block1.1.txt"
num_lines=$(wc -l < "$Working_Dir/asn_block1.1.txt")
echo -e "Final Total blocked Subnets is $num_lines\n\n"  |& tee -a "$Working_Dir/log/$date.txt"
