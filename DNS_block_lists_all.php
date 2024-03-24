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

//import needed libraries for email sending 
require '/volume1/web/admin/vendor/phpmailer/phpmailer/src/Exception.php';
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;


//get listing of all existing text files from the previous execution of the script. this will allow the script to send a notification email if a new file is created that did not previoously exist
//this is important since a new file would have to be added to a fortigate's configuration under the "external connectors" 
$currentFile="";
$theFiles=[];
//opens the directory for reading
$dp = opendir(getcwd())
	or die("<br /><font color=\"#FF0000\">Cannot Open The Directory </font><br>");
	
//add all files in directory to $theFiles array
while ($currentFile !== false){
	$currentFile = readDir($dp);
	$theFiles[] = $currentFile;
} // end while
	
//because we opened the dir, we need to close it
closedir($dp);
	
//sorts all the files
rsort ($theFiles);
	
foreach ($theFiles as $currentFile){
	if ($currentFile != "." && $currentFile != ".." && $currentFile != "list_files.php" && $currentFile != "DNS_block_lists_all.php" && $currentFile != ""){
		if ($refresh_data){
			//if we are refreshing data, delete all files including the files previously downloaded 
			unlink("/volume1/web/DNS_FG-91G/".$currentFile."");
		}else{
			//if we are NOT refreshing data, then we do NOT want to delete any of the "master" files downloaded from the internet
			if(!str_contains($currentFile, 'master')){
				unlink("/volume1/web/DNS_FG-91G/".$currentFile."");
			}
		}
	}
}


//function to send email notifications if new files are created so the fortigate external connections list can be updated
function send_email($file_name, $email_address, $smtp_server, $SMTPAuth_type, $smtp_user, $smtp_pass, $SMTPSecure_type, $smtp_port, $from_email_address){
	date_default_timezone_set('Etc/UTC');


	require "/volume1/web/admin/vendor/autoload.php";

	//Create an instance; passing `true` enables exceptions
	$mail = new PHPMailer(true);

	try {
		//Server settings
		//$mail->SMTPDebug = SMTP::DEBUG_SERVER;                      //Enable verbose debug output
		$mail->isSMTP();                                            //Send using SMTP
		$mail->Host       = ''.$smtp_server.'';                     //Set the SMTP server to send through
		if($SMTPAuth_type==1){
			$mail->SMTPAuth   = true;                                   //Enable SMTP authentication
		}else{
			$mail->SMTPAuth   = false;                                   //Disable SMTP authentication
		}
		$mail->Username   = ''.$smtp_user.'';                     //SMTP username
		$mail->Password   = ''.$smtp_pass.'';                               //SMTP password
		if($SMTPSecure_type=="ENCRYPTION_STARTTLS"){
			$mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;            //Enable implicit TLS encryption
		}else if($SMTPSecure_type=="ENCRYPTION_SMTPS"){
			$mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;            //Enable SSL
		}
		$mail->Port       = $smtp_port;                                    //TCP port to connect to; use 587 if you have set `SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS`

		//Recipients
		$mail->setFrom(''.$from_email_address.'');
		
		$mail->addAddress(''.$email_address.'');     //Add a recipient
		
		$mail->addReplyTo(''.$from_email_address.'');
			
		//Content
		$mail->isHTML(true);                                  //Set email format to HTML
		$mail->Subject = "New File - DNS Block Lists";
		$mail->Body    = "New DNS Block List File \"".$file_name."\" has been added";
		$mail->AltBody = "New DNS Block List File \"".$file_name."\" has been added";

		$mail->send();
		//echo 'Message has been sent';
	} catch (Exception $e) {
		echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
	}
}


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

$domains_blocked_counter=0;

//download the data from the desired URL block list
function download_data($outputfile_local, $URL_local){
	if (urlExists($URL_local)){
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
	}else{
		print "<p style=\"color:red;\">".$URL_local." did not return as available</p>";
	}
}

//this function is needed because the fortigate external thread connectors can handle only 131,072 entries per list
//however many lists have well over this limit. also, some sources that may be desired are much less than 131,000 entries, 
//this allows aggregating multiple small lists into one file for the fortigate to process to maximize effectiveness as fortigates are also limited to the number of external threat feeds allowed
function process_data($outputfile_local, $file_name, $debug_local, $array_to_search, $email_address, $smtp_server, $SMTPAuth_type, $smtp_user, $smtp_pass, $SMTPSecure_type, $smtp_port, $from_email_address){

	$domains_blocked_counter_local=0; //how many domains have been added per the current file?
	$data = file_get_contents($outputfile_local);
	
	$lines = explode("\n",$data); #make an array with all of the data in the file so we can process the data line by line

	$counter = 1;

	$handle = fopen( __DIR__ .'/'.$file_name.'.'.$counter.'.txt','wb');
	if (!in_array(''.$file_name.'.'.$counter.'.txt', $array_to_search)) {
		print "The file \"".$file_name.".".$counter.".txt\" is NEW!<br>";
		send_email("".$file_name.".".$counter.".txt", $email_address, $smtp_server, $SMTPAuth_type, $smtp_user, $smtp_pass, $SMTPSecure_type, $smtp_port, $from_email_address);
	}
	if ($debug_local){
		$handle2 = fopen( __DIR__ .'/'.$file_name.'.debug.'.$counter.'.txt','wb');
		if (!in_array(''.$file_name.'.debug.'.$counter.'.txt', $array_to_search)) {
			print "The file \"".$file_name.".debug.".$counter.".txt\" is NEW!<br>";
			send_email("".$file_name.".debug.".$counter.".txt", $email_address, $smtp_server, $SMTPAuth_type, $smtp_user, $smtp_pass, $SMTPSecure_type, $smtp_port, $from_email_address);
		}
	}

	$lineswritten = 0;
	foreach ($lines as $line) {
		
		//many of these lists have comments starting with the "#" character, we will remove these lines if they START with a "#"
		$character = "#";
	   $line = preg_replace('/' . preg_quote($character, '/') . '.*/', '', $line);
	   
	   //some lines already have a return character at the end of the line, we do not want this so let's remove it. 
	   $character = "\r";
	   $line = preg_replace('/' . preg_quote($character, '/') . '.*/', '', $line);
	  
	  
	  //other lines have comments or other data towards the end of the line after the domain name entry
	  //we need to remove that information, and we need to perform additional filtering to remove empty lines
	  if ($line!="" && $line!="\n" && $line!="\r" && $line!="\n\r" && $line!="\r\n" && strlen($line) > 6 && mb_strlen($line) > 6){
		  if ($lineswritten!=0) fwrite($handle, chr(0x0D).chr(0x0A)); 
		  fwrite($handle,$line);
		  $domains_blocked_counter_local=$domains_blocked_counter_local+1;
		  if ($debug_local){
			fwrite($handle2,"".$lineswritten.": \"".$line."\"\n");
		  }
		  $lineswritten = $lineswritten+1;
	  }
	  // did we write 131,000 lines? Close file, increase counter and open next output file. Note fortigate external connectors have a max line limit of 131,072, we will save slightly less than this
	  if ($lineswritten == 131000) {
		  if ($debug_local){
			echo "<br>".$file_name.".".$counter.".txt created";
		  }
		fclose($handle);
		$counter = $counter+1;
		$handle = fopen( __DIR__ .'/'.$file_name.'.'.$counter.'.txt','wb');
		if (!in_array(''.$file_name.'.'.$counter.'.txt', $array_to_search)) {
			print "The file \"".$file_name.".".$counter.".txt\" is NEW!<br>";
			send_email("".$file_name.".".$counter.".txt", $email_address, $smtp_server, $SMTPAuth_type, $smtp_user, $smtp_pass, $SMTPSecure_type, $smtp_port, $from_email_address);
		}
		$lineswritten = 0;
	  }
	}
	fclose($handle);
	if ($debug_local){
		fclose($handle2);
	}
	if ($debug_local){
		echo "<br>".$file_name.".".$counter.".txt created<br><b>Number of domains blocked in the various \"".$file_name."\" files: ".$domains_blocked_counter_local."</b>";
		echo "<br><br>";
	}
	return $domains_blocked_counter_local;
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

$domains_blocked_counter=$domains_blocked_counter + process_data($outputfile, "web_block1", $debug, $theFiles, $email_address, $smtp_server, $SMTPAuth_type, $smtp_user, $smtp_pass, $SMTPSecure_type, $smtp_port, $from_email_address);

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

$domains_blocked_counter=$domains_blocked_counter + process_data($outputfile, "web_block2", $debug, $theFiles, $email_address, $smtp_server, $SMTPAuth_type, $smtp_user, $smtp_pass, $SMTPSecure_type, $smtp_port, $from_email_address);

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

$domains_blocked_counter=$domains_blocked_counter + process_data($outputfile, "web_block3", $debug, $theFiles, $email_address, $smtp_server, $SMTPAuth_type, $smtp_user, $smtp_pass, $SMTPSecure_type, $smtp_port, $from_email_address);

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
$domains_blocked_counter=$domains_blocked_counter + process_data($outputfile, "web_block4", $debug, $theFiles, $email_address, $smtp_server, $SMTPAuth_type, $smtp_user, $smtp_pass, $SMTPSecure_type, $smtp_port, $from_email_address);

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


$domains_blocked_counter=$domains_blocked_counter + process_data($outputfile, "web_block5", $debug, $theFiles, $email_address, $smtp_server, $SMTPAuth_type, $smtp_user, $smtp_pass, $SMTPSecure_type, $smtp_port, $from_email_address);

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
$domains_blocked_counter=$domains_blocked_counter + process_data($outputfile, "web_block6", $debug, $theFiles, $email_address, $smtp_server, $SMTPAuth_type, $smtp_user, $smtp_pass, $SMTPSecure_type, $smtp_port, $from_email_address);

//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************

print "<H1 style=\"color:red;\">TOTAL DOMAINS BLOCKED: ".$domains_blocked_counter."</H1>";

//saving details of the total domains blocked count to inflixDB
$post_url="".$measurement.",snmp_device_name=$snmp_device_name domains_blocked_counter=".$domains_blocked_counter."";

shell_exec("curl -XPOST \"".$influxdb_http_type."://".$influxdb_host.":".$influxdb_port."/api/v2/write?bucket=".$influxdb_name."&org=".$influxdb_org."\" -H \"Authorization: Token ".$influxdb_pass."\" --data-raw \"".$post_url."\"");

?>
