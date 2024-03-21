```ASN_LIST.txt``` --> list of the ASNs i block on my Fortigate SSL VPN loop back interface

```ASN_block_lists_all.php``` --> script i use to pull all of the IP address details for all ASNs in ```ASN_LIST.txt``` and save the results into one single .txt file so i can use my fortigate's external threat feeds to import the results

```DNS_block_lists_all.php``` --> script that pulls the domain names used in multiple Pie-Hole DNS block lists. the script formats the data in a way compatible with the fortigate. I then use the WEB filter profile with this as an external threat feed to block significant amounts of ads, tracking, and malicious sites

```web_blockX.Y.txt``` --> these are the resulting files made when running the ```DNS_block_lists_all.php``` script. any one Fortigate external threat feed can only handle 131,000 entires, and the script ensures the files are maxed out

```manual_block_list.txt``` --> list of IPs that have tried to force a username/password on my fortigate but that i either cannot find their ASN, or their ASN is a large telecom provider and i do not wish to block. this is used on my Fortigate SSL_VPN loop back interface
