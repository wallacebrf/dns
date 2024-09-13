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

The key to the fortiagte blocking everything we want is to use a loop back interface. This re-routes the WAN traffic through regular polcies so we are able to perform ACCEPT or DENY actions using ISDB, address groups, external threat feeds etc. 

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

the IP address ```10.10.20.1 255.255.255.255``` is the address I am assigning the loopback. It can really be any address you want, but should not be publically routable. The same needs to be done with the IPv6 address ``` set ip6-address xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx/128```, you need to choose an IP address to assign to this interface. Later we will be doing more with these addresses. 

### B.) Auto-Block IP addresses Atempting to Brute Force SSL-VPN logins Using Common User Names

Over time I noticed that there were common user names being used to attempt brute force log ins. Those user names were:

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

If you notice, I have both upper and lower case here, to acheive this, for the username field I have to use a wildcard. For example for admin/Admin I use ``` set value "*dmin*"```. This allows me to get the upper and lower case of admin/Admin. PLEASE NOTE: ENSURE NONE OF YOUR USER NAMES HAVE THE STRING ```dmin``` AS THOSE WILL BE CAUGHT BY THIS. 

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
