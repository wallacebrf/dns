```ASN_LIST.txt``` --> list of the ASNs I block on my Fortigate SSL VPN loop back interface

```ASN_block_lists_all.php``` --> script I use to pull all of the IP address details for all ASNs in ```ASN_LIST.txt``` and save the results into ```asn_blockX.Y.txt``` files so I can use my fortigate's external threat feeds to import the results

```DNS_block_lists_all.php``` COMBINED with ```webblock.sh```--> The PHP script that pulls the domain names used in multiple Pie-Hole DNS block lists. The script formats the data in a way compatible with the fortigate since pie hole lists are formatted as HOST files. The PHP script itself then activates the .sh file to perform a little more filtering, but most importantly to remove duplicate entries. For example, currently the PHP script downloads over 2-million entries and after removing duplicates, it removes around 45% of those entries. 

I then use the WEB filter profile within my Fortigate firewall loop back interface with the resulting ```web_blockX.txt``` files as external threat feed to block significant amounts of ads, tracking, and malicious sites on top of what fortinet already blocks

```web_blockX.txt``` --> these are the resulting files made when running the ```DNS_block_lists_all.php``` script. any one Fortigate external threat feed can only handle 131,000 entries, and the script ensures the files are maxed out and aggregates everything into as few files as possible

```asn_blockX.Y.txt``` --> these are the resulting files made when running the ```ASN_block_lists_all.php``` script. any one Fortigate external threat feed can only handle 131,000 entries, and the script ensures the files are maxed out and aggregates everything into as few files as possible

```manual_block_list.txt``` --> list of IPs that have tried to force a username/password on my fortigate but that i either cannot find their ASN, or their ASN is a large telecom provider and i do not wish to block. this is used on my Fortigate SSL_VPN loop back interface
