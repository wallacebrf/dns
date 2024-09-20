### 1.) ASN LIST Block List
I block the ASN address ranges of a large number of server rental companies as a lot of "bad actors" use these servers to perform port scans and brute force attacks. 

```ASN_LIST.txt``` --> list of the ASNs I block on my Fortigate SSL VPN loop back interface. This is the list of ASNs that the ```ASN_block_lists_all.php``` script pulls. 

```ASN_block_lists_all.php``` --> script I use to pull all of the IP address details for all ASNs in ```ASN_LIST.txt``` and save the results into ```asn_blockX.Y.txt``` files so I can use my fortigate's external threat feeds to import the results. The script downloads (as of 09/18/2024) 64,656 subnet ranges, some of the ranges go as large as a /10 subnet!

```asn_blockX.Y.txt``` --> these are the resulting files made when running the ```ASN_block_lists_all.php``` script. any one Fortigate external threat feed can only handle 131,000 entries, and the script ensures the files are maxed out and aggregates everything into as few files as possible

```manual_block_list.txt``` --> list of IPs that have tried to force a username/password on my fortigate but their ASN is a large telecomm provider and I do not wish to block the entire ASN. this is used on my Fortigate SSL_VPN loop back interface

### 2.) Web Filter Blocks
While the fortigate firewalls do have built in web-filters for advertisements and known malicious actors, it is not blocking everything I would like it to. As such I wanted to use the plethora of Pie-Hole block lists, especially the lists at this amazing site https://firebog.net/. The issue is that these lists are not formatted in the way the Fortigate external threat feeds will accept. As a result I made a script that will download all of the separate lists, format the entries to be compatible with the external threat feeds, and save the entries into separate files with 131,000 entries per file since that is the limit of the threat feeds. 

```DNS_block_lists_all.php``` COMBINED with ```webblock.sh```--> The PHP script that pulls the domain names used in multiple Pie-Hole DNS block lists. The script formats the data in a way compatible with the fortigate since pie hole lists are formatted as HOST files. The PHP script itself then activates the ```webblock.sh``` file to perform a little more filtering, but most importantly to remove duplicate entries. For example, currently the PHP script downloads (as of 09/18/2024) 2,246,682 entries and after removing duplicates, has 1,582,134 unique entries being blocked. 

I then use the WEB filter profile within my Fortigate firewall with the resulting ```web_blockX.txt``` files as external threat feed to block significant amounts of ads, tracking, and malicious sites on top of what fortinet already blocks. Refer to ```SSL_VPN Config with loopback and auto-block.txt``` for how I configured my Fortigate SSLVPN. 

```web_blockX.txt``` --> these are the resulting files made when running the ```DNS_block_lists_all.php``` script. any one Fortigate external threat feed can only handle 131,000 entries, and the script ensures the files are maxed out and aggregates everything into as few files as possible. As of 09/18/2024, there are 13x files starting from ```web_block0.txt``` through ```web_block12.txt```. 

### 3.) Linux server UFW firewall ASN blocking and Geography blocking

To increase the security of the VPS I am using i also want to be able to use my ASN lists so I can add IP addresses to the ufw firewall to block connections, but I needed a easy way to add and or remove entries from the firewall as required. 

```fw_update.sh``` was written to allow for this. 

If ASN based blocking is not desired, it can be turned off by setting the script variable ```block_ASN=1``` from a value of 1 to a value of 0. 

The script will also download many different country code IPv4 IP ranges to allow for Geo based blocking. I have disabled all IPv6 incoming connections to my VPS, so I am not downloading the IPv6 addresses ranges. Currently the script downloads ALL countries IPv4 ranges EXCEPT for the United states and Germany. The US because that is the country I live in, but did not want to block Germany as Hetzner is a German company and I did not want to risk issues. 

The script gets the needed Geo IP ranges from this repository: https://github.com/herrbischoff/country-ip-blocks/tree/master

If Geo based blocking is not desired, it can be turned off by setting the script variable ```block_geo=1``` from a value of 1 to a value of 0. 

If IPv6 incoming connections are not being allowed at all, like I am with my VPS, then keep the variable ```ipv6=0``` set to 0. If you wish to use IPv6, then set this variable to 1. 

to see what the script will attempt to do to your system's UFW configuration without actually applying those changes, set the variable ```test_mode=0``` to a value of 1. The script will output what it is doing, but not actually make changes to UFW. 

when this script is run, it will download all of the ASN and Geo block files, aggregate them into one file, and check each address to see if it currently being blocked by UFW. If it NOT currently being blocked, then it will be added to your UFW config as a "DENY IN" to "ANYWHERE"

the second thing the script will do is compare all of the DENY IN entries in the UFW configuration and confirm they are still part of the ASN/GEO block lists. If the entry is NOT in those lists, then it will be removed. This is to ensure as those lists update over time, both new addresses will be added, but old addresses will be removed as well from your configuration. 

Any "ALLOW IN" entries on the UFW fire wall will be ignored by this script. 

running this script for the first time will take DAYS TO COMPLETE as well over 100,000 entries will be added! The process starts out somewhat fast, but as more entries are added, it takes the UFW subsystem longer and longer to add new additional entries slowing the process down. Just let the script run. 

After the first time it is run, It is suggested to add a line to crontab to run the script once per month, this should only take a few minutes to an hour or two depending on how many addresses need to be added or removed from your UFW configuration. 

### 4.) Fortigate SSL-VPN full configuration

```SSL_VPN Config with loopback and auto-block.txt``` is my entire working fortigate SSLVPN configuration. This allows for auto-blocking of ~20 of the most common user name brute force attempts. It blocks be geography, blocks all of the Internet Service Database (ISDB) entries, and blocks all of the entries in this repo's ASN list to reduce the number of attempts to attack the SSL VPN gateway. some items have been removed like internal IP addresses, so read carefully and ensure you properly replace the required lines to match your configuration.

### Code Breakdown

### A.) Create Loop Back Interface

The key to the fortiagte blocking everything we want is to use a loop back interface. This re-routes the WAN traffic through regular polices so we are able to perform ACCEPT or DENY actions using ISDB, address groups, external threat feeds etc. 

to create your loop back copy the following code:

```
config system interface
    edit "WAN_to_LOOPBACK"
        set vdom "root"
        set ip 10.10.20.1 255.255.255.255
        set allowaccess ping
        set type loopback
        set role lan
        set snmp-index 38
        config ipv6
            set ip6-address xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx/128
        end
    next
end
```

the IP address ```10.10.20.1 255.255.255.255``` is the address I am assigning the loopback. It can really be any address you want, but should not be publicly rout-able. The same needs to be done with the IPv6 address ``` set ip6-address xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx/128```, you need to choose an IP address to assign to this interface. Later we will be doing more with these addresses. 

### B.) Auto-Block IP addresses Attempting to Brute Force SSL-VPN logins Using Common User Names

Over time I noticed that there were common user names being used to attempt brute force log ins. Those user names were:

```
1.) admin/Admin
2.) fax/Fax
3.) fortigate/Fortigate
4.) fortinet/Fortinet
5.) guest/Guest
6.) kiosk/Kiosk
7.) printer/Printer
8.) receiving/Receiving
9.) scanner/Scanner
10.) sslvpn
11.) teacher/Teacher
12.) test/Test
13.) voicemail/Voicemail
14.) (no user name entered at all) --> when no user name is entered, the system returns "N/A"
15.) report/Report
16.) general/General
17.) frontdesk/Frontdesk
18.) tech/Tech
19.) support/Support
20.) security/Security
21.) host/Host
22.) store/Store
23.) library/Library
24.) client/Client
25.) None of the user names I use have a "." like "john.doe" so for me at least any user name with a "." is to be blocked
26.) user/User
```

If you notice, I have both upper and lower case here, to achieve this, for the username field I have to use a wildcard. For example for admin/Admin I use ``` set value "*dmin*"```. This allows me to get the upper and lower case of admin/Admin. PLEASE NOTE: ENSURE NONE OF YOUR USER NAMES HAVE THE STRING ```dmin``` AS THOSE WILL BE CAUGHT BY THIS. 

below are all of my automation TRIGGERS. I have to have one trigger per user name as FortiOS only allows "AND" and not "OR" for user name. 

```
config system automation-trigger
    edit "SSLVPN_Connection"
        set event-type event-log
        set logid 39947 39424
    next
    edit "SSL_LOGIN_FAIL_admin"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*dmin*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_fax"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*ax*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_fortigate"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*ortigate*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_fortinet"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*ortinet*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_guest"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*uest*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_kiosk"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*iosk*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_printer"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*rinter*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_receiving"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*eceiving*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_scanner"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*canner*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_sslvpn"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*slvpn*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_teacher"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*eacher*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_test"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*est*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_voicemail"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*oicemail*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_NA"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "N/A"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_report"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*eport*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_general"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*eneral*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_frontdesk"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*rontdesk*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_tech"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*ech*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_support"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*upport*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_security"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*ecurity*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_host"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*ost*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_store"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*tore*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_library"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*ibrary*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_client"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*lient*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_dot"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*.*"
            next
        end
    next
    edit "SSL_LOGIN_FAIL_USER"
        set description "SSL_LOGIN_FAIL"
        set event-type event-log
        set logid 39426
        config fields
            edit 1
                set name "user"
                set value "*ser*"
            next
        end
    next
end
```

Next we have the automation actions. We have three actions, one is to add the offending IP address to an IP address object and to add that address object to our address group used for blocking. The second action is to send an email notification about the address being blocked. The third is to send notifications when a successful SSL-VPN connection is made. 
The address object created uses the following format: ```SSL_VPN_Block_%%log.remip%%```. So if the offending IP address is "11.22.33.44" then the address object will be named ```SSL_VPN_Block_11.22.33.44```. This address object is then added to an address group named ```Block_SSL_Failed``` which will be used in the loop back interface. 

Ensure the to and from email addresses are configured correctly. Also ensure that your fortigate is properly configured to send emails (that is not included in this config). Finally ensure the email subject is as desired. 


```
config system automation-action
    edit "SSL_Connection"
        set action-type email
        set email-to "email@email.com"
        set email-from "from@email.com"
        set email-subject "New SSL Connection"
    next
    edit "Block_SSL_Failed"
        set description "Block_SSL_Failed"
        set action-type cli-script
        set script "config firewall address
edit SSL_VPN_Block_%%log.remip%%
set subnet %%log.remip%%/32
end
config firewall addrgrp
edit Block_SSL_Failed
append member SSL_VPN_Block_%%log.remip%%
end"
        set accprofile "super_admin"
    next
    edit "SSL_VPN_Block"
        set description "SSL_VPN_Block"
        set action-type email
        set email-to "email@email.com"
        set email-from "from@email.com"
        set email-subject "SSL VPN IP Auto Blocked"
        set message "%%log.remip%% address has been added to the address group \"Block_SSL_Failed\" while using the following username: \"%%log.user%%\". 
The results of the CLI script were:
%%results%%"
    next
end
```

Next we have our actual automation stitches which will utilize our triggers and actions. Unfortunately we need a separate sticth per user name trigger since we are not allowed to use "OR" logic in the triggers. 

```
config system automation-stitch
    edit "SSL_Connection"
        set trigger "SSLVPN_Connection"
        config actions
            edit 1
                set action "SSL_Connection"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_admin"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_admin"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_fax"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_fax"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_fortigate"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_fortigate"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_fortinet"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_fortinet"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_guest"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_guest"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_kiosk"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_kiosk"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_printer"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_printer"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_receiving"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_receiving"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_scanner"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_scanner"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_sslvpn"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_sslvpn"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_teacher"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_teacher"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_test"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_test"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_voicemail"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_voicemail"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_NA"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_NA"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_report"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_report"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_general"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_general"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_frontdesk"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_frontdesk"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_tech"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_tech"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_support"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_support"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_security"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_security"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_host"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_host"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_store"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_store"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_library"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_library"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_client"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_client"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_dot"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_dot"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
    edit "SSL_LOGIN_FAIL_USER"
        set description "SSL_VPN_Block"
        set status enable
        set trigger "SSL_LOGIN_FAIL_USER"
        config actions
            edit 1
                set action "Block_SSL_Failed"
                set required enable
            next
            edit 2
                set action "SSL_VPN_Block"
                set required enable
            next
        end
    next
end
```

### C.) Needed address Objects
Next we have the address objects we need. we will define the address range allowed by the SSL VPN tunnel under the object name of ```SSLVPN_TUNNEL_ADDR1```

```
config firewall address
    edit "SSLVPN_TUNNEL_ADDR1"
        set type iprange
        set start-ip 10.212.134.200
        set end-ip 10.212.134.210
    next
```

### D.) Loop Back Interface
Next we create the address objects for the IP addresses assigned to the loop back interface

```
edit "WAN_to_LOOPBACK address"
        set type interface-subnet
        set subnet 10.10.20.1 255.255.255.255
        set interface "WAN_to_LOOPBACK"
    next
end
config firewall address6
    edit "SSLVPN_TUNNEL_IPv6_ADDR1"
        set ip6 fdff:ffff::/120
    next
    edit "SSL_VPN_address"
        set ip6 xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx/128
    next
end
```

### E.) Geo-Blocking
within the file
https://raw.githubusercontent.com/wallacebrf/dns/main/SSL_VPN%20Config%20with%20loopback%20and%20auto-block.txt

There are many countries listed which are used to block those countries in the address group below. choose the countries you wish to block and replace the line ```set member "your_chosen_countries_to_block"``` below with the appropriate entries. 

```
config firewall addrgrp
    edit "SSL_VPN_Block_Geography"
        set member "your_chosen_countries_to_block"
    edit "Block_SSL_Failed"
    next
end
```

### F.) External Threat Feeds
Next we need to configure our external threat feeds. One is a list of ASNs that we wish to block. The second is a list of addresses that we wish to block, but are part of a large ASN like comcast, ATT, verison etc. we can add the individual addresses to this list so we do not fill our Fortigate with thousands of address objects. 

```
config system external-resource
    edit "manual_blocked"
        set type address
        set resource "https://raw.githubusercontent.com/wallacebrf/dns/main/manual_block_list.txt"
        set refresh-rate 60
    next
    edit "ASN_lists_blocked"
        set type address
        set resource "https://raw.githubusercontent.com/wallacebrf/dns/main/asn_block1.1.txt"
        set refresh-rate 1440
    next
end
```

### G.) SSL VPN Tunnel Settings
Next we get to configure the SSL-VPN settings themselves. we need to create a user group. In this case we are making the group ```SSL-VPN_Admin```. Replace "12345" with the users you wish to allow. 

ensure to replace the line ```set servercert "my_cert"``` with your loaded SSL certificate that has already been loaded into the fortiagte. 

```
config user group
    edit "SSL-VPN_Admin"
        set member "12345"
    next
end
config vpn ssl web portal
    edit "full-access"
        set tunnel-mode enable
        set ipv6-tunnel-mode enable
        set web-mode enable
        set limit-user-logins enable
        set forticlient-download disable
        set auto-connect enable
        set keep-alive enable
        set save-password enable
        set ip-pools "SSLVPN_TUNNEL_ADDR1"
        set split-tunneling disable
        set ipv6-pools "SSLVPN_TUNNEL_IPv6_ADDR1"
        set ipv6-split-tunneling disable
    next
    edit "web-access"
        set limit-user-logins enable
        set forticlient-download disable
    next
end
config vpn ssl settings
    set status enable
    set servercert "my_cert"
    set idle-timeout 3600
    set login-attempt-limit 5
    set login-block-time 86400
    set tunnel-ip-pools "SSLVPN_TUNNEL_ADDR1"
    set tunnel-ipv6-pools "SSLVPN_TUNNEL_IPv6_ADDR1"
    set dns-server1 8.8.8.8
    set dns-server2 1.1.1.1
    set ipv6-dns-server1 2001:4860:4860::8888
    set ipv6-dns-server2 2606:4700::1111
    set port 443
    set header-x-forwarded-for pass
    set source-interface "WAN_to_LOOPBACK"
    set source-address "all"
    set source-address6 "all"
    set default-portal "web-access"
    config authentication-rule
        edit 1
            set groups "SSL-VPN_Admin"
            set portal "full-access"
        next
    end
    set hsts-include-subdomains enable
    set dual-stack-mode enable
end
```

### H.) Virtual IP
next we need to create two virtual IPs that will allow us for forward our WAN port 443 to our loop back interface IP address assignments. 

ensure the lines ```set extip xxx.xxx.xxx.xxx``` and ```set extip xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx``` match your WAN IPv4 and IPv6 addresses respectively. Ensure the line ```set mappedip xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx``` is the same IPv6 address we assigned to the loopback interface in line ```set ip6-address xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx/128```

```
config firewall vip
    edit "WAN_to_LOOPBACK"
        set extip xxx.xxx.xxx.xxx
        set mappedip "10.10.20.1"
        set extintf "wan1"
        set portforward enable
        set extport 443
        set mappedport 443
    next
end
config firewall vip6
    edit "WAN_to_LOOPBACK"
        set extip xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx
        set mappedip xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx
        set portforward enable
        set extport 443
        set mappedport 443
    next
end
```

### I.) Required Firewall Policies
finally we need to create the required fire wall polices that will allow traffic from the WAN port to travel to the loop back interface. 

1.) SSL_VPN_ASN_BLOCKED_IPv6 --> this policy will block all IPv6 traffic from the WAN interface to our loop back interface where the IPv6 address is included in the external threat feed ```ASN_lists_blocked```

2.) SSL_VPN_MANUAL_BLOCKED_IPv6 --> this policy will block all IPv6 traffic from the WAN interface to our loop back interface where the IPv6 address is included in the external threat feed ```manual_blocked```

3.) SSL_VPN_Loopback_IPv6_ONLY --> this policy will ALLOW all other IPv6 traffic that has not already been blocked by our two external threat feeds. 

4.) SSL_VPN_BLOCK_GEOGRAPHY_IPv4 --> this policy will block all IPv4 traffic from the WAN interface to our loop back interface where the IPv4 address is from any of our desired blocked countries. 

5.) SSL_VPN_Loopback_ISDB_IPv4 --> this policy will block all IPv4 traffic from the WAN interface to our loop back interface where the IPv4 address is contained within our desired Fortigate Internet Service Database (ISDB) lists. 

6.) SSL_VPN_ASN_BLOCKED_IPv4 --> this policy will block all IPv4 traffic from the WAN interface to our loop back interface where the IPv4 address is included in the external threat feed ```ASN_lists_blocked```

7.) SSL_VPN_MANUAL_BLOCKED_IPv4 --> this policy will block all IPv4 traffic from the WAN interface to our loop back interface where the IPv4 address is included in the external threat feed ```manual_blocked```

8.) SSL_VPN_ALLOWED_IPv4 --> This policy will ALLOW all IPv4 traffic from the WAN interface to our loop back interface where the IPv4 address has not already been blocked by the ASN, manual block, ISDB, and geo-blocks. 

```
config firewall policy
    edit 95
        set status enable
        set name "SSL_VPN_ASN_BLOCKED_IPv6"
        set srcintf "wan1"
        set dstintf "WAN_to_LOOPBACK"
        set srcaddr6 "ASN_lists_blocked"
        set dstaddr6 "WAN_to_LOOPBACK"
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
    edit 93
        set status enable
        set name "SSL_VPN_MANUAL_BLOCKED_IPv6"
        set srcintf "wan1"
        set dstintf "WAN_to_LOOPBACK"
        set srcaddr6 "manual_blocked"
        set dstaddr6 "WAN_to_LOOPBACK"
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
    edit 89
        set status enable
        set name "SSL_VPN_Loopback_IPv6_ONLY"
        set srcintf "wan1"
        set dstintf "WAN_to_LOOPBACK"
        set action accept
        set srcaddr6 "all"
        set dstaddr6 "WAN_to_LOOPBACK"
        set schedule "always"
        set service "HTTPS"
        set utm-status enable
        set inspection-mode proxy
        set profile-protocol-options "Core_Proxy"
        set ssl-ssh-profile "certificate-inspection"
        set ips-sensor "Core_high_security"
        set logtraffic all
    next
    edit 90
        set status enable
        set name "SSL_VPN_BLOCK_GEOGRAPHY_IPv4"
        set srcintf "wan1"
        set dstintf "WAN_to_LOOPBACK"
        set srcaddr "SSL_VPN_Block_Geography"
        set dstaddr "WAN_to_LOOPBACK"
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
    edit 88
        set status enable
        set name "SSL_VPN_Loopback_ISDB_IPv4"
        set srcintf "wan1"
        set dstintf "WAN_to_LOOPBACK"
        set dstaddr "WAN_to_LOOPBACK"
        set internet-service-src enable
        set internet-service-src-name "Akamai-Linode.Cloud" "Alibaba-Alibaba.Cloud" "Amazon-Amazon.SES" "Amazon-AWS" "Amazon-AWS.GovCloud.US" "Atlassian-Atlassian.Cloud" "BinaryEdge-Scanner" "Botnet-C&C.Server" "Bunny.net-CDN" "Cisco-Meraki.Cloud" "Cloudflare-CDN" "CriminalIP-Scanner" "Cyber.Casa-Scanner" "Datadog-Datadog" "Extreme-Extreme.Cloud" "Five9-Five9" "Google-Google.Bot" "GTHost-Dedicated.Instant.Servers" "Hetzner-Hetzner.Hosting.Service" "Hosting-Bulletproof.Hosting" "Hurricane.Electric-Hurricane.Electric.Internet.Services" "Imperva-Imperva.Cloud.WAF" "Ingenuity-Ingenuity.Cloud.Service" "Internet.Census.Group-Scanner" "Malicious-Malicious.Server" "Medianova-CDN" "Microsoft-Bing.Bot" "NetScout-Scanner" "NodePing-NodePing.Probe" "Okta-Okta" "Phishing-Phishing.Server" "Proxy-Proxy.Server" "Qualys-Qualys.Cloud.Platform" "Shodan-Scanner" "Skyhigh.Security-Secure.Web.Gateway" "SolarWinds-Pingdom.Probe" "SolarWinds-SolarWinds.RMM" "SolarWinds-SpamExperts" "Stark.Industries-Stark.Industries.Hosting.Service" "StatusCake-StatusCake.Monitor" "Stretchoid-Scanner" "Tenable-Tenable.io.Cloud.Scanner" "Tor-Exit.Node" "Tor-Relay.Node" "VPN-Anonymous.VPN" "8X8-8X8.Cloud" "Adobe-Adobe.Sign" "Akamai-CDN" "Apple-APNs" "Atlassian-Atlassian.Notification" "Azion-Azion.Platform" "CacheFly-CDN" "Cato-Cato.Cloud" "CDN77-CDN" "Censys-Scanner" "Cisco-Secure.Endpoint" "ColoCrossing-ColoCrossing.Hosting.Service" "DigitalOcean-DigitalOcean.Platform" "Edgio-CDN" "Fastly-CDN" "GCore.Labs-CDN" "Gigas-Gigas.Cloud" "GitHub-GitHub" "Google-Gmail" "Google-Google.Cloud" "INAP-INAP" "InterneTTL-Scanner" "Jamf-Jamf.Cloud" "Kakao-Kakao.Services" "LaunchDarkly-LaunchDarkly.Platform" "LeakIX-Scanner" "Microsoft-Azure" "Microsoft-Azure.AD" "Microsoft-Azure.Data.Factory" "Microsoft-Azure.Monitor" "Microsoft-Azure.Power.BI" "Microsoft-Azure.SQL" "Microsoft-Azure.Virtual.Desktop" "Microsoft-Dynamics" "Microsoft-Office365.Published" "Microsoft-Office365.Published.Allow" "Microsoft-Office365.Published.Optimize" "Microsoft-Office365.Published.USGOV" "Microsoft-Outlook" "Microsoft-Skype_Teams" "Microsoft-Teams.Published.Worldwide.Allow" "Microsoft-Teams.Published.Worldwide.Optimize" "Microsoft-WNS" "Mimecast-Mimecast" "NetDocuments-NetDocuments.Platform" "Netskope-Netskope.Cloud" "Neustar-UltraDNS.Probes" "NewRelic-Synthetic.Monitor" "Nice-CXone" "Oracle-Oracle.Cloud" "OVHcloud-OVHcloud" "Paylocity-Paylocity" "Performive-Performive.Cloud" "Recyber-Scanner" "RedShield-RedShield.Cloud" "Salesforce-Email.Relay" "SAP-SAP.Ariba" "Sendgrid-Sendgrid.Email" "SentinelOne-SentinelOne.Cloud" "Shadowserver-Scanner" "Shopify-Shopify" "Sinch-Mailgun" "Slack-Slack" "Spam-Spamming.Server" "StackPath-CDN" "Tencent-VooV.Meeting" "Twilio-Elastic.SIP.Trunking" "UK.NCSC-Scanner" "UptimeRobot-UptimeRobot.Monitor" "VadeSecure-VadeSecure.Cloud" "Veritas-Enterprise.Vault.Cloud" "Vonage-Vonage.Contact.Center" "Voximplant-Voximplant.Platform" "xMatters-xMatters.Platform" "Zendesk-Zendesk.Suite" "Zoho-Site24x7.Monitor" "Zoom.us-Zoom.Meeting"
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
    edit 96
        set status enable
        set name "SSL_VPN_ASN_BLOCKED_IPv4"
        set srcintf "wan1"
        set dstintf "WAN_to_LOOPBACK"
        set srcaddr "ASN_lists_blocked"
        set dstaddr "WAN_to_LOOPBACK"
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
    edit 91
        set status enable
        set name "SSL_VPN_AUTO_BLOCK_IPv4"
        set srcintf "wan1"
        set dstintf "WAN_to_LOOPBACK"
        set srcaddr "Block_SSL_Failed"
        set dstaddr "WAN_to_LOOPBACK"
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
    edit 92
        set status enable
        set name "SSL_VPN_MANUAL_BLOCKED_IPv4"
        set srcintf "wan1"
        set dstintf "WAN_to_LOOPBACK"
        set srcaddr "manual_blocked"
        set dstaddr "WAN_to_LOOPBACK"
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
    edit 94
        set status enable
        set name "SSL_VPN_ALLOWED_IPv4"
        set srcintf "wan1"
        set dstintf "WAN_to_LOOPBACK"
        set action accept
        set srcaddr "all"
        set dstaddr "WAN_to_LOOPBACK"
        set schedule "always"
        set service "HTTPS"
        set utm-status enable
        set inspection-mode proxy
        set profile-protocol-options "Core_Proxy"
        set ssl-ssh-profile "certificate-inspection"
        set ips-sensor "Core_high_security"
        set logtraffic all
    next
end
```
