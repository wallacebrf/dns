#!/bin/bash

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
		fi
		lines=0
		echo "" > "web_block$file_name_counter.txt" #reset the contents if old contents were there before
	fi
done < out.txt