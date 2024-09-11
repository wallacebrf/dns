#!/bin/bash

ipv6=0 #set to a 1 to add IPv6 addresses to the UFW configuration
test_mode=0 #set to a "1" to download and compare settings, but do NOT change any of the current settings on the system
block_ASN=1
block_geo=1

#download all of the ASN text files 
echo -e "\n\n***************************************"
echo "download all of the ASN text files"
echo -e "***************************************\n\n"
mkdir /var/www/asn/

if [[ "$block_ASN" -eq 1 ]]; then
	wget -O AS22612.txt https://asn.ipinfo.app/api/text/list/AS22612
	mv /var/www/AS22612.txt /var/www/asn/AS22612.txt

	wget -O AS12312.txt https://asn.ipinfo.app/api/text/list/AS12312
	mv /var/www/AS12312.txt /var/www/asn/AS12312.txt

	wget -O AS64419.txt https://asn.ipinfo.app/api/text/list/AS64419
	mv /var/www/AS64419.txt /var/www/asn/AS64419.txt

	wget -O AS204957.txt https://asn.ipinfo.app/api/text/list/AS204957
	mv /var/www/AS204957.txt /var/www/asn/AS204957.txt

	wget -O AS61112.txt https://asn.ipinfo.app/api/text/list/AS61112
	mv /var/www/AS61112.txt /var/www/asn/AS61112.txt

	wget -O AS8100.txt https://asn.ipinfo.app/api/text/list/AS8100
	mv /var/www/AS8100.txt /var/www/asn/AS8100.txt

	wget -O AS16276.txt https://asn.ipinfo.app/api/text/list/AS16276
	mv /var/www/AS16276.txt /var/www/asn/AS16276.txt

	wget -O AS35540.txt https://asn.ipinfo.app/api/text/list/AS35540
	mv /var/www/AS35540.txt /var/www/asn/AS35540.txt

	wget -O AS394814.txt https://asn.ipinfo.app/api/text/list/AS394814
	mv /var/www/AS394814.txt /var/www/asn/AS394814.txt

	wget -O AS35478.txt https://asn.ipinfo.app/api/text/list/AS35478
	mv /var/www/AS35478.txt /var/www/asn/AS35478.txt

	wget -O AS22384.txt https://asn.ipinfo.app/api/text/list/AS22384
	mv /var/www/AS22384.txt /var/www/asn/AS22384.txt

	wget -O AS46562.txt https://asn.ipinfo.app/api/text/list/AS46562
	mv /var/www/AS46562.txt /var/www/asn/AS46562.txt

	wget -O AS39486.txt https://asn.ipinfo.app/api/text/list/AS39486
	mv /var/www/AS39486.txt /var/www/asn/AS39486.txt

	wget -O AS44144.txt https://asn.ipinfo.app/api/text/list/AS44144
	mv /var/www/AS44144.txt /var/www/asn/AS44144.txt

	wget -O AS133499.txt https://asn.ipinfo.app/api/text/list/AS133499
	mv /var/www/AS133499.txt /var/www/asn/AS133499.txt

	wget -O AS134450.txt https://asn.ipinfo.app/api/text/list/AS134450
	mv /var/www/AS134450.txt /var/www/asn/AS134450.txt

	wget -O AS203020.txt https://asn.ipinfo.app/api/text/list/AS203020
	mv /var/www/AS203020.txt /var/www/asn/AS203020.txt

	wget -O AS204287.txt https://asn.ipinfo.app/api/text/list/AS204287
	mv /var/www/AS204287.txt /var/www/asn/AS204287.txt

	wget -O AS207990.txt https://asn.ipinfo.app/api/text/list/AS207990
	mv /var/www/AS207990.txt /var/www/asn/AS207990.txt

	wget -O AS11878.txt https://asn.ipinfo.app/api/text/list/AS11878
	mv /var/www/AS11878.txt /var/www/asn/AS11878.txt

	wget -O AS6939.txt https://asn.ipinfo.app/api/text/list/AS6939
	mv /var/www/AS6939.txt /var/www/asn/AS6939.txt

	wget -O AS60068.txt https://asn.ipinfo.app/api/text/list/AS60068
	mv /var/www/AS60068.txt /var/www/asn/AS60068.txt

	wget -O AS212238.txt https://asn.ipinfo.app/api/text/list/AS212238
	mv /var/www/AS212238.txt /var/www/asn/AS212238.txt

	wget -O AS50446.txt https://asn.ipinfo.app/api/text/list/AS50446
	mv /var/www/AS50446.txt /var/www/asn/AS50446.txt

	wget -O AS9009.txt https://asn.ipinfo.app/api/text/list/AS9009
	mv /var/www/AS9009.txt /var/www/asn/AS9009.txt

	wget -O AS16247.txt https://asn.ipinfo.app/api/text/list/AS16247
	mv /var/www/AS16247.txt /var/www/asn/AS16247.txt

	wget -O AS42973.txt https://asn.ipinfo.app/api/text/list/AS42973
	mv /var/www/AS42973.txt /var/www/asn/AS42973.txt

	wget -O AS35536.txt https://asn.ipinfo.app/api/text/list/AS35536
	mv /var/www/AS35536.txt /var/www/asn/AS35536.txt

	wget -O AS9312.txt https://asn.ipinfo.app/api/text/list/AS9312
	mv /var/www/AS9312.txt /var/www/asn/AS9312.txt

	wget -O AS8888.txt https://asn.ipinfo.app/api/text/list/AS8888
	mv /var/www/AS8888.txt /var/www/asn/AS8888.txt

	wget -O AS6233.txt https://asn.ipinfo.app/api/text/list/AS6233
	mv /var/www/AS6233.txt /var/www/asn/AS6233.txt

	wget -O AS4785.txt https://asn.ipinfo.app/api/text/list/AS4785
	mv /var/www/AS4785.txt /var/www/asn/AS4785.txt

	wget -O AS3258.txt https://asn.ipinfo.app/api/text/list/AS3258
	mv /var/www/AS3258.txt /var/www/asn/AS3258.txt

	wget -O AS3214.txt https://asn.ipinfo.app/api/text/list/AS3214
	mv /var/www/AS3214.txt /var/www/asn/AS3214.txt

	wget -O AS949.txt https://asn.ipinfo.app/api/text/list/AS949
	mv /var/www/AS949.txt /var/www/asn/AS949.txt

	wget -O AS14315.txt https://asn.ipinfo.app/api/text/list/AS14315
	mv /var/www/AS14315.txt /var/www/asn/AS14315.txt

	wget -O AS18779.txt https://asn.ipinfo.app/api/text/list/AS18779
	mv /var/www/AS18779.txt /var/www/asn/AS18779.txt

	wget -O AS7005.txt https://asn.ipinfo.app/api/text/list/AS7005
	mv /var/www/AS7005.txt /var/www/asn/AS7005.txt

	wget -O AS26666.txt https://asn.ipinfo.app/api/text/list/AS26666
	mv /var/www/AS26666.txt /var/www/asn/AS26666.txt

	wget -O AS13335.txt https://asn.ipinfo.app/api/text/list/AS13335
	mv /var/www/AS13335.txt /var/www/asn/AS13335.txt

	wget -O AS202623.txt https://asn.ipinfo.app/api/text/list/AS202623
	mv /var/www/AS202623.txt /var/www/asn/AS202623.txt

	wget -O AS395747.txt https://asn.ipinfo.app/api/text/list/AS395747
	mv /var/www/AS395747.txt /var/www/asn/AS395747.txt

	wget -O AS62651.txt https://asn.ipinfo.app/api/text/list/AS62651
	mv /var/www/AS62651.txt /var/www/asn/AS62651.txt

	wget -O AS54203.txt https://asn.ipinfo.app/api/text/list/AS54203
	mv /var/www/AS54203.txt /var/www/asn/AS54203.txt

	wget -O AS54138.txt https://asn.ipinfo.app/api/text/list/AS54138
	mv /var/www/AS54138.txt /var/www/asn/AS54138.txt

	wget -O AS50667.txt https://asn.ipinfo.app/api/text/list/AS50667
	mv /var/www/AS50667.txt /var/www/asn/AS50667.txt

	wget -O AS31362.txt https://asn.ipinfo.app/api/text/list/AS31362
	mv /var/www/AS31362.txt /var/www/asn/AS31362.txt

	wget -O AS13926.txt https://asn.ipinfo.app/api/text/list/AS13926
	mv /var/www/AS13926.txt /var/www/asn/AS13926.txt

	wget -O AS213006.txt https://asn.ipinfo.app/api/text/list/AS213006
	mv /var/www/AS213006.txt /var/www/asn/AS213006.txt

	wget -O AS213005.txt https://asn.ipinfo.app/api/text/list/AS213005
	mv /var/www/AS213005.txt /var/www/asn/AS213005.txt

	wget -O AS212862.txt https://asn.ipinfo.app/api/text/list/AS212862
	mv /var/www/AS212862.txt /var/www/asn/AS212862.txt

	wget -O AS212861.txt https://asn.ipinfo.app/api/text/list/AS212861
	mv /var/www/AS212861.txt /var/www/asn/AS212861.txt

	wget -O AS204286.txt https://asn.ipinfo.app/api/text/list/AS204286
	mv /var/www/AS204286.txt /var/www/asn/AS204286.txt

	wget -O AS202636.txt https://asn.ipinfo.app/api/text/list/AS202636
	mv /var/www/AS202636.txt /var/www/asn/AS202636.txt

	wget -O AS200908.txt https://asn.ipinfo.app/api/text/list/AS200908
	mv /var/www/AS200908.txt /var/www/asn/AS200908.txt

	wget -O AS17470.txt https://asn.ipinfo.app/api/text/list/AS17470
	mv /var/www/AS17470.txt /var/www/asn/AS17470.txt

	wget -O AS209372.txt https://asn.ipinfo.app/api/text/list/AS209372
	mv /var/www/AS209372.txt /var/www/asn/AS209372.txt

	wget -O AS45887.txt https://asn.ipinfo.app/api/text/list/AS45887
	mv /var/www/AS45887.txt /var/www/asn/AS45887.txt

	wget -O AS48337.txt https://asn.ipinfo.app/api/text/list/AS48337
	mv /var/www/AS48337.txt /var/www/asn/AS48337.txt

	wget -O AS63949.txt https://asn.ipinfo.app/api/text/list/AS63949
	mv /var/www/AS63949.txt /var/www/asn/AS63949.txt

	wget -O AS61317.txt https://asn.ipinfo.app/api/text/list/AS61317
	mv /var/www/AS61317.txt /var/www/asn/AS61317.txt

	wget -O AS263735.txt https://asn.ipinfo.app/api/text/list/AS263735
	mv /var/www/AS263735.txt /var/www/asn/AS263735.txt

	wget -O AS263740.txt https://asn.ipinfo.app/api/text/list/AS263740
	mv /var/www/AS263740.txt /var/www/asn/AS263740.txt

	wget -O AS14061.txt https://asn.ipinfo.app/api/text/list/AS14061
	mv /var/www/AS14061.txt /var/www/asn/AS14061.txt

	wget -O AS14576.txt https://asn.ipinfo.app/api/text/list/AS14576
	mv /var/www/AS14576.txt /var/www/asn/AS14576.txt

	wget -O AS8075.txt https://asn.ipinfo.app/api/text/list/AS8075
	mv /var/www/AS8075.txt /var/www/asn/AS8075.txt

	wget -O AS62240.txt https://asn.ipinfo.app/api/text/list/AS62240
	mv /var/www/AS62240.txt /var/www/asn/AS62240.txt

	wget -O AS36352.txt https://asn.ipinfo.app/api/text/list/AS36352
	mv /var/www/AS36352.txt /var/www/asn/AS36352.txt

	wget -O AS12876.txt https://asn.ipinfo.app/api/text/list/AS12876
	mv /var/www/AS12876.txt /var/www/asn/AS12876.txt

	wget -O AS37518.txt https://asn.ipinfo.app/api/text/list/AS37518
	mv /var/www/AS37518.txt /var/www/asn/AS37518.txt

	wget -O AS132203.txt https://asn.ipinfo.app/api/text/list/AS132203
	mv /var/www/AS132203.txt /var/www/asn/AS132203.txt

	wget -O AS45090.txt https://asn.ipinfo.app/api/text/list/AS45090
	mv /var/www/AS45090.txt /var/www/asn/AS45090.txt

	wget -O AS55286.txt https://asn.ipinfo.app/api/text/list/AS55286
	mv /var/www/AS55286.txt /var/www/asn/AS55286.txt

	wget -O AS210558.txt https://asn.ipinfo.app/api/text/list/AS210558
	mv /var/www/AS210558.txt /var/www/asn/AS210558.txt

	wget -O AS206092.txt https://asn.ipinfo.app/api/text/list/AS206092
	mv /var/www/AS206092.txt /var/www/asn/AS206092.txt

	wget -O AS26548.txt https://asn.ipinfo.app/api/text/list/AS26548
	mv /var/www/AS26548.txt /var/www/asn/AS26548.txt

	wget -O AS137409.txt https://asn.ipinfo.app/api/text/list/AS137409
	mv /var/www/AS137409.txt /var/www/asn/AS137409.txt

	wget -O AS40861.txt https://asn.ipinfo.app/api/text/list/AS40861
	mv /var/www/AS40861.txt /var/www/asn/AS40861.txt

	wget -O AS36007.txt https://asn.ipinfo.app/api/text/list/AS36007
	mv /var/www/AS36007.txt /var/www/asn/AS36007.txt

	wget -O AS24961.txt https://asn.ipinfo.app/api/text/list/AS24961
	mv /var/www/AS24961.txt /var/www/asn/AS24961.txt

	wget -O AS39572.txt https://asn.ipinfo.app/api/text/list/AS39572
	mv /var/www/AS39572.txt /var/www/asn/AS39572.txt

	wget -O AS5384.txt https://asn.ipinfo.app/api/text/list/AS5384
	mv /var/www/AS5384.txt /var/www/asn/AS5384.txt

	wget -O AS8966.txt https://asn.ipinfo.app/api/text/list/AS8966
	mv /var/www/AS8966.txt /var/www/asn/AS8966.txt

	wget -O AS834.txt https://asn.ipinfo.app/api/text/list/AS834
	mv /var/www/AS834.txt /var/www/asn/AS834.txt

	wget -O AS932.txt https://asn.ipinfo.app/api/text/list/AS932
	mv /var/www/AS932.txt /var/www/asn/AS932.txt

	wget -O AS6134.txt https://asn.ipinfo.app/api/text/list/AS6134
	mv /var/www/AS6134.txt /var/www/asn/AS6134.txt

	wget -O AS15828.txt https://asn.ipinfo.app/api/text/list/AS15828
	mv /var/www/AS15828.txt /var/www/asn/AS15828.txt

	wget -O AS17048.txt https://asn.ipinfo.app/api/text/list/AS17048
	mv /var/www/AS17048.txt /var/www/asn/AS17048.txt

	wget -O AS27524.txt https://asn.ipinfo.app/api/text/list/AS27524
	mv /var/www/AS27524.txt /var/www/asn/AS27524.txt

	wget -O AS33333.txt https://asn.ipinfo.app/api/text/list/AS33333
	mv /var/www/AS33333.txt /var/www/asn/AS33333.txt

	wget -O AS35624.txt https://asn.ipinfo.app/api/text/list/AS35624
	mv /var/www/AS35624.txt /var/www/asn/AS35624.txt

	wget -O AS3223.txt https://asn.ipinfo.app/api/text/list/AS3223
	mv /var/www/AS3223.txt /var/www/asn/AS3223.txt

	wget -O AS3842.txt https://asn.ipinfo.app/api/text/list/AS3842
	mv /var/www/AS3842.txt /var/www/asn/AS3842.txt

	wget -O AS4694.txt https://asn.ipinfo.app/api/text/list/AS4694
	mv /var/www/AS4694.txt /var/www/asn/AS4694.txt

	wget -O AS5577.txt https://asn.ipinfo.app/api/text/list/AS5577
	mv /var/www/AS5577.txt /var/www/asn/AS5577.txt

	wget -O AS6724.txt https://asn.ipinfo.app/api/text/list/AS6724
	mv /var/www/AS6724.txt /var/www/asn/AS6724.txt

	wget -O AS7203.txt https://asn.ipinfo.app/api/text/list/AS7203
	mv /var/www/AS7203.txt /var/www/asn/AS7203.txt

	wget -O AS7489.txt https://asn.ipinfo.app/api/text/list/AS7489
	mv /var/www/AS7489.txt /var/www/asn/AS7489.txt

	wget -O AS7506.txt https://asn.ipinfo.app/api/text/list/AS7506
	mv /var/www/AS7506.txt /var/www/asn/AS7506.txt

	wget -O AS7850.txt https://asn.ipinfo.app/api/text/list/AS7850
	mv /var/www/AS7850.txt /var/www/asn/AS7850.txt

	wget -O AS7979.txt https://asn.ipinfo.app/api/text/list/AS7979
	mv /var/www/AS7979.txt /var/www/asn/AS7979.txt

	wget -O AS8455.txt https://asn.ipinfo.app/api/text/list/AS8455
	mv /var/www/AS8455.txt /var/www/asn/AS8455.txt

	wget -O AS8560.txt https://asn.ipinfo.app/api/text/list/AS8560
	mv /var/www/AS8560.txt /var/www/asn/AS8560.txt

	wget -O AS9370.txt https://asn.ipinfo.app/api/text/list/AS9370
	mv /var/www/AS9370.txt /var/www/asn/AS9370.txt

	wget -O AS10297.txt https://asn.ipinfo.app/api/text/list/AS10297
	mv /var/www/AS10297.txt /var/www/asn/AS10297.txt

	wget -O AS10439.txt https://asn.ipinfo.app/api/text/list/AS10439
	mv /var/www/AS10439.txt /var/www/asn/AS10439.txt

	wget -O AS11831.txt https://asn.ipinfo.app/api/text/list/AS11831
	mv /var/www/AS11831.txt /var/www/asn/AS11831.txt

	wget -O AS12586.txt https://asn.ipinfo.app/api/text/list/AS12586
	mv /var/www/AS12586.txt /var/www/asn/AS12586.txt

	wget -O AS13213.txt https://asn.ipinfo.app/api/text/list/AS13213
	mv /var/www/AS13213.txt /var/www/asn/AS13213.txt

	wget -O AS13739.txt https://asn.ipinfo.app/api/text/list/AS13739
	mv /var/www/AS13739.txt /var/www/asn/AS13739.txt

	wget -O AS14127.txt https://asn.ipinfo.app/api/text/list/AS14127
	mv /var/www/AS14127.txt /var/www/asn/AS14127.txt

	wget -O AS14618.txt https://asn.ipinfo.app/api/text/list/AS14618
	mv /var/www/AS14618.txt /var/www/asn/AS14618.txt

	wget -O AS16509.txt https://asn.ipinfo.app/api/text/list/AS16509
	mv /var/www/AS16509.txt /var/www/asn/AS16509.txt

	wget -O AS15083.txt https://asn.ipinfo.app/api/text/list/AS15083
	mv /var/www/AS15083.txt /var/www/asn/AS15083.txt

	wget -O AS15169.txt https://asn.ipinfo.app/api/text/list/AS15169
	mv /var/www/AS15169.txt /var/www/asn/AS15169.txt

	wget -O AS15395.txt https://asn.ipinfo.app/api/text/list/AS15395
	mv /var/www/AS15395.txt /var/www/asn/AS15395.txt

	wget -O AS15497.txt https://asn.ipinfo.app/api/text/list/AS15497
	mv /var/www/AS15497.txt /var/www/asn/AS15497.txt

	wget -O AS15510.txt https://asn.ipinfo.app/api/text/list/AS15510
	mv /var/www/AS15510.txt /var/www/asn/AS15510.txt

	wget -O AS15626.txt https://asn.ipinfo.app/api/text/list/AS15626
	mv /var/www/AS15626.txt /var/www/asn/AS15626.txt

	wget -O AS16125.txt https://asn.ipinfo.app/api/text/list/AS16125
	mv /var/www/AS16125.txt /var/www/asn/AS16125.txt

	wget -O AS16262.txt https://asn.ipinfo.app/api/text/list/AS16262
	mv /var/www/AS16262.txt /var/www/asn/AS16262.txt

	wget -O AS16628.txt https://asn.ipinfo.app/api/text/list/AS16628
	mv /var/www/AS16628.txt /var/www/asn/AS16628.txt

	wget -O AS17216.txt https://asn.ipinfo.app/api/text/list/AS17216
	mv /var/www/AS17216.txt /var/www/asn/AS17216.txt

	wget -O AS18450.txt https://asn.ipinfo.app/api/text/list/AS18450
	mv /var/www/AS18450.txt /var/www/asn/AS18450.txt

	wget -O AS18978.txt https://asn.ipinfo.app/api/text/list/AS18978
	mv /var/www/AS18978.txt /var/www/asn/AS18978.txt

	wget -O AS19084.txt https://asn.ipinfo.app/api/text/list/AS19084
	mv /var/www/AS19084.txt /var/www/asn/AS19084.txt

	wget -O AS19318.txt https://asn.ipinfo.app/api/text/list/AS19318
	mv /var/www/AS19318.txt /var/www/asn/AS19318.txt

	wget -O AS19437.txt https://asn.ipinfo.app/api/text/list/AS19437
	mv /var/www/AS19437.txt /var/www/asn/AS19437.txt

	wget -O AS19531.txt https://asn.ipinfo.app/api/text/list/AS19531
	mv /var/www/AS19531.txt /var/www/asn/AS19531.txt

	wget -O AS19624.txt https://asn.ipinfo.app/api/text/list/AS19624
	mv /var/www/AS19624.txt /var/www/asn/AS19624.txt

	wget -O AS19871.txt https://asn.ipinfo.app/api/text/list/AS19871
	mv /var/www/AS19871.txt /var/www/asn/AS19871.txt

	wget -O AS19969.txt https://asn.ipinfo.app/api/text/list/AS19969
	mv /var/www/AS19969.txt /var/www/asn/AS19969.txt

	wget -O AS20021.txt https://asn.ipinfo.app/api/text/list/AS20021
	mv /var/www/AS20021.txt /var/www/asn/AS20021.txt

	wget -O AS20264.txt https://asn.ipinfo.app/api/text/list/AS20264
	mv /var/www/AS20264.txt /var/www/asn/AS20264.txt

	wget -O AS20454.txt https://asn.ipinfo.app/api/text/list/AS20454
	mv /var/www/AS20454.txt /var/www/asn/AS20454.txt

	wget -O AS20473.txt https://asn.ipinfo.app/api/text/list/AS20473
	mv /var/www/AS20473.txt /var/www/asn/AS20473.txt

	wget -O AS20598.txt https://asn.ipinfo.app/api/text/list/AS20598
	mv /var/www/AS20598.txt /var/www/asn/AS20598.txt

	wget -O AS21859.txt https://asn.ipinfo.app/api/text/list/AS21859
	mv /var/www/AS21859.txt /var/www/asn/AS21859.txt

	wget -O AS22363.txt https://asn.ipinfo.app/api/text/list/AS22363
	mv /var/www/AS22363.txt /var/www/asn/AS22363.txt

	wget -O AS22552.txt https://asn.ipinfo.app/api/text/list/AS22552
	mv /var/www/AS22552.txt /var/www/asn/AS22552.txt

	wget -O AS22781.txt https://asn.ipinfo.app/api/text/list/AS22781
	mv /var/www/AS22781.txt /var/www/asn/AS22781.txt

	wget -O AS23033.txt https://asn.ipinfo.app/api/text/list/AS23033
	mv /var/www/AS23033.txt /var/www/asn/AS23033.txt

	wget -O AS23342.txt https://asn.ipinfo.app/api/text/list/AS23342
	mv /var/www/AS23342.txt /var/www/asn/AS23342.txt

	wget -O AS23352.txt https://asn.ipinfo.app/api/text/list/AS23352
	mv /var/www/AS23352.txt /var/www/asn/AS23352.txt

	wget -O AS25780.txt https://asn.ipinfo.app/api/text/list/AS25780
	mv /var/www/AS25780.txt /var/www/asn/AS25780.txt

	wget -O AS29838.txt https://asn.ipinfo.app/api/text/list/AS29838
	mv /var/www/AS29838.txt /var/www/asn/AS29838.txt

	wget -O AS29854.txt https://asn.ipinfo.app/api/text/list/AS29854
	mv /var/www/AS29854.txt /var/www/asn/AS29854.txt

	wget -O AS30083.txt https://asn.ipinfo.app/api/text/list/AS30083
	mv /var/www/AS30083.txt /var/www/asn/AS30083.txt

	wget -O AS30475.txt https://asn.ipinfo.app/api/text/list/AS30475
	mv /var/www/AS30475.txt /var/www/asn/AS30475.txt

	wget -O AS30633.txt https://asn.ipinfo.app/api/text/list/AS30633
	mv /var/www/AS30633.txt /var/www/asn/AS30633.txt

	wget -O AS32097.txt https://asn.ipinfo.app/api/text/list/AS32097
	mv /var/www/AS32097.txt /var/www/asn/AS32097.txt

	wget -O AS32181.txt https://asn.ipinfo.app/api/text/list/AS32181
	mv /var/www/AS32181.txt /var/www/asn/AS32181.txt

	wget -O AS32244.txt https://asn.ipinfo.app/api/text/list/AS32244
	mv /var/www/AS32244.txt /var/www/asn/AS32244.txt

	wget -O AS32475.txt https://asn.ipinfo.app/api/text/list/AS32475
	mv /var/www/AS32475.txt /var/www/asn/AS32475.txt

	wget -O AS32780.txt https://asn.ipinfo.app/api/text/list/AS32780
	mv /var/www/AS32780.txt /var/www/asn/AS32780.txt

	wget -O AS33083.txt https://asn.ipinfo.app/api/text/list/AS33083
	mv /var/www/AS33083.txt /var/www/asn/AS33083.txt

	wget -O AS33182.txt https://asn.ipinfo.app/api/text/list/AS33182
	mv /var/www/AS33182.txt /var/www/asn/AS33182.txt

	wget -O AS33302.txt https://asn.ipinfo.app/api/text/list/AS33302
	mv /var/www/AS33302.txt /var/www/asn/AS33302.txt

	wget -O AS33480.txt https://asn.ipinfo.app/api/text/list/AS33480
	mv /var/www/AS33480.txt /var/www/asn/AS33480.txt

	wget -O AS33724.txt https://asn.ipinfo.app/api/text/list/AS33724
	mv /var/www/AS33724.txt /var/www/asn/AS33724.txt

	wget -O AS35908.txt https://asn.ipinfo.app/api/text/list/AS35908
	mv /var/www/AS35908.txt /var/www/asn/AS35908.txt

	wget -O AS35916.txt https://asn.ipinfo.app/api/text/list/AS35916
	mv /var/www/AS35916.txt /var/www/asn/AS35916.txt

	wget -O AS36114.txt https://asn.ipinfo.app/api/text/list/AS36114
	mv /var/www/AS36114.txt /var/www/asn/AS36114.txt

	wget -O AS36351.txt https://asn.ipinfo.app/api/text/list/AS36351
	mv /var/www/AS36351.txt /var/www/asn/AS36351.txt

	wget -O AS36666.txt https://asn.ipinfo.app/api/text/list/AS36666
	mv /var/www/AS36666.txt /var/www/asn/AS36666.txt

	wget -O AS40156.txt https://asn.ipinfo.app/api/text/list/AS40156
	mv /var/www/AS40156.txt /var/www/asn/AS40156.txt

	wget -O AS40244.txt https://asn.ipinfo.app/api/text/list/AS40244
	mv /var/www/AS40244.txt /var/www/asn/AS40244.txt

	wget -O AS40676.txt https://asn.ipinfo.app/api/text/list/AS40676
	mv /var/www/AS40676.txt /var/www/asn/AS40676.txt

	wget -O AS40824.txt https://asn.ipinfo.app/api/text/list/AS40824
	mv /var/www/AS40824.txt /var/www/asn/AS40824.txt

	wget -O AS46261.txt https://asn.ipinfo.app/api/text/list/AS46261
	mv /var/www/AS46261.txt /var/www/asn/AS46261.txt

	wget -O AS46475.txt https://asn.ipinfo.app/api/text/list/AS46475
	mv /var/www/AS46475.txt /var/www/asn/AS46475.txt

	wget -O AS46664.txt https://asn.ipinfo.app/api/text/list/AS46664
	mv /var/www/AS46664.txt /var/www/asn/AS46664.txt

	wget -O AS46844.txt https://asn.ipinfo.app/api/text/list/AS46844
	mv /var/www/AS46844.txt /var/www/asn/AS46844.txt

	wget -O AS53340.txt https://asn.ipinfo.app/api/text/list/AS53340
	mv /var/www/AS53340.txt /var/www/asn/AS53340.txt

	wget -O AS53559.txt https://asn.ipinfo.app/api/text/list/AS53559
	mv /var/www/AS53559.txt /var/www/asn/AS53559.txt

	wget -O AS53597.txt https://asn.ipinfo.app/api/text/list/AS53597
	mv /var/www/AS53597.txt /var/www/asn/AS53597.txt

	wget -O AS53667.txt https://asn.ipinfo.app/api/text/list/AS53667
	mv /var/www/AS53667.txt /var/www/asn/AS53667.txt

	wget -O AS53755.txt https://asn.ipinfo.app/api/text/list/AS53755
	mv /var/www/AS53755.txt /var/www/asn/AS53755.txt

	wget -O AS53850.txt https://asn.ipinfo.app/api/text/list/AS53850
	mv /var/www/AS53850.txt /var/www/asn/AS53850.txt

	wget -O AS54455.txt https://asn.ipinfo.app/api/text/list/AS54455
	mv /var/www/AS54455.txt /var/www/asn/AS54455.txt

	wget -O AS54489.txt https://asn.ipinfo.app/api/text/list/AS54489
	mv /var/www/AS54489.txt /var/www/asn/AS54489.txt

	wget -O AS54500.txt https://asn.ipinfo.app/api/text/list/AS54500
	mv /var/www/AS54500.txt /var/www/asn/AS54500.txt

	wget -O AS63018.txt https://asn.ipinfo.app/api/text/list/AS63018
	mv /var/www/AS63018.txt /var/www/asn/AS63018.txt

	wget -O AS63199.txt https://asn.ipinfo.app/api/text/list/AS63199
	mv /var/www/AS63199.txt /var/www/asn/AS63199.txt

	wget -O AS63473.txt https://asn.ipinfo.app/api/text/list/AS63473
	mv /var/www/AS63473.txt /var/www/asn/AS63473.txt

	wget -O AS64245.txt https://asn.ipinfo.app/api/text/list/AS64245
	mv /var/www/AS64245.txt /var/www/asn/AS64245.txt

	wget -O AS394380.txt https://asn.ipinfo.app/api/text/list/AS394380
	mv /var/www/AS394380.txt /var/www/asn/AS394380.txt

	wget -O AS395111.txt https://asn.ipinfo.app/api/text/list/AS395111
	mv /var/www/AS395111.txt /var/www/asn/AS395111.txt

	wget -O AS35830.txt https://asn.ipinfo.app/api/text/list/AS35830
	mv /var/www/AS35830.txt /var/www/asn/AS35830.txt

	wget -O AS45102.txt https://asn.ipinfo.app/api/text/list/AS45102
	mv /var/www/AS45102.txt /var/www/asn/AS45102.txt

	wget -O AS206728.txt https://asn.ipinfo.app/api/text/list/AS206728
	mv /var/www/AS206728.txt /var/www/asn/AS206728.txt

	wget -O AS398722.txt https://asn.ipinfo.app/api/text/list/AS398722
	mv /var/www/AS398722.txt /var/www/asn/AS398722.txt

	wget -O AS212027.txt https://asn.ipinfo.app/api/text/list/AS212027
	mv /var/www/AS212027.txt /var/www/asn/AS212027.txt

	wget -O AS142002.txt https://asn.ipinfo.app/api/text/list/AS142002
	mv /var/www/AS142002.txt /var/www/asn/AS142002.txt

	wget -O AS398324.txt https://asn.ipinfo.app/api/text/list/AS398324
	mv /var/www/AS398324.txt /var/www/asn/AS398324.txt
else
	echo -e "\n\n***************************************"
	echo "Skipping ASN Block Lists"
	echo -e "***************************************\n\n"
fi

#download GEOBLOCK text files 
#supply of IPs for different countries: https://github.com/herrbischoff/country-ip-blocks/tree/master/ipv4
#country codes: https://www.iban.com/country-codes
echo -e "\n\n***************************************"
echo "download all of the ASN text files"
echo -e "***************************************\n\n"

if [[ "$block_geo" -eq 1 ]]; then
	wget -O ad.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ad.cidr
	mv /var/www/ad.txt /var/www/asn/ad.txt

	wget -O ae.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ae.cidr
	mv /var/www/ae.txt /var/www/asn/ae.txt

	wget -O af.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/af.cidr
	mv /var/www/af.txt /var/www/asn/af.txt

	wget -O ag.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ag.cidr
	mv /var/www/ag.txt /var/www/asn/ag.txt

	wget -O ai.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ai.cidr
	mv /var/www/ai.txt /var/www/asn/ai.txt

	wget -O al.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/al.cidr
	mv /var/www/al.txt /var/www/asn/al.txt

	wget -O am.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/am.cidr
	mv /var/www/am.txt /var/www/asn/am.txt

	wget -O ao.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ao.cidr
	mv /var/www/ao.txt /var/www/asn/ao.txt

	wget -O ap.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ap.cidr
	mv /var/www/ap.txt /var/www/asn/ap.txt

	wget -O aq.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/aq.cidr
	mv /var/www/aq.txt /var/www/asn/aq.txt

	wget -O ar.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ar.cidr
	mv /var/www/ar.txt /var/www/asn/ar.txt

	wget -O as.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/as.cidr
	mv /var/www/as.txt /var/www/asn/as.txt

	wget -O at.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/at.cidr
	mv /var/www/at.txt /var/www/asn/at.txt

	wget -O au.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/au.cidr
	mv /var/www/au.txt /var/www/asn/au.txt

	wget -O aw.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/aw.cidr
	mv /var/www/aw.txt /var/www/asn/aw.txt

	wget -O ax.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ax.cidr
	mv /var/www/ax.txt /var/www/asn/ax.txt

	wget -O az.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/az.cidr
	mv /var/www/az.txt /var/www/asn/az.txt

	wget -O ba.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ba.cidr
	mv /var/www/ba.txt /var/www/asn/ba.txt

	wget -O bb.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bb.cidr
	mv /var/www/bb.txt /var/www/asn/bb.txt

	wget -O bd.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bd.cidr
	mv /var/www/bd.txt /var/www/asn/bd.txt

	wget -O be.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/be.cidr
	mv /var/www/be.txt /var/www/asn/be.txt

	wget -O bf.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bf.cidr
	mv /var/www/bf.txt /var/www/asn/bf.txt

	wget -O bg.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bg.cidr
	mv /var/www/bg.txt /var/www/asn/bg.txt

	wget -O bh.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bh.cidr
	mv /var/www/bh.txt /var/www/asn/bh.txt

	wget -O bi.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bi.cidr
	mv /var/www/bi.txt /var/www/asn/bi.txt

	wget -O bj.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bj.cidr
	mv /var/www/bj.txt /var/www/asn/bj.txt

	wget -O bl.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bl.cidr
	mv /var/www/bl.txt /var/www/asn/bl.txt

	wget -O bm.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bm.cidr
	mv /var/www/bm.txt /var/www/asn/bm.txt

	wget -O bn.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bn.cidr
	mv /var/www/bn.txt /var/www/asn/bn.txt

	wget -O bo.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bo.cidr
	mv /var/www/bo.txt /var/www/asn/bo.txt

	wget -O bq.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bq.cidr
	mv /var/www/bq.txt /var/www/asn/bq.txt

	wget -O br.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/br.cidr
	mv /var/www/br.txt /var/www/asn/br.txt

	wget -O bs.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bs.cidr
	mv /var/www/bs.txt /var/www/asn/bs.txt

	wget -O bt.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bt.cidr
	mv /var/www/bt.txt /var/www/asn/bt.txt

	wget -O bw.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bw.cidr
	mv /var/www/bw.txt /var/www/asn/bw.txt

	wget -O by.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/by.cidr
	mv /var/www/by.txt /var/www/asn/by.txt

	wget -O bz.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/bz.cidr
	mv /var/www/bz.txt /var/www/asn/bz.txt

	wget -O ca.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ca.cidr
	mv /var/www/ca.txt /var/www/asn/ca.txt

	wget -O cd.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cd.cidr
	mv /var/www/cd.txt /var/www/asn/cd.txt

	wget -O cf.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cf.cidr
	mv /var/www/cf.txt /var/www/asn/cf.txt

	wget -O cg.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cg.cidr
	mv /var/www/cg.txt /var/www/asn/cg.txt

	wget -O ch.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ch.cidr
	mv /var/www/ch.txt /var/www/asn/ch.txt

	wget -O ci.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ci.cidr
	mv /var/www/ci.txt /var/www/asn/ci.txt

	wget -O ck.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ck.cidr
	mv /var/www/ck.txt /var/www/asn/ck.txt

	wget -O cl.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cl.cidr
	mv /var/www/cl.txt /var/www/asn/cl.txt

	wget -O cm.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cm.cidr
	mv /var/www/cm.txt /var/www/asn/cm.txt

	wget -O cn.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cn.cidr
	mv /var/www/cn.txt /var/www/asn/cn.txt

	wget -O co.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/co.cidr
	mv /var/www/co.txt /var/www/asn/co.txt

	wget -O cr.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cr.cidr
	mv /var/www/cr.txt /var/www/asn/cr.txt

	wget -O cu.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cu.cidr
	mv /var/www/cu.txt /var/www/asn/cu.txt

	wget -O cv.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cv.cidr
	mv /var/www/cv.txt /var/www/asn/cv.txt

	wget -O cw.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cw.cidr
	mv /var/www/cw.txt /var/www/asn/cw.txt

	wget -O cy.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cy.cidr
	mv /var/www/cy.txt /var/www/asn/cy.txt

	wget -O cz.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/cz.cidr
	mv /var/www/cz.txt /var/www/asn/cz.txt

	wget -O dj.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/dj.cidr
	mv /var/www/dj.txt /var/www/asn/dj.txt

	wget -O dk.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/dk.cidr
	mv /var/www/dk.txt /var/www/asn/dk.txt

	wget -O dm.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/dm.cidr
	mv /var/www/dm.txt /var/www/asn/dm.txt

	wget -O do.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/do.cidr
	mv /var/www/do.txt /var/www/asn/do.txt

	wget -O dz.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/dz.cidr
	mv /var/www/dz.txt /var/www/asn/dz.txt

	wget -O ec.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ec.cidr
	mv /var/www/ec.txt /var/www/asn/ec.txt

	wget -O ee.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ee.cidr
	mv /var/www/ee.txt /var/www/asn/ee.txt

	wget -O eg.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/eg.cidr
	mv /var/www/eg.txt /var/www/asn/eg.txt

	wget -O er.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/er.cidr
	mv /var/www/er.txt /var/www/asn/er.txt

	wget -O es.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/es.cidr
	mv /var/www/es.txt /var/www/asn/es.txt

	wget -O et.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/et.cidr
	mv /var/www/et.txt /var/www/asn/et.txt

	wget -O eu.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/eu.cidr
	mv /var/www/eu.txt /var/www/asn/eu.txt

	wget -O fi.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/fi.cidr
	mv /var/www/fi.txt /var/www/asn/fi.txt

	wget -O fj.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/fj.cidr
	mv /var/www/fj.txt /var/www/asn/fj.txt

	wget -O fk.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/fk.cidr
	mv /var/www/fk.txt /var/www/asn/fk.txt

	wget -O fm.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/fm.cidr
	mv /var/www/fm.txt /var/www/asn/fm.txt

	wget -O fo.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/fo.cidr
	mv /var/www/fo.txt /var/www/asn/fo.txt

	wget -O fr.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/fr.cidr
	mv /var/www/fr.txt /var/www/asn/fr.txt

	wget -O ga.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ga.cidr
	mv /var/www/ga.txt /var/www/asn/ga.txt

	wget -O gb.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gb.cidr
	mv /var/www/gb.txt /var/www/asn/gb.txt

	wget -O gd.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gd.cidr
	mv /var/www/gd.txt /var/www/asn/gd.txt

	wget -O ge.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ge.cidr
	mv /var/www/ge.txt /var/www/asn/ge.txt

	wget -O gf.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gf.cidr
	mv /var/www/gf.txt /var/www/asn/gf.txt

	wget -O gg.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gg.cidr
	mv /var/www/gg.txt /var/www/asn/gg.txt

	wget -O gh.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gh.cidr
	mv /var/www/gh.txt /var/www/asn/gh.txt

	wget -O gi.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gi.cidr
	mv /var/www/gi.txt /var/www/asn/gi.txt

	wget -O gl.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gl.cidr
	mv /var/www/gl.txt /var/www/asn/gl.txt

	wget -O gm.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gm.cidr
	mv /var/www/gm.txt /var/www/asn/gm.txt

	wget -O gn.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gn.cidr
	mv /var/www/gn.txt /var/www/asn/gn.txt

	wget -O gp.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gp.cidr
	mv /var/www/gp.txt /var/www/asn/gp.txt

	wget -O gq.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gq.cidr
	mv /var/www/gq.txt /var/www/asn/gq.txt

	wget -O gr.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gr.cidr
	mv /var/www/gr.txt /var/www/asn/gr.txt

	wget -O gt.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gt.cidr
	mv /var/www/gt.txt /var/www/asn/gt.txt

	wget -O gu.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gu.cidr
	mv /var/www/gu.txt /var/www/asn/gu.txt

	wget -O gw.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gw.cidr
	mv /var/www/gw.txt /var/www/asn/gw.txt

	wget -O gy.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/gy.cidr
	mv /var/www/gy.txt /var/www/asn/gy.txt

	wget -O hk.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/hk.cidr
	mv /var/www/hk.txt /var/www/asn/hk.txt

	wget -O hn.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/hn.cidr
	mv /var/www/hn.txt /var/www/asn/hn.txt

	wget -O hr.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/hr.cidr
	mv /var/www/hr.txt /var/www/asn/hr.txt

	wget -O ht.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ht.cidr
	mv /var/www/ht.txt /var/www/asn/ht.txt

	wget -O hu.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/hu.cidr
	mv /var/www/hu.txt /var/www/asn/hu.txt

	wget -O id.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/id.cidr
	mv /var/www/id.txt /var/www/asn/id.txt

	wget -O ie.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ie.cidr
	mv /var/www/ie.txt /var/www/asn/ie.txt

	wget -O il.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/il.cidr
	mv /var/www/il.txt /var/www/asn/il.txt

	wget -O im.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/im.cidr
	mv /var/www/im.txt /var/www/asn/im.txt

	wget -O in.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/in.cidr
	mv /var/www/in.txt /var/www/asn/in.txt

	wget -O io.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/io.cidr
	mv /var/www/io.txt /var/www/asn/io.txt

	wget -O iq.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/iq.cidr
	mv /var/www/iq.txt /var/www/asn/iq.txt

	wget -O ir.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ir.cidr
	mv /var/www/ir.txt /var/www/asn/ir.txt

	wget -O is.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/is.cidr
	mv /var/www/is.txt /var/www/asn/is.txt

	wget -O it.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/it.cidr
	mv /var/www/it.txt /var/www/asn/it.txt

	wget -O je.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/je.cidr
	mv /var/www/je.txt /var/www/asn/je.txt

	wget -O jm.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/jm.cidr
	mv /var/www/jm.txt /var/www/asn/jm.txt

	wget -O jo.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/jo.cidr
	mv /var/www/jo.txt /var/www/asn/jo.txt

	wget -O jp.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/jp.cidr
	mv /var/www/jp.txt /var/www/asn/jp.txt

	wget -O ke.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ke.cidr
	mv /var/www/ke.txt /var/www/asn/ke.txt

	wget -O kg.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/kg.cidr
	mv /var/www/kg.txt /var/www/asn/kg.txt

	wget -O kh.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/kh.cidr
	mv /var/www/kh.txt /var/www/asn/kh.txt

	wget -O ki.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ki.cidr
	mv /var/www/ki.txt /var/www/asn/ki.txt

	wget -O km.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/km.cidr
	mv /var/www/km.txt /var/www/asn/km.txt

	wget -O kn.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/kn.cidr
	mv /var/www/kn.txt /var/www/asn/kn.txt

	wget -O kp.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/kp.cidr
	mv /var/www/kp.txt /var/www/asn/kp.txt

	wget -O kr.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/kr.cidr
	mv /var/www/kr.txt /var/www/asn/kr.txt

	wget -O kw.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/kw.cidr
	mv /var/www/kw.txt /var/www/asn/kw.txt
	
	wget -O ky.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ky.cidr
	mv /var/www/ky.txt /var/www/asn/ky.txt

	wget -O kz.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/kz.cidr
	mv /var/www/kz.txt /var/www/asn/kz.txt

	wget -O la.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/la.cidr
	mv /var/www/la.txt /var/www/asn/la.txt

	wget -O lb.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/lb.cidr
	mv /var/www/lb.txt /var/www/asn/lb.txt

	wget -O lc.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/lc.cidr
	mv /var/www/lc.txt /var/www/asn/lc.txt
	
	wget -O li.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/li.cidr
	mv /var/www/li.txt /var/www/asn/li.txt

	wget -O lk.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/lk.cidr
	mv /var/www/lk.txt /var/www/asn/lk.txt

	wget -O lr.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/lr.cidr
	mv /var/www/lr.txt /var/www/asn/lr.txt

	wget -O ls.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ls.cidr
	mv /var/www/ls.txt /var/www/asn/ls.txt

	wget -O lt.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/lt.cidr
	mv /var/www/lt.txt /var/www/asn/lt.txt
	
	wget -O lu.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/lu.cidr
	mv /var/www/lu.txt /var/www/asn/lu.txt

	wget -O lv.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/lv.cidr
	mv /var/www/lv.txt /var/www/asn/lv.txt

	wget -O ly.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ly.cidr
	mv /var/www/ly.txt /var/www/asn/ly.txt

	wget -O ma.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ma.cidr
	mv /var/www/ma.txt /var/www/asn/ma.txt

	wget -O mc.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mc.cidr
	mv /var/www/mc.txt /var/www/asn/mc.txt
	
	wget -O md.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/md.cidr
	mv /var/www/md.txt /var/www/asn/md.txt

	wget -O me.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/me.cidr
	mv /var/www/me.txt /var/www/asn/me.txt

	wget -O mf.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mf.cidr
	mv /var/www/mf.txt /var/www/asn/mf.txt

	wget -O mg.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mg.cidr
	mv /var/www/mg.txt /var/www/asn/mg.txt

	wget -O mh.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mh.cidr
	mv /var/www/mh.txt /var/www/asn/mh.txt
	
	wget -O mk.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mk.cidr
	mv /var/www/mk.txt /var/www/asn/mk.txt

	wget -O ml.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ml.cidr
	mv /var/www/ml.txt /var/www/asn/ml.txt

	wget -O mm.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mm.cidr
	mv /var/www/mm.txt /var/www/asn/mm.txt

	wget -O mn.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mn.cidr
	mv /var/www/mn.txt /var/www/asn/mn.txt

	wget -O mo.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mo.cidr
	mv /var/www/mo.txt /var/www/asn/mo.txt
	
	wget -O mp.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mp.cidr
	mv /var/www/mp.txt /var/www/asn/mp.txt

	wget -O mq.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mq.cidr
	mv /var/www/mq.txt /var/www/asn/mq.txt

	wget -O mr.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mr.cidr
	mv /var/www/mr.txt /var/www/asn/mr.txt

	wget -O ms.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ms.cidr
	mv /var/www/ms.txt /var/www/asn/ms.txt

	wget -O mt.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mt.cidr
	mv /var/www/mt.txt /var/www/asn/mt.txt
	
	wget -O mu.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mu.cidr
	mv /var/www/mu.txt /var/www/asn/mu.txt

	wget -O mv.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mv.cidr
	mv /var/www/mv.txt /var/www/asn/mv.txt

	wget -O mw.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mw.cidr
	mv /var/www/mw.txt /var/www/asn/mw.txt

	wget -O mx.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mx.cidr
	mv /var/www/mx.txt /var/www/asn/mx.txt

	wget -O my.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/my.cidr
	mv /var/www/my.txt /var/www/asn/my.txt
	
	wget -O mz.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/mz.cidr
	mv /var/www/mz.txt /var/www/asn/mz.txt

	wget -O na.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/na.cidr
	mv /var/www/na.txt /var/www/asn/na.txt

	wget -O nc.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/nc.cidr
	mv /var/www/nc.txt /var/www/asn/nc.txt
	
	wget -O ne.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ne.cidr
	mv /var/www/ne.txt /var/www/asn/ne.txt
	
	wget -O nf.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/nf.cidr
	mv /var/www/nf.txt /var/www/asn/nf.txt
	
	wget -O ng.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ng.cidr
	mv /var/www/ng.txt /var/www/asn/ng.txt
	
	wget -O ni.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ni.cidr
	mv /var/www/ni.txt /var/www/asn/ni.txt
	
	wget -O nl.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/nl.cidr
	mv /var/www/nl.txt /var/www/asn/nl.txt
	
	wget -O no.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/no.cidr
	mv /var/www/no.txt /var/www/asn/no.txt
	
	wget -O np.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/np.cidr
	mv /var/www/np.txt /var/www/asn/np.txt
	
	wget -O nr.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/nr.cidr
	mv /var/www/nr.txt /var/www/asn/nr.txt
	
	wget -O nu.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/nu.cidr
	mv /var/www/nu.txt /var/www/asn/nu.txt
	
	wget -O nz.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/nz.cidr
	mv /var/www/nz.txt /var/www/asn/nz.txt
	
	wget -O om.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/om.cidr
	mv /var/www/om.txt /var/www/asn/om.txt
	
	wget -O pa.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/pa.cidr
	mv /var/www/pa.txt /var/www/asn/pa.txt
	
	wget -O pe.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/pe.cidr
	mv /var/www/pe.txt /var/www/asn/pe.txt
	
	wget -O pf.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/pf.cidr
	mv /var/www/pf.txt /var/www/asn/pf.txt
	
	wget -O pg.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/pg.cidr
	mv /var/www/pg.txt /var/www/asn/pg.txt
	
	wget -O ph.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ph.cidr
	mv /var/www/ph.txt /var/www/asn/ph.txt
	
	wget -O pk.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/pk.cidr
	mv /var/www/pk.txt /var/www/asn/pk.txt
	
	wget -O pl.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/pl.cidr
	mv /var/www/pl.txt /var/www/asn/pl.txt
	
	wget -O pm.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/pm.cidr
	mv /var/www/pm.txt /var/www/asn/pm.txt
	
	wget -O pr.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/pr.cidr
	mv /var/www/pr.txt /var/www/asn/pr.txt
	
	wget -O ps.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ps.cidr
	mv /var/www/ps.txt /var/www/asn/ps.txt
	
	wget -O pt.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/pt.cidr
	mv /var/www/pt.txt /var/www/asn/pt.txt
	
	wget -O pw.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/pw.cidr
	mv /var/www/pw.txt /var/www/asn/pw.txt
	
	wget -O py.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/py.cidr
	mv /var/www/py.txt /var/www/asn/py.txt
	
	wget -O qa.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/qa.cidr
	mv /var/www/qa.txt /var/www/asn/qa.txt
	
	wget -O re.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/re.cidr
	mv /var/www/re.txt /var/www/asn/re.txt
	
	wget -O ro.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ro.cidr
	mv /var/www/ro.txt /var/www/asn/ro.txt
	
	wget -O rs.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/rs.cidr
	mv /var/www/rs.txt /var/www/asn/rs.txt
	
	wget -O ru.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ru.cidr
	mv /var/www/ru.txt /var/www/asn/ru.txt

	wget -O rw.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/rw.cidr
	mv /var/www/rw.txt /var/www/asn/rw.txt
	
	wget -O sa.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sa.cidr
	mv /var/www/sa.txt /var/www/asn/sa.txt
	
	wget -O sb.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sb.cidr
	mv /var/www/sb.txt /var/www/asn/sb.txt
	
	wget -O sc.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sc.cidr
	mv /var/www/sc.txt /var/www/asn/sc.txt
	
	wget -O sd.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sd.cidr
	mv /var/www/sd.txt /var/www/asn/sd.txt
	
	wget -O se.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/se.cidr
	mv /var/www/se.txt /var/www/asn/se.txt
	
	wget -O sg.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sg.cidr
	mv /var/www/sg.txt /var/www/asn/sg.txt
	
	wget -O si.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/si.cidr
	mv /var/www/si.txt /var/www/asn/si.txt
	
	wget -O sk.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sk.cidr
	mv /var/www/sk.txt /var/www/asn/sk.txt
	
	wget -O sl.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sl.cidr
	mv /var/www/sl.txt /var/www/asn/sl.txt
	
	wget -O sm.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sm.cidr
	mv /var/www/sm.txt /var/www/asn/sm.txt
	
	wget -O sn.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sn.cidr
	mv /var/www/sn.txt /var/www/asn/sn.txt
	
	wget -O so.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/so.cidr
	mv /var/www/so.txt /var/www/asn/so.txt
	
	wget -O sr.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sr.cidr
	mv /var/www/sr.txt /var/www/asn/sr.txt
	
	wget -O ss.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ss.cidr
	mv /var/www/ss.txt /var/www/asn/ss.txt
	
	wget -O st.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/st.cidr
	mv /var/www/st.txt /var/www/asn/st.txt
	
	wget -O sv.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sv.cidr
	mv /var/www/sv.txt /var/www/asn/sv.txt
	
	wget -O sx.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sx.cidr
	mv /var/www/sx.txt /var/www/asn/sx.txt
	
	wget -O sy.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sy.cidr
	mv /var/www/sy.txt /var/www/asn/sy.txt
	
	wget -O sz.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/sz.cidr
	mv /var/www/sz.txt /var/www/asn/sz.txt
	
	wget -O tc.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/tc.cidr
	mv /var/www/tc.txt /var/www/asn/tc.txt
	
	wget -O td.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/td.cidr
	mv /var/www/td.txt /var/www/asn/td.txt
	
	wget -O tg.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/tg.cidr
	mv /var/www/tg.txt /var/www/asn/tg.txt
	
	wget -O th.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/th.cidr
	mv /var/www/th.txt /var/www/asn/th.txt
	
	wget -O tj.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/tj.cidr
	mv /var/www/tj.txt /var/www/asn/tj.txt
	
	wget -O tk.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/tk.cidr
	mv /var/www/tk.txt /var/www/asn/tk.txt
	
	wget -O tl.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/tl.cidr
	mv /var/www/tl.txt /var/www/asn/tl.txt
	
	wget -O tm.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/tm.cidr
	mv /var/www/tm.txt /var/www/asn/tm.txt
	
	wget -O tn.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/tn.cidr
	mv /var/www/tn.txt /var/www/asn/tn.txt
	
	wget -O to.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/to.cidr
	mv /var/www/to.txt /var/www/asn/to.txt
	
	wget -O tr.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/tr.cidr
	mv /var/www/tr.txt /var/www/asn/tr.txt
	
	wget -O tt.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/tt.cidr
	mv /var/www/tt.txt /var/www/asn/tt.txt
	
	wget -O tv.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/tv.cidr
	mv /var/www/tv.txt /var/www/asn/tv.txt
	
	wget -O tw.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/tw.cidr
	mv /var/www/tw.txt /var/www/asn/tw.txt
	
	wget -O tz.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/tz.cidr
	mv /var/www/tz.txt /var/www/asn/tz.txt
	
	wget -O ua.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ua.cidr
	mv /var/www/ua.txt /var/www/asn/ua.txt
	
	wget -O ug.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ug.cidr
	mv /var/www/ug.txt /var/www/asn/ug.txt
	
	wget -O uy.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/uy.cidr
	mv /var/www/uy.txt /var/www/asn/uy.txt
	
	wget -O uz.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/uz.cidr
	mv /var/www/uz.txt /var/www/asn/uz.txt
	
	wget -O va.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/va.cidr
	mv /var/www/va.txt /var/www/asn/va.txt
	
	wget -O vc.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/vc.cidr
	mv /var/www/vc.txt /var/www/asn/vc.txt
	
	wget -O ve.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ve.cidr
	mv /var/www/ve.txt /var/www/asn/ve.txt
	
	wget -O vg.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/vg.cidr
	mv /var/www/vg.txt /var/www/asn/vg.txt
	
	wget -O vi.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/vi.cidr
	mv /var/www/vi.txt /var/www/asn/vi.txt
	
	wget -O vn.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/vn.cidr
	mv /var/www/vn.txt /var/www/asn/vn.txt
	
	wget -O vu.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/vu.cidr
	mv /var/www/vu.txt /var/www/asn/vu.txt
	
	wget -O wf.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/wf.cidr
	mv /var/www/wf.txt /var/www/asn/wf.txt
	
	wget -O ws.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ws.cidr
	mv /var/www/ws.txt /var/www/asn/ws.txt
	
	wget -O ye.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ye.cidr
	mv /var/www/ye.txt /var/www/asn/ye.txt
	
	wget -O yt.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/yt.cidr
	mv /var/www/yt.txt /var/www/asn/yt.txt
	
	wget -O za.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/za.cidr
	mv /var/www/za.txt /var/www/asn/za.txt
	
	wget -O zm.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/zm.cidr
	mv /var/www/zm.txt /var/www/asn/zm.txt
	
	wget -O zw.txt https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/zw.cidr
	mv /var/www/zw.txt /var/www/asn/zw.txt
	
else
	echo -e "\n\n***************************************"
	echo "Skipping Geography Block Lists"
	echo -e "***************************************\n\n"
fi 

# Combine all text files
echo -e "\n\n***************************************"
echo "Combining all text files"
echo -e "***************************************\n\n"
cd /var/www/asn/
cat *.txt > /var/www/blocked.ip.list2

#export current ufw listing
echo -e "\n\n***************************************"
echo "export current ufw listing"
echo -e "***************************************\n\n"
ufw status numbered | tee /var/www/asn/current_ufw.txt

#delete header of ufw status, which are the first four lines of the file
echo -e "\n\n***************************************"
echo "delete header of ufw status"
echo -e "***************************************\n\n"
sed -i 1,4d /var/www/asn/current_ufw.txt

#search through all of the downloaded ASN entries to find ones not already in the UFW configuration
echo -e "\n\n*********************************************************************************************"
echo "search through all of the downloaded ASN entries to find ones not already in the UFW configuration"
echo -e "*********************************************************************************************\n\n"
while IFS= read -r block
do
	if grep -wq "$block" /var/www/asn/current_ufw.txt; then 
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
done < "/var/www/blocked.ip.list2"


#search through all of the UFW configuration, and remove entries not contained in the ASN list 
echo -e "\n\n*********************************************************************************************"
echo "search through all of the UFW configuration, and remove entries not contained in the ASN list "
echo -e "*********************************************************************************************\n\n"
while IFS= read -r block2
do
	string=$(echo "${block2##*IN}" | xargs) #remove everything from the line except for the IP address
	if grep -wq "$string" /var/www/blocked.ip.list2; then 
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
done < "/var/www/asn/current_ufw.txt"

#cleanup unneeded files
echo -e "\n\n***************************************"
echo "cleanup unneeded files"
echo -e "***************************************\n\n"
if [[ "$test_mode" -eq 0 ]]; then
	cd /var/www/
	rm -r /var/www/asn/
else
	echo "skipping file cleanup"
fi





