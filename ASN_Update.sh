#!/bin/bash
#Version 4/10/2025
#By Brian Wallace

Working_Dir="/volume1/web/ASN_List2"
Working_Dir="/mnt/c/scripts/ASN_List2"

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


##########################################################################
#download all of the ASN text files 
##########################################################################
if [[ ! -r "$Working_Dir/ASN.txt" ]]; then
	echo -e "Unable to read required file \"$Working_Dir/ASN.txt\"\n" >&2
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
	curl -s "https://asn.ipinfo.app/api/text/list/${line//[$'\t\r\n ']}" > "$Working_Dir/tmp/${line//[$'\t\r\n ']}.txt"
	num_lines=$(wc -l < "$Working_Dir/tmp/${line//[$'\t\r\n ']}.txt")
	if [ "$num_lines" -gt 0 ]; then
		echo -e "\n$num_lines Subnets Downloaded from ${line//[$'\t\r\n ']}\n"  |& tee -a "$Working_Dir/log/$date.txt"
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

cd "$Working_Dir/tmp/" || exit 1
cat *.txt > "$Working_Dir/master.txt"

##########################################################################
# Sort Addresses
##########################################################################
echo -e "\n\n***************************************"  |& tee -a "$Working_Dir/log/$date.txt"
echo "Sorting Addresses"  |& tee -a "$Working_Dir/log/$date.txt"
echo -e "***************************************\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n "$Working_Dir/master.txt" > "$Working_Dir/asn_block.txt"

rm "$Working_Dir/master.txt"

num_lines1=$(wc -l < "$Working_Dir/asn_block.txt")
echo -e "Total Blocked Subnets: $num_lines1\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

##########################################################################
# Aggregate Address Subnets
##########################################################################
#echo -e "\n\n***************************************"  |& tee -a "$Working_Dir/log/$date.txt"
#echo "Aggregate Address Subnets"  |& tee -a "$Working_Dir/log/$date.txt"
#echo -e "***************************************\n\n"  |& tee -a "$Working_Dir/log/$date.txt"

#cd "~/.local/bin" || exit 1
#~/.local/share/pipx/venvs/aggregate6/bin

#./aggregate6 "/mnt/c/scripts/ASN_List2/asn_block.txt" > "/mnt/c/scripts/ASN_List2/asn_block1.1.txt"

#num_lines2=$(wc -l < "$Working_Dir/asn_block1.1.txt")
#echo -e "Total Blocked Subnets: $num_lines2\n\n"  |& tee -a "$Working_Dir/log/$date.txt"
#echo -e "$(( $num_lines1 - $num_lines2 )) Aggregated into Wider Subnet\n\n"  |& tee -a "$Working_Dir/log/$date.txt"
