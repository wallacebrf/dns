### 1.) ASN LIST Block List
I block the ASN address ranges of a large number of server rental companies as a lot of "bad actors" use these servers to perform port scans and brute force attacks. 

***<a href="https://raw.githubusercontent.com/wallacebrf/dns/refs/heads/main/ASN_LIST.txt">ASN_LIST.txt</a>*** --> list of the ASNs I block on my Fortigate IPSEC local-in policies. This shows the names of the ASN and the revision history tracking of when i added new ASN entires 

***<a href="https://raw.githubusercontent.com/wallacebrf/dns/refs/heads/main/ASN_Update.sh">ASN_Update.sh</a>*** combined with ***<a href="https://raw.githubusercontent.com/wallacebrf/dns/refs/heads/main/ASN.txt">ASN.txt</a>*** --> script I use to pull all of the IP address details for all ASNs in ***```ASN.txt```*** and save the results into ***```asn_blockX.Y.txt```*** files so I can use my fortigate's external threat feeds to import the results. The script downloads (as of 9/12/2025) 37,157 subnet ranges, some of the ranges go as large as a /10 subnet! The ```ASN.txt``` is the raw listing of the blocked ASNs used by the shell script, while ```ASN_List.txt``` is the user-readable and revision history details of the ASNs being blocked as previously detailed. 

***<a href="https://raw.githubusercontent.com/wallacebrf/dns/refs/heads/main/asn_block1.1.txt">asn_block1.1.txt</a>*** --> The resulting files made when running the ```ASN_Update.sh``` script. any one Fortigate external threat feed can only handle 131,000 entries, and the script ensures the files are maxed out and aggregates everything into as few files as possible

***<a href="https://raw.githubusercontent.com/wallacebrf/dns/refs/heads/main/manual_block_list.txt">manual_block_list.txt</a>*** --> list of IPs that have tried to force a username/password on my fortigate but their ASN is a large telecomm provider and I do not wish to block the entire ASN. this is used on my Fortigate Local-In policies 

### 2.) Web Filter Blocks
While the fortigate firewalls do have built in web-filters for advertisements and known malicious actors, it is not blocking everything I would like it to. As such I wanted to use the plethora of Pie-Hole block lists, especially the lists at this amazing site https://firebog.net/. The issue is that these lists are not formatted in the way the Fortigate external threat feeds will accept. As a result I made a script that will download all of the separate lists, format the entries to be compatible with the external threat feeds, and save the entries into separate files with 131,000 entries per file since that is the limit of the threat feeds. 

***<a href="https://github.com/wallacebrf/dns/blob/main/webblock.sh">webblock.sh</a>*** --> This script pulls the domain names used in multiple Pie-Hole DNS block lists contained in ***<a href="https://raw.githubusercontent.com/wallacebrf/dns/refs/heads/main/web_block_source.txt">web_block_source.txt</a>***. The script formats the data in a way compatible with the fortigate since pie hole lists are formatted as HOST files. The script also performs a little more filtering, but most importantly to removes duplicate entries. For example, currently the PHP script downloads (as of 9/6/2025) 3,190,909 entries and after removing duplicates, has 2,150,073 unique entries being blocked. 

I then use the WEB filter profile within my Fortigate firewall with the resulting ```web_blockX.txt``` files as external threat feed to block significant amounts of ads, tracking, and malicious sites on top of what fortinet already blocks. 

***<a href="https://raw.githubusercontent.com/wallacebrf/dns/refs/heads/main/web_block0.txt">web_block0.txt</a> THROUGH <a href="https://raw.githubusercontent.com/wallacebrf/dns/refs/heads/main/web_block16.txt">web_block16.txt</a>*** --> these are the resulting files made when running the ```webblock.sh``` script. any one Fortigate external threat feed can only handle 131,000 entries, and the script ensures the files are maxed out and aggregates everything into as few files as possible. As of 8/24/2025, there are ***17x*** files starting from ```web_block0.txt``` through ```web_block16.txt```. 

### 3.) Linux server UFW firewall ASN blocking and Geography blocking

To increase the security of the VPS I am using i also want to be able to use my ASN lists so I can add IP addresses to the ufw firewall to block connections, but I needed a easy way to add and or remove entries from the firewall as required. 

```ufw_update.sh``` combined with ```ASN.txt``` and ```geoblock.txt``` was written to allow for this. 

If ASN based blocking is not desired, it can be turned off by setting the script variable ```block_ASN=1``` from a value of 1 to a value of 0. 

The script will also download many different country code IPv4 IP ranges to allow for Geo based blocking. I have disabled all IPv6 incoming connections to my VPS, so I am not downloading the IPv6 addresses ranges. Currently the script downloads ALL countries IPv4 ranges EXCEPT for the United states and Germany. The US because that is the country I live in, but did not want to block Germany as Hetzner is a German company and I did not want to risk issues. 

The script gets the needed Geo IP ranges from this repository: https://github.com/herrbischoff/country-ip-blocks/tree/master

If Geo based blocking is not desired, it can be turned off by setting the script variable ```block_geo=1``` from a value of 1 to a value of 0. 

If IPv6 incoming connections are not being allowed at all, like I am with my VPS, then keep the variable ```ipv6=0``` set to 0. If you wish to use IPv6, then set this variable to 1. 

to see what the script will attempt to do to your system's UFW configuration without actually applying those changes, set the variable ```test_mode=0``` to a value of 1. The script will output what it is doing, but not actually make changes to UFW. 

when this script is run, it will download all of the ASN and Geo block files, aggregate them into one file, and check each address to see if it currently being blocked by UFW. If it NOT currently being blocked, then it will be added to your UFW config as a "DENY IN" to "ANYWHERE"

the second thing the script will do is compare all of the DENY IN entries in the UFW configuration and confirm they are still part of the ASN/GEO block lists. If the entry is NOT in those lists, then it will be removed. This is to ensure as those lists update over time, both new addresses will be added, but old addresses will be removed as well from your configuration. 

Any "ALLOW IN" entries on the UFW fire wall will be ignored by this script. 

running this script for the first time will take 2-3 days to complete the first time it is run as well over 50,000 entries will be added! The process starts out somewhat fast, but as more entries are added, it takes the UFW subsystem longer and longer to add new additional entries slowing the process down. Just let the script run. 

After the first time it is run, It is suggested to add a line to crontab to run the script once per month, this should only take a few minutes to an hour or two depending on how many addresses need to be added or removed from your UFW configuration. 

### 4.) Fortigate SSL-VPN full configuration

ATTENTION - Fortinet is removing SSL VPN from FortiOS as such while I am leaving my SSL VPN configuration, i am not breaking down the details. 
### 5.) Fortigate Dial Up IP-Sec full configuration

in the link below is my entire IPsec configuration. 

https://github.com/wallacebrf/dns/blob/main/IPsec%20Configuration.txt

***Code Breakdown***

### 5A.) - config system global
This is just basic settings that appear to be default settings

```
config system global
    set ipsec-asic-offload enable
    set ipsec-ha-seqjump-rate 10
    set ipsec-hmac-offload enable
    set ipsec-soft-dec-async disable
end
```

### 5B.) - config system interface

These are the interfaces for the IPsec VPNs. I have three configured in this example

1.) HomeVPN-IPsec --> this listens on the WAN for IPv4 connections, and uses IKEv1

2.) HomeVPNv6 --> this listens on the WAN for IPv6 connections, and uses IKEv1

3.) HomeVPNv6-IKE2 --> this listens on the WAN for IPv6 connections, and uses IKEv2

```
config system interface
	edit "HomeVPN-IPsec"
        set type tunnel
        set monitor-bandwidth enable
        set interface "wan1"
    next
    edit "HomeVPNv6""
        set type tunnel
        set monitor-bandwidth enable
        set interface "wan1"
    next
	edit "HomeVPNv6-IKE2"
        set type tunnel
        set monitor-bandwidth enable
        set interface "wan1"
    next
end
```

### 5C.) - 
Enable NTP server service on the VPN connection

```
config system ntp
    set ntpsync enable
    set server-mode enable
    set interface "HomeVPN-IPsec" "HomeVPNv6" "HomeVPNv6-IKE2"
end
```

### 5D.) - config system automation-trigger

I use automation stiches to auto-block spammers who try to brute force connections to the system if they use certain usernames such as

!!!please note, ensure what ever user name sub strings you choose would not otherwise be triggered by a valid user account on your system!!!

1.) ```"N/A"``` -> they did not supply a user name at all

2.) ```*ibrary*``` -> if the username contains the sub string "ibrary``` as i had lots of attempts using the usernames "library", "Library" or "Library1" etc. The wild card in place of the "L" allows the stitch to get lower case and upper case senarios. 

3.) "```*est*``` -> if the username contains ```est``` as i had lots of attempts using the username "test", "Test", or "Test1" etc. The wild card in place of the "T" allows the stitch to get lower case and upper case senarios. 

4.) "```*ser*``` -> if the username contains ```ser``` as i had lots of attempts using the username "user", "User", or "User1" etc. The wild card in place of the "U" allows the stitch to get lower case and upper case senarios. 

5.) "```*dmin*``` -> if the username contains ```dmin``` as i had lots of attempts using the username "admin", "Admin", or "Admin1" etc. The wild card in place of the "A" allows the stitch to get lower case and upper case senarios. 

6.) "```*lient*``` -> if the username contains ```lient``` as i had lots of attempts using the username "client", "Client", or "Client1" etc. The wild card in place of the "A" allows the stitch to get lower case and upper case senarios.

7.) "```*.*``` -> none of the users in my system have periods so any attempted log-in using one is suspicious. 

8.) "```*ax*``` -> if the username contains ```ax``` as i had lots of attempts using the username "fax", "Fax", or "Fax1" etc. The wild card in place of the "F" allows the stitch to get lower case and upper case senarios. 

9.) "```*ortigate*``` -> if the username contains ```ortigate``` as i had lots of attempts using the username "fortigate", "Fortigate", or "Fortigate1" etc. The wild card in place of the "F" allows the stitch to get lower case and upper case senarios. 

10.) ```*ortinet*``` -> if the username contains ```ortinet``` as i had lots of attempts using the username "fortinet", "Fortinet", or "Fortinet1" etc. The wild card in place of the "F" allows the stitch to get lower case and upper case senarios. 

11.) ```*rontdesk*``` -> if the username contains ```rontdesk``` as i had lots of attempts using the username "frontdesk", "Frontdesk", or "Frontdesk1" etc. The wild card in place of the "F" allows the stitch to get lower case and upper case senarios. 

12.) ```*eneral*``` -> if the username contains ```eneral``` as i had lots of attempts using the username "general", "General", or "General1" etc. The wild card in place of the "G" allows the stitch to get lower case and upper case senarios. 

13.) ```*uest*``` -> if the username contains ```uest``` as i had lots of attempts using the username "guest", "Guest", or "Guest1" etc. The wild card in place of the "G" allows the stitch to get lower case and upper case senarios.

14.) ```*ost*``` -> if the username contains ```ost``` as i had lots of attempts using the username "host", "Host", or "Host1" etc. The wild card in place of the "H" allows the stitch to get lower case and upper case senarios.

15.) ```*iosk*``` -> if the username contains ```iosk``` as i had lots of attempts using the username "kiosk", "Kiosk", or "Kiosk1" etc. The wild card in place of the "K" allows the stitch to get lower case and upper case senarios.

16.) ```*rinter*``` -> if the username contains ```rinter``` as i had lots of attempts using the username "printer", "Printer", or "Printer1" etc. The wild card in place of the "P" allows the stitch to get lower case and upper case senarios.

17.) ```*eceiving*``` -> if the username contains ```eceiving``` as i had lots of attempts using the username "receiving", "Receiving", or "Receiving1" etc. The wild card in place of the "R" allows the stitch to get lower case and upper case senarios.

18.) ```*eport*``` -> if the username contains ```eport``` as i had lots of attempts using the username "report", "Report", or "Report1" etc. The wild card in place of the "R" allows the stitch to get lower case and upper case senarios.

19.) ```*canner*``` -> if the username contains ```canner``` as i had lots of attempts using the username "scanner", "Scanner", or "Scanner1" etc. The wild card in place of the "S" allows the stitch to get lower case and upper case senarios.

20.) ```*ecurity*``` -> if the username contains ```ecurity``` as i had lots of attempts using the username "scanner", "Scanner", or "Scanner1" etc. The wild card in place of the "S" allows the stitch to get lower case and upper case senarios.

21.) ```*tore*``` -> if the username contains ```tore``` as i had lots of attempts using the username "store", "Store", or "Store1" etc. The wild card in place of the "S" allows the stitch to get lower case and upper case senarios.

22.) ```*upport*``` -> if the username contains ```upport``` as i had lots of attempts using the username "support", "Support", or "Support1" etc. The wild card in place of the "S" allows the stitch to get lower case and upper case senarios.

23.) ```*eacher*``` -> if the username contains ```eacher``` as i had lots of attempts using the username "teacher", "Teacher", or "Teacher1" etc. The wild card in place of the "T" allows the stitch to get lower case and upper case senarios.

24.) ```*ech*``` -> if the username contains ```ech``` as i had lots of attempts using the username "tech", "Tech", or "Tech1" etc. The wild card in place of the "T" allows the stitch to get lower case and upper case senarios.

25.) ```*ech*``` -> if the username contains ```ech``` as i had lots of attempts using the username "tech", "Tech", or "Tech1" etc. The wild card in place of the "T" allows the stitch to get lower case and upper case senarios.

```
config system automation-trigger
    edit "IPSEC_TUNNEL_CHANGE"
        set event-type event-log
        set logid 37138 23102 23101
    next
    edit "IPSEC_FAILED"
        set event-type event-log
        set logid 37124 37125
    next
    edit "IPSEC_AUTOBLOCK_library_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*ibrary*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_test_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*est"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_user_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*ser*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_admin_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*dmin*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_client_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*lient*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_dot_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*.*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_fax_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*ax*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_fortigate_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*ortigate*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_fortinet_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*ortinet*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_frontdesk_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*rontdesk*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_general_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*eneral*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_guest_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*uest*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_host_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*ost*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_kiosk_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*iosk*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_printer_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*rinter*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_receiving_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*eceiving*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_report_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*eport*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_scanner_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*canner*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_security_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*ecurity*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_store_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*tore*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_support_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*upport*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_teacher_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*eacher*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_tech_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*ech*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_voicemail_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "*dmin*"
            next
        end
    next
    edit "IPSEC_AUTOBLOCK_NA_ipv4"
        set event-type event-log
        set logid 37124 37125
        config fields
            edit 1
                set name "reason"
                set value "peer SA proposal not match local policy"
            next
            edit 2
                set name "user"
                set value "N/A"
            next
        end
    next
end
```

### 5E.) - config system automation-action

when a match exists to a trigger, we first add the remote IP to our config as an address object, we then add that address object to a address group, and then we send an alert email. 

```
config system automation-action
    edit "Block_VPN_Failed_ipv4"
        set description "Block_VPN_Failed"
        set action-type cli-script
        set script "config firewall address
edit VPN_Block_%%log.remip%%
set subnet %%log.remip%%/32
end
config firewall addrgrp
edit Block_VPN_Failed
append member VPN_Block_%%log.remip%%
end"
        set accprofile "super_admin"
    next
    edit "VPN_Block_IPv4"
        set description "VPN_Block"
        set action-type email
        set email-to "email@email.com"
        set email-from "email@email.com"
        set email-subject "VPN IPv4 Auto Blocked"
        set message "%%log.remip%% address has been added to the address group \\\"Block_VPN_Failed\\\" while using the following username: \\\"%%log.user%%\\\". 
The results of the CLI script were:
%%results%%"
    next
    edit "IPSEC_TUNNEL_CHANGE"
        set action-type email
        set email-to "email@email.com"
        set email-from "email@email.com"
        set email-subject "IPsec Tunnel State Change"
    next
    edit "IPSEC_FAIL"
        set action-type email
        set email-to "email@email.com"
        set email-from "email@email.com"
        set email-subject "IPsec Failure"
    next
    edit "Block_VPN_Failed_ipv6"
        set description "Block_VPN_Failed"
        set action-type cli-script
        set script "config firewall address6
edit VPN_Block_%%log.remip%%
set type iprange
        set start-ip %%log.remip%%
        set end-ip %%log.remip%%
end
config firewall addrgrp6
edit Block_VPN_Failed_IPv6
append member VPN_Block_%%log.remip%%
end"
        set accprofile "super_admin"
    next
    edit "VPN_Block_IPv6"
        set description "VPN_Block"
        set action-type email
        set email-to "email@email.com"
        set email-from "email@email.com"
        set email-subject "VPN IPv6 Auto Blocked"
        set message "%%log.remip%% address has been added to the address group \\\"Block_VPN_Failed_IPv6\\\". 
The results of the CLI script were:
%%results%%"
    next
end
```

### 5F.) - config system automation-action
Unfortunately because Fortinet does not allow to use OR in stitches, we need a separate stitch per trigger, but using the same action each time. 

```
config system automation-stitch
    edit "LOGIN_FAIL_admin"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_admin_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_fax"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_fax_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_fortigate"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_fortigate_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_fortinet"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_fortinet_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_guest"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_guest_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_kiosk"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_kiosk_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_printer"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_printer_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_receiving"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_receiving_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_scanner"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_scanner_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_teacher"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_teacher_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_test"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_test_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_voicemail"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_voicemail_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_NA"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_NA_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_report"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_report_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_general"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_general_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_frontdesk"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_frontdesk_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_tech"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_tech_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_support"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_support_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_security"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_security_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_host"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_host_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_store"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_store_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_library"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_library_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_client"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_client_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_dot"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_dot_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "IPSEC_TUNNEL_STATE_CHANGE"
        set trigger "IPSEC_TUNNEL_CHANGE"
        config actions
            edit 1
                set action "IPSEC_TUNNEL_CHANGE"
                set required enable
            next
        end
    next
    edit "LOGIN_FAIL_USER"
        set description "SSL_VPN_Block"
        set trigger "IPSEC_AUTOBLOCK_user_ipv4"
        config actions
            edit 1
                set action "Block_VPN_Failed_ipv4"
                set required enable
            next
            edit 2
                set action "VPN_Block_IPv4"
                set required enable
            next
        end
    next
    edit "IPsec Fail"
        set trigger "IPSEC_FAILED"
        config actions
            edit 1
                set action "IPSEC_FAIL"
                set required enable
            next
        end
    next
end
```

### 5G.) - config user group
we need to configure our user groups

```
config user group
    edit "IPsec-Admin"
        set member "your_user"
    next
end
```

### 5H.) - config vpn ipsec phase1-interface
Configure the phase 1 interfaces for the three different IPsec tunnels

```
config vpn ipsec phase1-interface
    edit "HomeVPN-IPsec"
        set type dynamic
        set interface "wan1"
        set peertype any
        set net-device disable
        set mode-cfg enable
        set proposal aes256-sha512 aes256-sha384 aes128-sha1
        set dhgrp 14
        set xauthtype auto
        set authusrgrp "IPsec-Admin"
        set ipv4-start-ip 10.10.30.1
        set ipv4-end-ip 10.10.30.255
        set ipv4-netmask 255.255.255.0
        set dns-mode auto
        set ipv6-start-ip 2002:db7::1
        set ipv6-end-ip 2002:db7::10
        set unity-support disable
        set psksecret ENC xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    next
    edit "HomeVPNv6"
        set type dynamic
        set interface "wan1"
        set ip-version 6
        set peertype any
        set net-device disable
        set mode-cfg enable
        set proposal aes256-sha384 aes256-sha256 aes128-sha1 aes256-sha1
        set dhgrp 14
        set xauthtype auto
        set authusrgrp "IPsec-Admin"
        set ipv4-start-ip 10.10.30.20
        set ipv4-end-ip 10.10.30.255
        set ipv4-netmask 255.255.255.0
        set dns-mode auto
        set ipv6-start-ip 2002:db7::11
        set ipv6-end-ip 2002:db7::20
        set unity-support disable
        set psksecret ENC xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    next
    edit "HomeVPNv6-IKE2"
        set type dynamic
        set interface "wan1"
        set ip-version 6
        set ike-version 2
        set peertype dialup
        set net-device disable
        set mode-cfg enable
        set proposal aes256gcm-prfsha512 aes256gcm-prfsha384
        set dpd on-idle
        set dhgrp 31
        set usrgrp "IPsec-Admin"
        set ipv4-start-ip 10.10.30.20
        set ipv4-end-ip 10.10.30.255
        set ipv4-netmask 255.255.255.0
        set dns-mode auto
        set ipv6-start-ip 2002:db7::11
        set ipv6-end-ip 2002:db7::20
        set dpd-retryinterval 60
    next
end
```

### 5I.) - config vpn ipsec phase1-interface
Configure the phase 2 interfaces for the three different IPsec tunnels

```
config vpn ipsec phase2-interface
    edit "HomeVPN-IPsec"
        set phase1name "HomeVPN-IPsec"
        set proposal aes128-sha1 aes256-sha1 aes128-sha256 aes256-sha256 aes128gcm aes256gcm chacha20poly1305
    next
    edit "HomeVPN-IPsec_IPv6"
        set phase1name "HomeVPN-IPsec"
        set proposal aes128-sha1 aes256-sha1 aes128-sha256 aes256-sha256 aes128gcm aes256gcm chacha20poly1305
        set dhgrp 5
        set src-addr-type subnet6
        set dst-addr-type subnet6
    next
    edit "HomeVPNv6"
        set phase1name "HomeVPNv6"
        set proposal aes128-sha1 aes256-sha384 aes256-sha256
        set dhgrp 14
    next
    edit "HomeVPNv6_IPv6"
        set phase1name "HomeVPNv6"
        set proposal aes128-sha1 aes256-sha384 aes256-sha256
        set dhgrp 14
        set src-addr-type subnet6
        set dst-addr-type subnet6
    next
    edit "HomeVPNv4-IKE2"
        set phase1name "HomeVPNv6-IKE2"
        set proposal aes256-sha384 aes256-sha512
        set dhgrp 31
    next
    edit "HomeVPNv6-IKE2"
        set phase1name "HomeVPNv6-IKE2"
        set proposal aes256-sha512 aes256-sha384
        set dhgrp 31
        set src-addr-type subnet6
        set dst-addr-type subnet6
    next
end
```

### 5J.) - config system dns-server

Configure DNS servers and our security profile
```
config system dns-server
    edit "HomeVPN-IPsec"
        set mode forward-only
        set dnsfilter-profile "Your_DNS_filter_profile"
        set doh enable
    next
    edit "HomeVPNv6"
        set mode forward-only
        set dnsfilter-profile "Your_DNS_filter_profile"
        set doh enable
    next
    edit "HomeVPNv6-IKE2"
        set mode forward-only
        set dnsfilter-profile "Your_DNS_filter_profile"
        set doh enable
    next
end
```

### 5K.) - config firewall address
here we configure the IPv4 address range allowed to be used by the IP sec tunnels and we define countries we are blocking

```
config firewall address
	edit "HomeVPN-IPsec_range"
        set type iprange
        set start-ip 10.10.30.1
        set end-ip 10.10.30.255
    next
    edit "VPN_Block_China"
        set type geography
        set country "CN"
    next
    edit "VPN_Block_Russia"
        set type geography
        set country "RU"
    next
    edit "VPN_Block_Bangladesh"
        set type geography
        set country "BD"
    next
    edit "VPN_Block_Czech_Republic"
        set type geography
        set country "CZ"
    next
    edit "VPN_Block_Hong_Kong"
        set type geography
        set country "HK"
    next
    edit "VPN_Block_Indonesia"
        set type geography
        set country "ID"
    next
    edit "VPN_Block_Korea1"
        set type geography
        set country "KP"
    next
    edit "VPN_Block_Korea2"
        set type geography
        set country "KR"
    next
    edit "VPN_Block_Afganistan"
        set type geography
        set country "AF"
    next
    edit "VPN_Block_Aland_Islands"
        set type geography
        set country "AX"
    next
    edit "VPN_Block_Albania"
        set type geography
        set country "AL"
    next
    edit "VPN_Block_Algeria"
        set type geography
        set country "DZ"
    next
    edit "VPN_Block_Austrialia"
        set type geography
        set country "AU"
    next
    edit "VPN_Block_Austria"
        set type geography
        set country "AT"
    next
    edit "VPN_Block_Belgium"
        set type geography
        set country "BE"
    next
    edit "VPN_Block_Belize"
        set type geography
        set country "BZ"
    next
    edit "VPN_Block_Brazil"
        set type geography
        set country "BR"
    next
    edit "VPN_Block_Cambodia"
        set type geography
        set country "KH"
    next
    edit "VPN_Block_Canada"
        set type geography
        set country "CA"
    next
    edit "VPN_Block_Denmark"
        set type geography
        set country "DK"
    next
    edit "VPN_Block_France"
        set type geography
        set country "FR"
    next
    edit "VPN_Block_Germany"
        set type geography
        set country "DE"
    next
    edit "VPN_Block_Greece"
        set type geography
        set country "GR"
    next
    edit "VPN_Block_Hungary"
        set type geography
        set country "HU"
    next
    edit "VPN_Block_India"
        set type geography
        set country "IN"
    next
    edit "VPN_Block_Iran"
        set type geography
        set country "IR"
    next
    edit "VPN_Block_Iraq"
        set type geography
        set country "IQ"
    next
    edit "VPN_Block_Ireland"
        set type geography
        set country "IE"
    next
    edit "VPN_Block_Isreal"
        set type geography
        set country "IL"
    next
    edit "VPN_Block_Italy"
        set type geography
        set country "IT"
    next
    edit "VPN_Block_Japan"
        set type geography
        set country "JP"
    next
    edit "VPN_Block_Liberia"
        set type geography
        set country "LR"
    next
    edit "VPN_Block_Luxembourg"
        set type geography
        set country "LU"
    next
    edit "VPN_Block_Malaysia"
        set type geography
        set country "MY"
    next
    edit "VPN_Block_Mexico"
        set type geography
        set country "MX"
    next
    edit "VPN_Block_Singapore"
        set type geography
        set country "SG"
    next
    edit "VPN_Block_Spain"
        set type geography
        set country "ES"
    next
    edit "VPN_Block_Sweeden"
        set type geography
        set country "SE"
    next
    edit "VPN_Block_Switzerland"
        set type geography
        set country "CH"
    next
    edit "VPN_Block_Taiwan"
        set type geography
        set country "TW"
    next
    edit "VPN_Block_United_Kingdom"
        set type geography
        set country "GB"
    next
    edit "VPN_Block_Netherlands"
        set type geography
        set country "NL"
    next
    edit "VPN_Block_Netherlands_Antilles"
        set type geography
        set country "AN"
    next
    edit "VPN_Block_American_Aamoa"
        set type geography
        set country "AS"
    next
    edit "VPN_Block_Andorra"
        set type geography
        set country "AD"
    next
    edit "VPN_Block_Angola"
        set type geography
        set country "AO"
    next
    edit "VPN_Block_Anguilla"
        set type geography
        set country "AI"
    next
    edit "VPN_Block_Antigua_Barbuda"
        set type geography
        set country "AG"
    next
    edit "VPN_Block_Argentina"
        set type geography
        set country "AR"
    next
    edit "VPN_Block_Armenia"
        set type geography
        set country "AM"
    next
    edit "VPN_Block_Aruba"
        set type geography
        set country "AW"
    next
    edit "VPN_Block_Azerbaijan"
        set type geography
        set country "AZ"
    next
    edit "VPN_Block_Bahamas"
        set type geography
        set country "BS"
    next
    edit "VPN_Block_Bahrain"
        set type geography
        set country "BH"
    next
    edit "VPN_Block_Barbados"
        set type geography
        set country "BB"
    next
    edit "VPN_Block_Belarus"
        set type geography
        set country "BY"
    next
    edit "VPN_Block_Benin"
        set type geography
        set country "BJ"
    next
    edit "VPN_Block_Bermuda"
        set type geography
        set country "BM"
    next
    edit "VPN_Block_Bhutan"
        set type geography
        set country "BT"
    next
    edit "VPN_Block_Bolvia"
        set type geography
        set country "BO"
    next
    edit "VPN_Block_Bosnia_Herzegovia"
        set type geography
        set country "BA"
    next
    edit "VPN_Block_Botswana"
        set type geography
        set country "BW"
    next
    edit "VPN_Block_Bouvet_Island"
        set type geography
        set country "BV"
    next
    edit "VPN_Block_British_Indian_ocean_terr"
        set type geography
        set country "IO"
    next
    edit "VPN_Block_Brunei_Darussalam"
        set type geography
        set country "BN"
    next
    edit "VPN_Block_Bulgaria"
        set type geography
        set country "BG"
    next
    edit "VPN_Block_Burkina_Faso"
        set type geography
        set country "BF"
    next
    edit "VPN_Block_Burundi"
        set type geography
        set country "BI"
    next
    edit "VPN_Block_Cameroon"
        set type geography
        set country "CM"
    next
    edit "VPN_Block_Cape_Verde"
        set type geography
        set country "CV"
    next
    edit "VPN_Block_Cayman_Islands"
        set type geography
        set country "KY"
    next
    edit "VPN_Block_Central_African_Republic"
        set type geography
        set country "CF"
    next
    edit "VPN_Block_Chad"
        set type geography
        set country "TD"
    next
    edit "VPN_Block_Chile"
        set type geography
        set country "CL"
    next
    edit "VPN_Block_Christams_Island"
        set type geography
        set country "CX"
    next
    edit "VPN_Block_Columbia"
        set type geography
        set country "CO"
    next
    edit "VPN_Block_Comonros"
        set type geography
        set country "KM"
    next
    edit "VPN_Block_Congo"
        set type geography
        set country "CG"
    next
    edit "VPN_Block_Congo_Replibic"
        set type geography
        set country "CD"
    next
    edit "VPN_Block_Cook_Islands"
        set type geography
        set country "CK"
    next
    edit "VPN_Block_Costa_Rica"
        set type geography
        set country "CR"
    next
    edit "VPN_Block_Cote_Dlvoire"
        set type geography
        set country "CI"
    next
    edit "VPN_Block_Croatia"
        set type geography
        set country "HR"
    next
    edit "VPN_Block_Cuba"
        set type geography
        set country "CU"
    next
    edit "VPN_Block_Curacao"
        set type geography
        set country "CW"
    next
    edit "VPN_Block_Djibouti"
        set type geography
        set country "DJ"
    next
    edit "VPN_Block_Dominica"
        set type geography
        set country "DM"
    next
    edit "VPN_Block_Dominican_Replublic"
        set type geography
        set country "DO"
    next
    edit "VPN_Block_Ecuador"
        set type geography
        set country "EC"
    next
    edit "VPN_Block_Egypt"
        set type geography
        set country "EG"
    next
    edit "VPN_Block_El_Salvador"
        set type geography
        set country "SV"
    next
    edit "VPN_Block_Equatorial_Guinea"
        set type geography
        set country "GQ"
    next
    edit "VPN_Block_Eritrea"
        set type geography
        set country "ER"
    next
    edit "VPN_Block_Estonia"
        set type geography
        set country "EE"
    next
    edit "VPN_Block_Ethiopia"
        set type geography
        set country "ET"
    next
    edit "VPN_Block_Falkland_Islands"
        set type geography
        set country "FK"
    next
    edit "VPN_Block_Faroe_Islands"
        set type geography
        set country "FO"
    next
    edit "VPN_Block_Fiji"
        set type geography
        set country "FJ"
    next
    edit "VPN_Block_Finland"
        set type geography
        set country "FI"
    next
    edit "VPN_Block_French_Guiana"
        set type geography
        set country "GF"
    next
    edit "VPN_Block_French_Polnesia"
        set type geography
        set country "PF"
    next
    edit "VPN_Block_FST"
        set type geography
        set country "TF"
    next
    edit "VPN_Block_Gabon"
        set type geography
        set country "GA"
    next
    edit "VPN_Block_Gambia"
        set type geography
        set country "GM"
    next
    edit "VPN_Block_Georgia"
        set type geography
        set country "GE"
    next
    edit "VPN_Block_Ghana"
        set type geography
        set country "GH"
    next
    edit "VPN_Block_Gibraltar"
        set type geography
        set country "GI"
    next
    edit "VPN_Block_Greenland"
        set type geography
        set country "GL"
    next
    edit "VPN_Block_Grenada"
        set type geography
        set country "GD"
    next
    edit "VPN_Block_Guadeloupe"
        set type geography
        set country "GP"
    next
    edit "VPN_Block_Palestinain_Territory"
        set type geography
        set country "PS"
    next
    edit "VPN_Block_guam"
        set type geography
        set country "GU"
    next
    edit "VPN_Block_Guatemala"
        set type geography
        set country "GT"
    next
    edit "VPN_Block_Guerney"
        set type geography
        set country "GG"
    next
    edit "VPN_Block_Guinea"
        set type geography
        set country "GN"
    next
    edit "VPN_Block_Ginea-Bissau"
        set type geography
        set country "GW"
    next
    edit "VPN_Block_Guyana"
        set type geography
        set country "GY"
    next
    edit "VPN_Block_Haiti"
        set type geography
        set country "HT"
    next
    edit "VPN_Block_Heard_Islands"
        set type geography
        set country "HM"
    next
    edit "VPN_Block_Holy_See"
        set type geography
        set country "VA"
    next
    edit "VPN_Block_Honduras"
        set type geography
        set country "HN"
    next
    edit "VPN_Block_Iceland"
        set type geography
        set country "IS"
    next
    edit "VPN_Block_Isle_of_man"
        set type geography
        set country "IM"
    next
    edit "VPN_Block_Jamacia"
        set type geography
        set country "JM"
    next
    edit "VPN_Block_Jersey"
        set type geography
        set country "JE"
    next
    edit "VPN_Block_Jordan"
        set type geography
        set country "JO"
    next
    edit "VPN_Block_Kazakhstan"
        set type geography
        set country "KZ"
    next
    edit "VPN_Block_Kenya"
        set type geography
        set country "KE"
    next
    edit "VPN_Block_Kiribati"
        set type geography
        set country "KI"
    next
    edit "VPN_Block_Korea"
        set type geography
        set country "KP"
    next
    edit "VPN_Block_Kosovo"
        set type geography
        set country "XK"
    next
    edit "VPN_Block_Kuwait"
        set type geography
        set country "KW"
    next
    edit "VPN_Block_Kyrgyzstan"
        set type geography
        set country "KG"
    next
    edit "VPN_Block_Lao"
        set type geography
        set country "LA"
    next
    edit "VPN_Block_Latvia"
        set type geography
        set country "LV"
    next
    edit "VPN_Block_Lebanon"
        set type geography
        set country "LB"
    next
    edit "VPN_Block_Lesotho"
        set type geography
        set country "LS"
    next
    edit "VPN_Block_Libyan"
        set type geography
        set country "LY"
    next
    edit "VPN_Block_Liechtenstein"
        set type geography
        set country "LI"
    next
    edit "VPN_Block_Lithuania"
        set type geography
        set country "LT"
    next
    edit "VPN_Block_Macao"
        set type geography
        set country "MO"
    next
    edit "VPN_Block_Macedonia"
        set type geography
        set country "MK"
    next
    edit "VPN_Block_Madagascar"
        set type geography
        set country "MG"
    next
    edit "VPN_Block_Malawi"
        set type geography
        set country "MW"
    next
    edit "VPN_Block_Maldives"
        set type geography
        set country "MV"
    next
    edit "VPN_Block_Mali"
        set type geography
        set country "ML"
    next
    edit "VPN_Block_Malta"
        set type geography
        set country "MT"
    next
    edit "VPN_Block_Marshall_Islands"
        set type geography
        set country "MH"
    next
    edit "VPN_Block_Martinique"
        set type geography
        set country "MQ"
    next
    edit "VPN_Block_Mauritania"
        set type geography
        set country "MR"
    next
    edit "VPN_Block_Mauritius"
        set type geography
        set country "MU"
    next
    edit "VPN_Block_Mayotte"
        set type geography
        set country "YT"
    next
    edit "VPN_Block_Micronedia"
        set type geography
        set country "FM"
    next
    edit "VPN_Block_Moldova"
        set type geography
        set country "MD"
    next
    edit "VPN_Block_Monaco"
        set type geography
        set country "MC"
    next
    edit "VPN_Block_Mongolia"
        set type geography
        set country "MN"
    next
    edit "VPN_Block_Montenergo"
        set type geography
        set country "ME"
    next
    edit "VPN_Block_Montserrat"
        set type geography
        set country "MS"
    next
    edit "VPN_Block_Morocco"
        set type geography
        set country "MA"
    next
    edit "VPN_Block_Mozambique"
        set type geography
        set country "MZ"
    next
    edit "VPN_Block_Myanmar"
        set type geography
        set country "MM"
    next
    edit "VPN_Block_Turkey"
        set type geography
        set country "TR"
    next
    edit "VPN_Block_Cyprus"
        set type geography
        set country "CY"
    next
    edit "VPN_Block_Namibia"
        set type geography
        set country "NA"
    next
    edit "VPN_Block_Nauru"
        set type geography
        set country "NR"
    next
    edit "VPN_Block_Nepal"
        set type geography
        set country "NP"
    next
    edit "VPN_Block_New_Caledonia"
        set type geography
        set country "NC"
    next
    edit "VPN_Block_New_Zealand"
        set type geography
        set country "NZ"
    next
    edit "VPN_Block_Nicaragua"
        set type geography
        set country "NI"
    next
    edit "VPN_Block_Niger"
        set type geography
        set country "NE"
    next
    edit "VPN_Block_Nigeria"
        set type geography
        set country "NG"
    next
    edit "VPN_Block_Norway"
        set type geography
        set country "NO"
    next
    edit "VPN_Block_Pakistan"
        set type geography
        set country "PK"
    next
    edit "VPN_Block_Panama"
        set type geography
        set country "PA"
    next
    edit "VPN_Block_Paraguay"
        set type geography
        set country "PY"
    next
    edit "VPN_Block_Peru"
        set type geography
        set country "PE"
    next
    edit "VPN_Block_Philippines"
        set type geography
        set country "PH"
    next
    edit "VPN_Block_Poland"
        set type geography
        set country "PL"
    next
    edit "VPN_Block_Portugal"
        set type geography
        set country "PT"
    next
    edit "VPN_Block_Puerto_rico"
        set type geography
        set country "PR"
    next
    edit "VPN_Block_Reunion"
        set type geography
        set country "RE"
    next
    edit "VPN_Block_Romania"
        set type geography
        set country "RO"
    next
    edit "VPN_Block_Samoa"
        set type geography
        set country "WS"
    next
    edit "VPN_Block_Saudi_Arabia"
        set type geography
        set country "SA"
    next
    edit "VPN_Block_Serbia"
        set type geography
        set country "RS"
    next
    edit "VPN_Block_Slovakia"
        set type geography
        set country "SK"
    next
    edit "VPN_Block_Slovenia"
        set type geography
        set country "SI"
    next
    edit "VPN_Block_Somalia"
        set type geography
        set country "SO"
    next
    edit "VPN_Block_South_Africa"
        set type geography
        set country "ZA"
    next
    edit "VPN_Block_Sudan"
        set type geography
        set country "SD"
    next
    edit "VPN_Block_Syrian_arab_republic"
        set type geography
        set country "SY"
    next
    edit "VPN_Block_Thailand"
        set type geography
        set country "TH"
    next
    edit "VPN_Block_Turks_and_cacios"
        set type geography
        set country "TC"
    next
    edit "VPN_Block_Ukraine"
        set type geography
        set country "UA"
    next
    edit "VPN_Block_United_Arab_Emirates"
        set type geography
        set country "AE"
    next
    edit "VPN_Block_Uruguay"
        set type geography
        set country "UY"
    next
    edit "VPN_Block_Venezuela"
        set type geography
        set country "VE"
    next
    edit "VPN_Block_Vietnam"
        set type geography
        set country "VN"
    next
    edit "VPN_Block_Virgin_islands_british"
        set type geography
        set country "VG"
    next
    edit "USA"
        set type geography
        set country "US"
    next
    edit "VPN_Block_205.210.31.169"
        set subnet 205.210.31.169 255.255.255.255
end
```

### 5L.) - config firewall address6
here we configure the IPv6 address range allowed to be used by the IP sec tunnels and we define countries we are blocking

```
config firewall address6
	edit "HomeVPN-IPsec_range"
        set type iprange
        set start-ip 2002:db7::1
        set end-ip 2002:db7::20
    next
    edit "USA"
        set type geography
        set country "US"
    next
    edit "VPN_Block_2a01:4ff:f0:a387::1"
        set type iprange
        set start-ip 2a01:4ff:f0:a387::1
        set end-ip 2a01:4ff:f0:a387::1
    next
    edit "VPN_Block_Afganistan"
        set type geography
        set country "AF"
    next
    edit "VPN_Block_Aland_Islands"
        set type geography
        set country "AX"
    next
    edit "VPN_Block_Albania"
        set type geography
        set country "AL"
    next
    edit "VPN_Block_Algeria"
        set type geography
        set country "DZ"
    next
    edit "VPN_Block_American_Aamoa"
        set type geography
        set country "AS"
    next
    edit "VPN_Block_Andorra"
        set type geography
        set country "AD"
    next
    edit "VPN_Block_Angola"
        set type geography
        set country "AO"
    next
    edit "VPN_Block_Anguilla"
        set type geography
        set country "AI"
    next
    edit "VPN_Block_Antigua_Barbuda"
        set type geography
        set country "AG"
    next
    edit "VPN_Block_Argentina"
        set type geography
        set country "AR"
    next
    edit "VPN_Block_China"
        set type geography
        set country "CN"
    next
    edit "VPN_Block_Russia"
        set type geography
        set country "RU"
    next
    edit "VPN_Block_Bangladesh"
        set type geography
        set country "BD"
    next
    edit "VPN_Block_Czech_Republic"
        set type geography
        set country "CZ"
    next
    edit "VPN_Block_Hong_Kong"
        set type geography
        set country "HK"
    next
    edit "VPN_Block_Indonesia"
        set type geography
        set country "ID"
    next
    edit "VPN_Block_Korea1"
        set type geography
        set country "KP"
    next
    edit "VPN_Block_Korea2"
        set type geography
        set country "KR"
    next
    edit "VPN_Block_Austrialia"
        set type geography
        set country "AU"
    next
    edit "VPN_Block_Austria"
        set type geography
        set country "AT"
    next
    edit "VPN_Block_Belgium"
        set type geography
        set country "BE"
    next
    edit "VPN_Block_Belize"
        set type geography
        set country "BZ"
    next
    edit "VPN_Block_Brazil"
        set type geography
        set country "BR"
    next
    edit "VPN_Block_Cambodia"
        set type geography
        set country "KH"
    next
    edit "VPN_Block_Canada"
        set type geography
        set country "CA"
    next
    edit "VPN_Block_Denmark"
        set type geography
        set country "DK"
    next
    edit "VPN_Block_France"
        set type geography
        set country "FR"
    next
    edit "VPN_Block_Germany"
        set type geography
        set country "DE"
    next
    edit "VPN_Block_Greece"
        set type geography
        set country "GR"
    next
    edit "VPN_Block_Hungary"
        set type geography
        set country "HU"
    next
    edit "VPN_Block_India"
        set type geography
        set country "IN"
    next
    edit "VPN_Block_Iran"
        set type geography
        set country "IR"
    next
    edit "VPN_Block_Iraq"
        set type geography
        set country "IQ"
    next
    edit "VPN_Block_Ireland"
        set type geography
        set country "IE"
    next
    edit "VPN_Block_Isreal"
        set type geography
        set country "IL"
    next
    edit "VPN_Block_Italy"
        set type geography
        set country "IT"
    next
    edit "VPN_Block_Japan"
        set type geography
        set country "JP"
    next
    edit "VPN_Block_Liberia"
        set type geography
        set country "LR"
    next
    edit "VPN_Block_Luxembourg"
        set type geography
        set country "LU"
    next
    edit "VPN_Block_Malaysia"
        set type geography
        set country "MY"
    next
    edit "VPN_Block_Mexico"
        set type geography
        set country "MX"
    next
    edit "VPN_Block_Singapore"
        set type geography
        set country "SG"
    next
    edit "VPN_Block_Spain"
        set type geography
        set country "ES"
    next
    edit "VPN_Block_Sweeden"
        set type geography
        set country "SE"
    next
    edit "VPN_Block_Switzerland"
        set type geography
        set country "CH"
    next
    edit "VPN_Block_Taiwan"
        set type geography
        set country "TW"
    next
    edit "VPN_Block_United_Kingdom"
        set type geography
        set country "GB"
    next
    edit "VPN_Block_Netherlands"
        set type geography
        set country "NL"
    next
    edit "VPN_Block_Netherlands_Antilles"
        set type geography
        set country "AN"
    next
    edit "VPN_Block_Armenia"
        set type geography
        set country "AM"
    next
    edit "VPN_Block_Aruba"
        set type geography
        set country "AW"
    next
    edit "VPN_Block_Azerbaijan"
        set type geography
        set country "AZ"
    next
    edit "VPN_Block_Bahamas"
        set type geography
        set country "BS"
    next
    edit "VPN_Block_Bahrain"
        set type geography
        set country "BH"
    next
    edit "VPN_Block_Barbados"
        set type geography
        set country "BB"
    next
    edit "VPN_Block_Belarus"
        set type geography
        set country "BY"
    next
    edit "VPN_Block_Benin"
        set type geography
        set country "BJ"
    next
    edit "VPN_Block_Bermuda"
        set type geography
        set country "BM"
    next
    edit "VPN_Block_Bhutan"
        set type geography
        set country "BT"
    next
    edit "VPN_Block_Bolvia"
        set type geography
        set country "BO"
    next
    edit "VPN_Block_Bosnia_Herzegovia"
        set type geography
        set country "BA"
    next
    edit "VPN_Block_Botswana"
        set type geography
        set country "BW"
    next
    edit "VPN_Block_Bouvet_Island"
        set type geography
        set country "BV"
    next
    edit "VPN_Block_British_Indian_ocean_terr"
        set type geography
        set country "IO"
    next
    edit "VPN_Block_Brunei_Darussalam"
        set type geography
        set country "BN"
    next
    edit "VPN_Block_Bulgaria"
        set type geography
        set country "BG"
    next
    edit "VPN_Block_Burkina_Faso"
        set type geography
        set country "BF"
    next
    edit "VPN_Block_Burundi"
        set type geography
        set country "BI"
    next
    edit "VPN_Block_Cameroon"
        set type geography
        set country "CM"
    next
    edit "VPN_Block_Cape_Verde"
        set type geography
        set country "CV"
    next
    edit "VPN_Block_Cayman_Islands"
        set type geography
        set country "KY"
    next
    edit "VPN_Block_Central_African_Republic"
        set type geography
        set country "CF"
    next
    edit "VPN_Block_Chad"
        set type geography
        set country "TD"
    next
    edit "VPN_Block_Chile"
        set type geography
        set country "CL"
    next
    edit "VPN_Block_Christams_Island"
        set type geography
        set country "CX"
    next
    edit "VPN_Block_Columbia"
        set type geography
        set country "CO"
    next
    edit "VPN_Block_Comonros"
        set type geography
        set country "KM"
    next
    edit "VPN_Block_Congo"
        set type geography
        set country "CG"
    next
    edit "VPN_Block_Congo_Replibic"
        set type geography
        set country "CD"
    next
    edit "VPN_Block_Cook_Islands"
        set type geography
        set country "CK"
    next
    edit "VPN_Block_Costa_Rica"
        set type geography
        set country "CR"
    next
    edit "VPN_Block_Cote_Dlvoire"
        set type geography
        set country "CI"
    next
    edit "VPN_Block_Croatia"
        set type geography
        set country "HR"
    next
    edit "VPN_Block_Cuba"
        set type geography
        set country "CU"
    next
    edit "VPN_Block_Curacao"
        set type geography
        set country "CW"
    next
    edit "VPN_Block_Djibouti"
        set type geography
        set country "DJ"
    next
    edit "VPN_Block_Dominica"
        set type geography
        set country "DM"
    next
    edit "VPN_Block_Dominican_Replublic"
        set type geography
        set country "DO"
    next
    edit "VPN_Block_Ecuador"
        set type geography
        set country "EC"
    next
    edit "VPN_Block_Egypt"
        set type geography
        set country "EG"
    next
    edit "VPN_Block_El_Salvador"
        set type geography
        set country "SV"
    next
    edit "VPN_Block_Equatorial_Guinea"
        set type geography
        set country "GQ"
    next
    edit "VPN_Block_Eritrea"
        set type geography
        set country "ER"
    next
    edit "VPN_Block_Estonia"
        set type geography
        set country "EE"
    next
    edit "VPN_Block_Ethiopia"
        set type geography
        set country "ET"
    next
    edit "VPN_Block_Falkland_Islands"
        set type geography
        set country "FK"
    next
    edit "VPN_Block_Faroe_Islands"
        set type geography
        set country "FO"
    next
    edit "VPN_Block_Fiji"
        set type geography
        set country "FJ"
    next
    edit "VPN_Block_Finland"
        set type geography
        set country "FI"
    next
    edit "VPN_Block_French_Guiana"
        set type geography
        set country "GF"
    next
    edit "VPN_Block_French_Polnesia"
        set type geography
        set country "PF"
    next
    edit "VPN_Block_FST"
        set type geography
        set country "TF"
    next
    edit "VPN_Block_Gabon"
        set type geography
        set country "GA"
    next
    edit "VPN_Block_Gambia"
        set type geography
        set country "GM"
    next
    edit "VPN_Block_Georgia"
        set type geography
        set country "GE"
    next
    edit "VPN_Block_Ghana"
        set type geography
        set country "GH"
    next
    edit "VPN_Block_Gibraltar"
        set type geography
        set country "GI"
    next
    edit "VPN_Block_Greenland"
        set type geography
        set country "GL"
    next
    edit "VPN_Block_Grenada"
        set type geography
        set country "GD"
    next
    edit "VPN_Block_Guadeloupe"
        set type geography
        set country "GP"
    next
    edit "VPN_Block_Palestinain_Territory"
        set type geography
        set country "PS"
    next
    edit "VPN_Block_guam"
        set type geography
        set country "GU"
    next
    edit "VPN_Block_Guatemala"
        set type geography
        set country "GT"
    next
    edit "VPN_Block_Guerney"
        set type geography
        set country "GG"
    next
    edit "VPN_Block_Guinea"
        set type geography
        set country "GN"
    next
    edit "VPN_Block_Ginea-Bissau"
        set type geography
        set country "GW"
    next
    edit "VPN_Block_Guyana"
        set type geography
        set country "GY"
    next
    edit "VPN_Block_Haiti"
        set type geography
        set country "HT"
    next
    edit "VPN_Block_Heard_Islands"
        set type geography
        set country "HM"
    next
    edit "VPN_Block_Holy_See"
        set type geography
        set country "VA"
    next
    edit "VPN_Block_Honduras"
        set type geography
        set country "HN"
    next
    edit "VPN_Block_Iceland"
        set type geography
        set country "IS"
    next
    edit "VPN_Block_Isle_of_man"
        set type geography
        set country "IM"
    next
    edit "VPN_Block_Jamacia"
        set type geography
        set country "JM"
    next
    edit "VPN_Block_Jersey"
        set type geography
        set country "JE"
    next
    edit "VPN_Block_Jordan"
        set type geography
        set country "JO"
    next
    edit "VPN_Block_Kazakhstan"
        set type geography
        set country "KZ"
    next
    edit "VPN_Block_Kenya"
        set type geography
        set country "KE"
    next
    edit "VPN_Block_Kiribati"
        set type geography
        set country "KI"
    next
    edit "VPN_Block_Korea"
        set type geography
        set country "KP"
    next
    edit "VPN_Block_Kosovo"
        set type geography
        set country "XK"
    next
    edit "VPN_Block_Kuwait"
        set type geography
        set country "KW"
    next
    edit "VPN_Block_Kyrgyzstan"
        set type geography
        set country "KG"
    next
    edit "VPN_Block_Lao"
        set type geography
        set country "LA"
    next
    edit "VPN_Block_Latvia"
        set type geography
        set country "LV"
    next
    edit "VPN_Block_Lebanon"
        set type geography
        set country "LB"
    next
    edit "VPN_Block_Lesotho"
        set type geography
        set country "LS"
    next
    edit "VPN_Block_Libyan"
        set type geography
        set country "LY"
    next
    edit "VPN_Block_Liechtenstein"
        set type geography
        set country "LI"
    next
    edit "VPN_Block_Lithuania"
        set type geography
        set country "LT"
    next
    edit "VPN_Block_Macao"
        set type geography
        set country "MO"
    next
    edit "VPN_Block_Macedonia"
        set type geography
        set country "MK"
    next
    edit "VPN_Block_Madagascar"
        set type geography
        set country "MG"
    next
    edit "VPN_Block_Malawi"
        set type geography
        set country "MW"
    next
    edit "VPN_Block_Maldives"
        set type geography
        set country "MV"
    next
    edit "VPN_Block_Mali"
        set type geography
        set country "ML"
    next
    edit "VPN_Block_Malta"
        set type geography
        set country "MT"
    next
    edit "VPN_Block_Marshall_Islands"
        set type geography
        set country "MH"
    next
    edit "VPN_Block_Martinique"
        set type geography
        set country "MQ"
    next
    edit "VPN_Block_Mauritania"
        set type geography
        set country "MR"
    next
    edit "VPN_Block_Mauritius"
        set type geography
        set country "MU"
    next
    edit "VPN_Block_Mayotte"
        set type geography
        set country "YT"
    next
    edit "VPN_Block_Micronedia"
        set type geography
        set country "FM"
    next
    edit "VPN_Block_Moldova"
        set type geography
        set country "MD"
    next
    edit "VPN_Block_Monaco"
        set type geography
        set country "MC"
    next
    edit "VPN_Block_Mongolia"
        set type geography
        set country "MN"
    next
    edit "VPN_Block_Montenergo"
        set type geography
        set country "ME"
    next
    edit "VPN_Block_Montserrat"
        set type geography
        set country "MS"
    next
    edit "VPN_Block_Morocco"
        set type geography
        set country "MA"
    next
    edit "VPN_Block_Mozambique"
        set type geography
        set country "MZ"
    next
    edit "VPN_Block_Myanmar"
        set type geography
        set country "MM"
    next
    edit "VPN_Block_Turkey"
        set type geography
        set country "TR"
    next
    edit "VPN_Block_Cyprus"
        set type geography
        set country "CY"
    next
    edit "VPN_Block_Namibia"
        set type geography
        set country "NA"
    next
    edit "VPN_Block_Nauru"
        set type geography
        set country "NR"
    next
    edit "VPN_Block_Nepal"
        set type geography
        set country "NP"
    next
    edit "VPN_Block_New_Caledonia"
        set type geography
        set country "NC"
    next
    edit "VPN_Block_New_Zealand"
        set type geography
        set country "NZ"
    next
    edit "VPN_Block_Nicaragua"
        set type geography
        set country "NI"
    next
    edit "VPN_Block_Niger"
        set type geography
        set country "NE"
    next
    edit "VPN_Block_Nigeria"
        set type geography
        set country "NG"
    next
    edit "VPN_Block_Norway"
        set type geography
        set country "NO"
    next
    edit "VPN_Block_Pakistan"
        set type geography
        set country "PK"
    next
    edit "VPN_Block_Panama"
        set type geography
        set country "PA"
    next
    edit "VPN_Block_Paraguay"
        set type geography
        set country "PY"
    next
    edit "VPN_Block_Peru"
        set type geography
        set country "PE"
    next
    edit "VPN_Block_Philippines"
        set type geography
        set country "PH"
    next
    edit "VPN_Block_Poland"
        set type geography
        set country "PL"
    next
    edit "VPN_Block_Portugal"
        set type geography
        set country "PT"
    next
    edit "VPN_Block_Puerto_rico"
        set type geography
        set country "PR"
    next
    edit "VPN_Block_Reunion"
        set type geography
        set country "RE"
    next
    edit "VPN_Block_Romania"
        set type geography
        set country "RO"
    next
    edit "VPN_Block_Samoa"
        set type geography
        set country "WS"
    next
    edit "VPN_Block_Saudi_Arabia"
        set type geography
        set country "SA"
    next
    edit "VPN_Block_Serbia"
        set type geography
        set country "RS"
    next
    edit "VPN_Block_Slovakia"
        set type geography
        set country "SK"
    next
    edit "VPN_Block_Slovenia"
        set type geography
        set country "SI"
    next
    edit "VPN_Block_Somalia"
        set type geography
        set country "SO"
    next
    edit "VPN_Block_South_Africa"
        set type geography
        set country "ZA"
    next
    edit "VPN_Block_Sudan"
        set type geography
        set country "SD"
    next
    edit "VPN_Block_Syrian_arab_republic"
        set type geography
        set country "SY"
    next
    edit "VPN_Block_Thailand"
        set type geography
        set country "TH"
    next
    edit "VPN_Block_Turks_and_cacios"
        set type geography
        set country "TC"
    next
    edit "VPN_Block_Ukraine"
        set type geography
        set country "UA"
    next
    edit "VPN_Block_United_Arab_Emirates"
        set type geography
        set country "AE"
    next
    edit "VPN_Block_Uruguay"
        set type geography
        set country "UY"
    next
    edit "VPN_Block_Venezuela"
        set type geography
        set country "VE"
    next
    edit "VPN_Block_Vietnam"
        set type geography
        set country "VN"
    next
    edit "VPN_Block_Virgin_islands_british"
        set type geography
        set country "VG"
    next
end
```

### 5M.) - config firewall address6
define our IPv4 address groups, one for the geography, and one used by the auto block stitches

```
config firewall addrgrp
    edit "VPN_Block_Geography"
        set member "VPN_Block_Bangladesh" "VPN_Block_China" "VPN_Block_Russia" "VPN_Block_Czech_Republic" "VPN_Block_Hong_Kong" "VPN_Block_Indonesia" "VPN_Block_Korea1" "VPN_Block_Korea2" "VPN_Block_Afganistan" "VPN_Block_Aland_Islands" "VPN_Block_Albania" "VPN_Block_Algeria" "VPN_Block_Austria" "VPN_Block_Austrialia" "VPN_Block_Belgium" "VPN_Block_Belize" "VPN_Block_Brazil" "VPN_Block_Cambodia" "VPN_Block_Canada" "VPN_Block_Denmark" "VPN_Block_France" "VPN_Block_Germany" "VPN_Block_Greece" "VPN_Block_Hungary" "VPN_Block_India" "VPN_Block_Iran" "VPN_Block_Iraq" "VPN_Block_Ireland" "VPN_Block_Isreal" "VPN_Block_Italy" "VPN_Block_Japan" "VPN_Block_Liberia" "VPN_Block_Luxembourg" "VPN_Block_Malaysia" "VPN_Block_Mexico" "VPN_Block_Singapore" "VPN_Block_Spain" "VPN_Block_Sweeden" "VPN_Block_Switzerland" "VPN_Block_Taiwan" "VPN_Block_United_Kingdom" "VPN_Block_American_Aamoa" "VPN_Block_Andorra" "VPN_Block_Angola" "VPN_Block_Anguilla" "VPN_Block_Antigua_Barbuda" "VPN_Block_Argentina" "VPN_Block_Armenia" "VPN_Block_Aruba" "VPN_Block_Azerbaijan" "VPN_Block_Bahamas" "VPN_Block_Bahrain" "VPN_Block_Barbados" "VPN_Block_Belarus" "VPN_Block_Benin" "VPN_Block_Bermuda" "VPN_Block_Bhutan" "VPN_Block_Bolvia" "VPN_Block_Bosnia_Herzegovia" "VPN_Block_Botswana" "VPN_Block_Bouvet_Island" "VPN_Block_British_Indian_ocean_terr" "VPN_Block_Brunei_Darussalam" "VPN_Block_Bulgaria" "VPN_Block_Burkina_Faso" "VPN_Block_Burundi" "VPN_Block_Cameroon" "VPN_Block_Cape_Verde" "VPN_Block_Cayman_Islands" "VPN_Block_Central_African_Republic" "VPN_Block_Chad" "VPN_Block_Chile" "VPN_Block_Christams_Island" "VPN_Block_Columbia" "VPN_Block_Comonros" "VPN_Block_Congo" "VPN_Block_Congo_Replibic" "VPN_Block_Cook_Islands" "VPN_Block_Costa_Rica" "VPN_Block_Cote_Dlvoire" "VPN_Block_Croatia" "VPN_Block_Cuba" "VPN_Block_Curacao" "VPN_Block_Djibouti" "VPN_Block_Dominica" "VPN_Block_Dominican_Replublic" "VPN_Block_Ecuador" "VPN_Block_Egypt" "VPN_Block_El_Salvador" "VPN_Block_Equatorial_Guinea" "VPN_Block_Eritrea" "VPN_Block_Estonia" "VPN_Block_Ethiopia" "VPN_Block_Netherlands" "VPN_Block_Netherlands_Antilles" "VPN_Block_Falkland_Islands" "VPN_Block_Faroe_Islands" "VPN_Block_Fiji" "VPN_Block_Finland" "VPN_Block_French_Guiana" "VPN_Block_French_Polnesia" "VPN_Block_FST" "VPN_Block_Gabon" "VPN_Block_Gambia" "VPN_Block_Georgia" "VPN_Block_Ghana" "VPN_Block_Gibraltar" "VPN_Block_Ginea-Bissau" "VPN_Block_Greenland" "VPN_Block_Grenada" "VPN_Block_Guadeloupe" "VPN_Block_guam" "VPN_Block_Guatemala" "VPN_Block_Guerney" "VPN_Block_Guinea" "VPN_Block_Guyana" "VPN_Block_Palestinain_Territory" "VPN_Block_Haiti" "VPN_Block_Heard_Islands" "VPN_Block_Holy_See" "VPN_Block_Honduras" "VPN_Block_Iceland" "VPN_Block_Isle_of_man" "VPN_Block_Jamacia" "VPN_Block_Jersey" "VPN_Block_Jordan" "VPN_Block_Kazakhstan" "VPN_Block_Kenya" "VPN_Block_Kiribati" "VPN_Block_Korea" "VPN_Block_Kosovo" "VPN_Block_Kuwait" "VPN_Block_Kyrgyzstan" "VPN_Block_Lao" "VPN_Block_Latvia" "VPN_Block_Lebanon" "VPN_Block_Lesotho" "VPN_Block_Libyan" "VPN_Block_Liechtenstein" "VPN_Block_Lithuania" "VPN_Block_Macao" "VPN_Block_Macedonia" "VPN_Block_Madagascar" "VPN_Block_Malawi" "VPN_Block_Maldives" "VPN_Block_Mali" "VPN_Block_Malta" "VPN_Block_Marshall_Islands" "VPN_Block_Martinique" "VPN_Block_Mauritania" "VPN_Block_Mauritius" "VPN_Block_Mayotte" "VPN_Block_Micronedia" "VPN_Block_Moldova" "VPN_Block_Monaco" "VPN_Block_Mongolia" "VPN_Block_Montenergo" "VPN_Block_Montserrat" "VPN_Block_Morocco" "VPN_Block_Mozambique" "VPN_Block_Myanmar" "VPN_Block_Turkey" "VPN_Block_Cyprus" "VPN_Block_Namibia" "VPN_Block_Nauru" "VPN_Block_Nepal" "VPN_Block_New_Caledonia" "VPN_Block_New_Zealand" "VPN_Block_Nicaragua" "VPN_Block_Niger" "VPN_Block_Nigeria" "VPN_Block_Norway" "VPN_Block_Pakistan" "VPN_Block_Panama" "VPN_Block_Paraguay" "VPN_Block_Peru" "VPN_Block_Philippines" "VPN_Block_Poland" "VPN_Block_Portugal" "VPN_Block_Puerto_rico" "VPN_Block_Reunion" "VPN_Block_Romania" "VPN_Block_Samoa" "VPN_Block_Saudi_Arabia" "VPN_Block_Serbia" "VPN_Block_Slovakia" "VPN_Block_Slovenia" "VPN_Block_Somalia" "VPN_Block_South_Africa" "VPN_Block_Sudan" "VPN_Block_Syrian_arab_republic" "VPN_Block_Thailand" "VPN_Block_Turks_and_cacios" "VPN_Block_Ukraine" "VPN_Block_United_Arab_Emirates" "VPN_Block_Uruguay" "VPN_Block_Venezuela" "VPN_Block_Vietnam" "VPN_Block_Virgin_islands_british"
    next
    edit "Block_VPN_Failed"
        set member "VPN_Block_205.210.31.169"
    next
end
```

### 5N.) - config firewall address6
define our IPv6 address groups, one for the geography, and one used by the auto block stitches

```
config firewall addrgrp6
    edit "Block_VPN_Failed_IPv6"
        set member "VPN_Block_2a01:4ff:f0:a387::1"
    next
    edit "VPN_Block_Geography_IPv6"
        set member "VPN_Block_Afganistan" "VPN_Block_Aland_Islands" "VPN_Block_Albania" "VPN_Block_Algeria" "VPN_Block_American_Aamoa" "VPN_Block_Andorra" "VPN_Block_Angola" "VPN_Block_Anguilla" "VPN_Block_Antigua_Barbuda" "VPN_Block_Argentina" "VPN_Block_Armenia" "VPN_Block_Aruba" "VPN_Block_Austria" "VPN_Block_Austrialia" "VPN_Block_Azerbaijan" "VPN_Block_Bahamas" "VPN_Block_Bahrain" "VPN_Block_Bangladesh" "VPN_Block_Barbados" "VPN_Block_Belarus" "VPN_Block_Belgium" "VPN_Block_Belize" "VPN_Block_Benin" "VPN_Block_Bermuda" "VPN_Block_Bhutan" "VPN_Block_Bolvia" "VPN_Block_Bosnia_Herzegovia" "VPN_Block_Botswana" "VPN_Block_Bouvet_Island" "VPN_Block_Brazil" "VPN_Block_British_Indian_ocean_terr" "VPN_Block_Brunei_Darussalam" "VPN_Block_Bulgaria" "VPN_Block_Burkina_Faso" "VPN_Block_Burundi" "VPN_Block_Cambodia" "VPN_Block_Cameroon" "VPN_Block_Canada" "VPN_Block_Cape_Verde" "VPN_Block_Cayman_Islands" "VPN_Block_Central_African_Republic" "VPN_Block_Chad" "VPN_Block_Chile" "VPN_Block_China" "VPN_Block_Christams_Island" "VPN_Block_Columbia" "VPN_Block_Comonros" "VPN_Block_Congo" "VPN_Block_Congo_Replibic" "VPN_Block_Cook_Islands" "VPN_Block_Costa_Rica" "VPN_Block_Cote_Dlvoire" "VPN_Block_Croatia" "VPN_Block_Cuba" "VPN_Block_Curacao" "VPN_Block_Cyprus" "VPN_Block_Czech_Republic" "VPN_Block_Denmark" "VPN_Block_Djibouti" "VPN_Block_Dominica" "VPN_Block_Dominican_Replublic" "VPN_Block_Ecuador" "VPN_Block_Egypt" "VPN_Block_El_Salvador" "VPN_Block_Equatorial_Guinea" "VPN_Block_Eritrea" "VPN_Block_Estonia" "VPN_Block_Ethiopia" "VPN_Block_Falkland_Islands" "VPN_Block_Faroe_Islands" "VPN_Block_Fiji" "VPN_Block_Finland" "VPN_Block_France" "VPN_Block_French_Guiana" "VPN_Block_French_Polnesia" "VPN_Block_FST" "VPN_Block_Gabon" "VPN_Block_Gambia" "VPN_Block_Georgia" "VPN_Block_Germany" "VPN_Block_Ghana" "VPN_Block_Gibraltar" "VPN_Block_Ginea-Bissau" "VPN_Block_Greece" "VPN_Block_Greenland" "VPN_Block_Grenada" "VPN_Block_Guadeloupe" "VPN_Block_guam" "VPN_Block_Guatemala" "VPN_Block_Guerney" "VPN_Block_Guinea" "VPN_Block_Guyana" "VPN_Block_Haiti" "VPN_Block_Heard_Islands" "VPN_Block_Holy_See" "VPN_Block_Honduras" "VPN_Block_Hong_Kong" "VPN_Block_Hungary" "VPN_Block_Iceland" "VPN_Block_India" "VPN_Block_Indonesia" "VPN_Block_Iran" "VPN_Block_Iraq" "VPN_Block_Ireland" "VPN_Block_Isle_of_man" "VPN_Block_Isreal" "VPN_Block_Italy" "VPN_Block_Jamacia" "VPN_Block_Japan" "VPN_Block_Jersey" "VPN_Block_Jordan" "VPN_Block_Kazakhstan" "VPN_Block_Kenya" "VPN_Block_Kiribati" "VPN_Block_Korea" "VPN_Block_Korea1" "VPN_Block_Korea2" "VPN_Block_Kosovo" "VPN_Block_Kuwait" "VPN_Block_Kyrgyzstan" "VPN_Block_Lao" "VPN_Block_Latvia" "VPN_Block_Lebanon" "VPN_Block_Lesotho" "VPN_Block_Liberia" "VPN_Block_Libyan" "VPN_Block_Liechtenstein" "VPN_Block_Lithuania" "VPN_Block_Luxembourg" "VPN_Block_Macao" "VPN_Block_Macedonia" "VPN_Block_Madagascar" "VPN_Block_Malawi" "VPN_Block_Malaysia" "VPN_Block_Maldives" "VPN_Block_Mali" "VPN_Block_Malta" "VPN_Block_Marshall_Islands" "VPN_Block_Martinique" "VPN_Block_Mauritania" "VPN_Block_Mauritius" "VPN_Block_Mayotte" "VPN_Block_Mexico" "VPN_Block_Micronedia" "VPN_Block_Moldova" "VPN_Block_Monaco" "VPN_Block_Mongolia" "VPN_Block_Montenergo" "VPN_Block_Montserrat" "VPN_Block_Morocco" "VPN_Block_Mozambique" "VPN_Block_Myanmar" "VPN_Block_Namibia" "VPN_Block_Nauru" "VPN_Block_Nepal" "VPN_Block_Netherlands" "VPN_Block_Netherlands_Antilles" "VPN_Block_New_Caledonia" "VPN_Block_New_Zealand" "VPN_Block_Nicaragua" "VPN_Block_Niger" "VPN_Block_Nigeria" "VPN_Block_Norway" "VPN_Block_Pakistan" "VPN_Block_Palestinain_Territory" "VPN_Block_Panama" "VPN_Block_Paraguay" "VPN_Block_Peru" "VPN_Block_Philippines" "VPN_Block_Poland" "VPN_Block_Portugal" "VPN_Block_Puerto_rico" "VPN_Block_Reunion" "VPN_Block_Romania" "VPN_Block_Russia" "VPN_Block_Samoa" "VPN_Block_Saudi_Arabia" "VPN_Block_Serbia" "VPN_Block_Singapore" "VPN_Block_Slovakia" "VPN_Block_Slovenia" "VPN_Block_Somalia" "VPN_Block_South_Africa" "VPN_Block_Spain" "VPN_Block_Sudan" "VPN_Block_Sweeden" "VPN_Block_Switzerland" "VPN_Block_Syrian_arab_republic" "VPN_Block_Taiwan" "VPN_Block_Thailand" "VPN_Block_Turkey" "VPN_Block_Turks_and_cacios" "VPN_Block_Ukraine" "VPN_Block_United_Arab_Emirates" "VPN_Block_United_Kingdom" "VPN_Block_Uruguay" "VPN_Block_Venezuela" "VPN_Block_Vietnam" "VPN_Block_Virgin_islands_british"
    next
end
```

### 5O.) - config system external-resource
Configure our external threat feeds to block the ASNs of web hosting providers and our manual block list so we can use it in our local-in-polices

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
        set refresh-rate 10080
    next
end
```

### 5P.) - config firewall local-in-policy
Define our IPv4 local-in-policy. we first make sure to allow any known IPs so they are not blocked by accident by the auto-block stitches.

we then block all countries we do not wish to allow access to our services

we then block everything on our ASN block llists

we then block everything on our manual block list

finally we block everything caught by our auto-block stitches

```
config firewall local-in-policy
    edit 1
        set intf "wan1"
        set srcaddr "your_allowed_ips"
        set dstaddr "all"
        set action accept
        set service "IKE"
        set schedule "always"
    next
    edit 2
        set intf "wan1"
        set srcaddr "VPN_Block_Geography"
        set dstaddr "all"
        set service "ALL"
        set schedule "always"
    next
    edit 3
        set intf "wan1"
        set srcaddr "ASN_lists_blocked"
        set dstaddr "all"
        set service "ALL"
        set schedule "always"
    next
    edit 4
        set intf "wan1"
        set srcaddr "manual_blocked"
        set dstaddr "all"
        set service "ALL"
        set schedule "always"
    next
    edit 5
        set intf "wan1"
        set srcaddr "Block_VPN_Failed"
        set dstaddr "all"
        set service "ALL"
        set schedule "always"
    next
end
```


### 5Q.) - config firewall local-in-policy6
Define our IPv6 local-in-policy. we first make sure to allow any known IPs so they are not blocked by accident by the auto-block stitches.

we then block all countries we do not wish to allow access to our services

we then block everything on our ASN block llists

finally we block everything caught by our auto-block stitches

```
config firewall local-in-policy6
    edit 1
        set intf "wan1"
        set srcaddr "your_allowed_ips_IPv6"
        set dstaddr "all"
        set action accept
        set service "IKE"
        set schedule "always"
    next
    edit 2
        set intf "wan1"
        set srcaddr "VPN_Block_Geography_IPv6"
        set dstaddr "all"
        set service "ALL"
        set schedule "always"
    next
    edit 3
        set intf "wan1"
        set srcaddr "ASN_lists_blocked"
        set dstaddr "all"
        set service "ALL"
        set schedule "always"
    next
    edit 4
        set intf "wan1"
        set srcaddr "Block_VPN_Failed_IPv6"
        set dstaddr "all"
        set service "ALL"
        set schedule "always"
    next
end
```

### 5R.) - config firewall policy

Finally, we now need to configure explicit fire wall polcies to allow the IPsec VPNs access to our various other netwworks / VLANs. 

```
config firewall policy
	edit 163
        set name "HomeVPN-IPsec --> VLANXYZ"
        set srcintf "HomeVPN-IPsec"
        set dstintf "VLANXYZ"
        set action accept
        set srcaddr "HomeVPN-IPsec_range"
        set dstaddr "Device_IP_device1"
        set schedule "always"
        set service "ALL"
        set profile-protocol-options "Core_Proxy"
        set logtraffic all
    next
    edit 166
        set name "HomeVPNv6-IKE2 --> VLANXYZ"
        set srcintf "HomeVPNv6-IKE2"
        set dstintf "VLANXYZ"
        set action accept
        set srcaddr "HomeVPN-IPsec_range"
        set dstaddr "Device_IP_device1"
        set schedule "always"
        set service "ALL"
        set profile-protocol-options "Core_Proxy"
        set logtraffic all
    next
    edit 131
        set name "IPsec --> VLANXYZ"
        set srcintf "HomeVPNv6"
        set dstintf "VLANXYZ"
        set action accept
        set srcaddr "HomeVPN-IPsec_range"
        set dstaddr "Device_IP_device1"
        set schedule "always"
        set service "ALL"
        set profile-protocol-options "Core_Proxy"
        set logtraffic all
    next
    edit 165
        set name "HomeVPN-IPsec --> VLANXYZ IPv6"
        set srcintf "HomeVPN-IPsec"
        set dstintf "VLANXYZ"
        set action accept
        set srcaddr6 "HomeVPN-IPsec_range"
        set dstaddr6 "Device_IP_device1_IPv6"
        set schedule "always"
        set service "ALL"
        set profile-protocol-options "Core_Proxy"
        set logtraffic all
    next
    edit 167
        set name "HomeVPNv6-IKE2 --> VLANXYZ IPv6"
        set srcintf "HomeVPNv6-IKE2"
        set dstintf "VLANXYZ"
        set action accept
        set srcaddr6 "HomeVPN-IPsec_range"
        set dstaddr6 "Device_IP_device1_IPv6"
        set schedule "always"
        set service "ALL"
        set profile-protocol-options "Core_Proxy"
        set logtraffic all
    next
    edit 149
        set name "IPsec --> VLANXYZ (IPv6)"
        set srcintf "HomeVPNv6"
        set dstintf "VLANXYZ"
        set action accept
        set srcaddr6 "HomeVPN-IPsec_range"
        set dstaddr6 "Device_IP_device1_IPv6"
        set schedule "always"
        set service "ALL"
        set profile-protocol-options "Core_Proxy"
        set logtraffic all
    next
```
