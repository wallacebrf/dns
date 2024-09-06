<?php
//*****************************************************************
//USER VARIABLES
//*****************************************************************

chdir("/volume1/web/DNS_FG-91G"); //location on server where the DNS files will be saved to. Ensure this directory has write permissions for the web-server running this PHP script
$refresh_data=true; //pull new data from online resources?
$debug=false; //create debug output showing address vs entry in the files

//influxdb data user variables
//we will log the total number of blocked domains saved to file to influx to see how the number of domains changes over time
//note this only supports inlfuxdb version 2. 
$snmp_device_name="FG-91G";
$measurement="fortigate_blocked_domains";
$influxdb_host="localhost";
$influxdb_port="8086";
$influxdb_pass="password";
$influxdb_name="db_name";
$influxdb_http_type="http";
$influxdb_org="org";

//email variables
$email_address="email@email.com";
$smtp_server="mail.com";	
$SMTPAuth_type=1;
$smtp_user="user";
$smtp_pass="pass";
$SMTPSecure_type="ENCRYPTION_STARTTLS";
$smtp_port=587;
$from_email_address="from@email.com";

//note: due to the memory limits of default PHP server settings, the various websites below have been broken into six groups. 
//this is done to prevent the "master" files from exceeding ~12MB in size. this is because the "master" files are read back into memory after being downloaded and exploded into an array
//the array cannot exceed the PHP memory limits or the script will fail. edit/adjust the various websites downloaded as desired. 


//*****************************************************************
//SCRIPT START
//*****************************************************************

//function to determine if a website is available or not
//got code from https://stackoverflow.com/questions/24270027/how-to-check-if-website-is-accessible
function urlExists($url=NULL)  
{  
    if($url == NULL) return false;  
    $ch = curl_init($url);  
    curl_setopt($ch, CURLOPT_TIMEOUT, 5);  
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);  
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);  
    $data = curl_exec($ch);  
    $httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);  
    curl_close($ch);  
    if($httpcode>=200 && $httpcode<300){  
        return true;  
    } else {  
        return false;  
    }  
}  

//download the data from the desired URL block list
function download_data($outputfile_local, $URL_local){
	//if (urlExists($URL_local)){
		$counter =0;
		//$myfile = fopen($URL_local, "r");
		if (($myfile = @fopen($URL_local, "r"))!==false ) {
			if ( !$myfile ) {
				print "<p style=\"color:red;\">".$URL_local." could not be opened</p>";
			}else{
				while(!feof($myfile)) {

					//a lot of these lists are hosts lists so they have a IP address etc. prior to the domain name. this is going to search for and remove this information. 
					//this needs to be done as the fortigate external threat connectors just wants a simple list of domain names and or IP addresses only. 
					//they are not able to process the host file data format. 
					$search = array("127.0.0.1 ", "localhost", "::1 ", "0.0.0.0 ", "0.0.0.0", "127.0.0.1	", ".localdomain", "255.255.255.255	broadcasthost", "::1");
					$replace = array('', '', '', '', '', '', '', '', '');
					$subject = fgets($myfile);

					//determine if we saved any bytes of data to the file. if we did, then something probably downloaded correctly, if there is no data in the file, then something must have went wrong. 
					$counter = $counter + file_put_contents($outputfile_local,str_replace($search, $replace, $subject), FILE_APPEND);
				}
				if ($counter == 0){
					print "<p style=\"color:red;\">".$URL_local." returned zero bytes</p>";
				}
				fclose($myfile);
			}
		}else{
			print "<p style=\"color:red;\">".$URL_local." contents could not be downloaded</p>";
		}
}

$outputfile = 'master1.txt';
if ($refresh_data){
	$URL="https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser";
	file_put_contents($outputfile, "");
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts";
	download_data($outputfile, $URL);

	$URL="https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt";
	download_data($outputfile, $URL);

	$URL="https://v.firebog.net/hosts/Prigent-Crypto.txt";
	download_data($outputfile, $URL);

	$URL="https://urlhaus.abuse.ch/downloads/hostfile/";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt";
	download_data($outputfile, $URL);

	$URL="https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt";
	download_data($outputfile, $URL);

	$URL="https://adaway.org/hosts.txt";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt";
	download_data($outputfile, $URL);

	$URL="https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt";
	download_data($outputfile, $URL);
}

//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************

$outputfile = 'master2.txt';
if ($refresh_data){
	file_put_contents($outputfile, "");
	$URL="https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts";
	download_data($outputfile, $URL);

	$URL="https://v.firebog.net/hosts/static/w3kbl.txt";
	download_data($outputfile, $URL);

	$URL="https://v.firebog.net/hosts/AdguardDNS.txt";
	download_data($outputfile, $URL);

	$URL="https://v.firebog.net/hosts/Admiral.txt";
	download_data($outputfile, $URL);

	$URL="https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt";
	download_data($outputfile, $URL);

	$URL="https://v.firebog.net/hosts/Easylist.txt";
	download_data($outputfile, $URL);

	$URL="https://v.firebog.net/hosts/Easyprivacy.txt";
	download_data($outputfile, $URL);

	$URL="https://v.firebog.net/hosts/Prigent-Ads.txt";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/hectorm/hmirror/master/data/spam404.com/list.txt";
	download_data($outputfile, $URL);

	$URL="https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt";
	download_data($outputfile, $URL);

	$URL="https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/hectorm/hmirror/master/data/eth-phishing-detect/list.txt";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/hectorm/hmirror/master/data/anudeepnd-adservers/list.txt";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/hectorm/hmirror/master/data/adguard-simplified/list.txt";
	download_data($outputfile, $URL);
}

//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************

$outputfile = 'master3.txt';

if ($refresh_data){
	file_put_contents($outputfile, "");
	$URL="https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
	download_data($outputfile, $URL);

	$URL="https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt";
	download_data($outputfile, $URL);

	$URL="https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt";
	download_data($outputfile, $URL);

	$URL="https://phishing.army/download/phishing_army_blocklist_extended.txt";
	download_data($outputfile, $URL);
}

//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************

$outputfile = 'master4.txt';
if ($refresh_data){
	file_put_contents($outputfile, "");
	$URL="https://v.firebog.net/hosts/RPiList-Malware.txt";
	download_data($outputfile, $URL);

	$URL="https://v.firebog.net/hosts/RPiList-Phishing.txt";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt";
	download_data($outputfile, $URL);
}

//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************

$outputfile = 'master5.txt';
if ($refresh_data){
	file_put_contents($outputfile, "");
	$URL="https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt";
	download_data($outputfile, $URL);

	$URL="https://someonewhocares.org/hosts/zero/hosts";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/VeleSila/yhosts/master/hosts";
	download_data($outputfile, $URL);

	$URL="https://winhelp2002.mvps.org/hosts.txt";
	download_data($outputfile, $URL);

	$URL="https://v.firebog.net/hosts/neohostsbasic.txt";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/RooneyMcNibNug/pihole-stuff/master/SNAFU.txt";
	download_data($outputfile, $URL);

	$URL="https://paulgb.github.io/BarbBlock/blacklists/hosts-file.txt";
	download_data($outputfile, $URL);

	$URL="https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts";
	download_data($outputfile, $URL);
	
	$URL="https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/android-tracking.txt";
	download_data($outputfile, $URL);
	
	$URL="https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/SmartTV.txt";
	download_data($outputfile, $URL);
	
	$URL="https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/AmazonFireTV.txt";
	download_data($outputfile, $URL);
}

//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************
$outputfile = 'master6.txt';
if ($refresh_data){
	file_put_contents($outputfile, "");
	$URL="https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt";
	download_data($outputfile, $URL);

	$URL="https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt";
	download_data($outputfile, $URL);
}

print shell_exec("bash webblock.sh");

?>
