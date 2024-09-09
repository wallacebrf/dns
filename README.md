### 1.) ASN LIST Block List
I block the ASN address ranges of a large number of server rental companies as a lot of "bad actors" use these servers to perform port scans and brute force attacks. 

```ASN_LIST.txt``` --> list of the ASNs I block on my Fortigate SSL VPN loop back interface. This is the list of ASNs that the ```ASN_block_lists_all.php``` script pulls. 

```ASN_block_lists_all.php``` --> script I use to pull all of the IP address details for all ASNs in ```ASN_LIST.txt``` and save the results into ```asn_blockX.Y.txt``` files so I can use my fortigate's external threat feeds to import the results. The script downloads (as of 09/09/2024) 62,818 subnet ranges, some of the ranges go as large as a /10 subnet!

```asn_blockX.Y.txt``` --> these are the resulting files made when running the ```ASN_block_lists_all.php``` script. any one Fortigate external threat feed can only handle 131,000 entries, and the script ensures the files are maxed out and aggregates everything into as few files as possible

```manual_block_list.txt``` --> list of IPs that have tried to force a username/password on my fortigate but their ASN is a large telecomm provider and I do not wish to block the entire ASN. this is used on my Fortigate SSL_VPN loop back interface

### 2.) Web Filter Blocks
While the fortigate firewalls do have built in web-filters for advertisements and known malicious actors, it is not blocking everything I would like it to. As such I wanted to use the plethora of Pie-Hole block lists, especially the lists at this amazing site https://firebog.net/. The issue is that these lists are not formatted in the way the Fortigate external threat feeds will accept. As a result I made a script that will download all of the separate lists, format the entries to be compatible with the external threat feeds, and save the entries into separate files with 131,000 entries per file since that is the limit of the threat feeds. 

```DNS_block_lists_all.php``` COMBINED with ```webblock.sh```--> The PHP script that pulls the domain names used in multiple Pie-Hole DNS block lists. The script formats the data in a way compatible with the fortigate since pie hole lists are formatted as HOST files. The PHP script itself then activates the ```webblock.sh``` file to perform a little more filtering, but most importantly to remove duplicate entries. For example, currently the PHP script downloads (as of 09/09/2024) 2,228,897 entries and after removing duplicates, has 1,563,039 unique entries being blocked. 

I then use the WEB filter profile within my Fortigate firewall with the resulting ```web_blockX.txt``` files as external threat feed to block significant amounts of ads, tracking, and malicious sites on top of what fortinet already blocks. Refer to ```SSL_VPN Config with loopback and auto-block.txt``` for how I configured my Fortigate SSLVPN. 

```web_blockX.txt``` --> these are the resulting files made when running the ```DNS_block_lists_all.php``` script. any one Fortigate external threat feed can only handle 131,000 entries, and the script ensures the files are maxed out and aggregates everything into as few files as possible. As of 09/09/2024, there are 12x files starting from ```web_block0.txt``` through ```web_block12.txt```. 

### 3.) Fortigate SSL-VPN full configuration

```SSL_VPN Config with loopback and auto-block.txt``` is my entire working fortigate SSLVPN configuration. This allows for auto-blocking of ~20 of the most common user name brute force attempts. It blocks be geography, blocks all of the Internet Service Database (ISDB) entries, and blocks all of the entries in this repo's ASN list to reduce the number of attempts to attack the SSL VPN gateway. some items have been removed like internal IP addresses, so read carefully and ensure you properly replace the required lines to match your configuration. 
