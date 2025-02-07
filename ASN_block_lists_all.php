<?php
//*****************************************************************
//USER VARIABLES
//*****************************************************************

//need to add: 

chdir("/volume1/web/ASN_lists"); //location on server where the ASN files will be saved to. Ensure this directory has write permissions for the web-server running this PHP script
$refresh_data=true; //pull new data from online resources?
$debug=false; //create debug output showing address vs entry in the files
$download_hetzner=true;

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
	if ($currentFile != "." && $currentFile != ".." && $currentFile != "" && $currentFile != "ASN_block_lists_all.php" && $currentFile != "ufw_update.sh"){
		if ($refresh_data){
			//if we are refreshing data, delete all files including the files previously downloaded 
			unlink("/volume1/web/ASN_lists/".$currentFile."");
		}else{
			//if we are NOT refreshing data, then we do NOT want to delete any of the "master" files downloaded from the internet
			if(!str_contains($currentFile, 'ASN_master')){
				unlink("/volume1/web/ASN_lists/".$currentFile."");
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
		$mail->Subject = "New File - ASN Block Lists";
		$mail->Body    = "New ASN Block List File \"".$file_name."\" has been added";
		$mail->AltBody = "New ASN Block List File \"".$file_name."\" has been added";

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
	//if (urlExists($URL_local)){
		$counter =0;
		if (($myfile = @fopen($URL_local, "r"))!==false ) {
			if ( !$myfile ) {
				print "<p style=\"color:red;\">".$URL_local." could not be opened</p>";
			}else{
				while(!feof($myfile)) {
					
					$subject = fgets($myfile);

					//determine if we saved any bytes of data to the file. if we did, then something probably downloaded correctly, if there is no data in the file, then something must have went wrong. 
					$counter = $counter + file_put_contents($outputfile_local, $subject, FILE_APPEND);
				}
				if ($counter == 0){
					print "<p style=\"color:red;\">".$URL_local." returned zero bytes</p>";
				}
				fclose($myfile);
			}
		}else{
			print "<p style=\"color:red;\">".$URL_local." contents could not be downloaded</p>";
		}
	//}else{
	//	print "<p style=\"color:red;\">".$URL_local." did not return as available</p>";
	//}
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
		$character = " ";
	   $line = preg_replace('/' . preg_quote($character, '/') . '.*/', '', $line);
	   $character = "<";
	   $line = preg_replace('/' . preg_quote($character, '/') . '.*/', '', $line);
	   
	   //some lines already have a return character at the end of the line, we do not want this so let's remove it. 
	   $character = "\r";
	   $line = preg_replace('/' . preg_quote($character, '/') . '.*/', '', $line);
		
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


$outputfile = 'ASN_master1.txt';
if ($refresh_data){
	$URL="https://asn.ipinfo.app/api/text/list/AS44477";
	file_put_contents($outputfile, "");
	download_data($outputfile, $URL);

	$URL="https://asn.ipinfo.app/api/text/list/AS22612";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS12312";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS64419";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS204957";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS61112";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS8100";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS16276";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS35540";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS394814";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS35478";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS22384";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS46562";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS39486";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS44144";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS133499";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS134450";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS203020";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS204287";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS207990";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS11878";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS6939";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS60068";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS212238";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS211612";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS50446";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS9009";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS16247";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS42973";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS35536";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS9312";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS8888";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS6233";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS4785";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS3258";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS3214";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS949";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS14315";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS18779";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS7005";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS26666";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS13335";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS202623";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS395747";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS62651";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS54203";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS54138";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS50667";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS31362";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS13926";
	download_data($outputfile, $URL);
	
	
	if ($download_hetzner) {
	
		$URL="https://asn.ipinfo.app/api/text/list/AS24940"; 
		download_data($outputfile, $URL);
		
		$URL="https://asn.ipinfo.app/api/text/list/AS212317";
		download_data($outputfile, $URL);
		
		$URL="https://asn.ipinfo.app/api/text/list/AS213230"; 
		download_data($outputfile, $URL);
	}else{
		print "skipping Hetzner ASNs";
	}
	
	
	
	$URL="https://asn.ipinfo.app/api/text/list/AS213006";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS213005";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS212862";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS212861";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS204286";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS202636";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS200908";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS17470";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS209372";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS45887";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS48337";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS63949";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS61317";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS263735";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS263740";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS14061";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS14576";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS8075";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS62240";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS36352";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS12876";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS37518";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS132203";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS45090";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS55286";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS210558";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS206092";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS26548";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS137409";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS14576";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS40861";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS36007";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS24961";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS39572";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS5384";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS8966";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS834";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS932";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS6134";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS15828";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS17048";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS27524";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS33333";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS35624";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS3223";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS3842";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS4694";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS5577";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS6724";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS7203";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS7489";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS7506";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS7850";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS7979";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS8455";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS8560";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS9370";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS10297";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS10439";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS11831";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS12586";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS13213";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS13739";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS14127";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS14618";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS16509";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS15083";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS15169";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS15395";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS15497";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS15510";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS15626";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS16125";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS16262";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS16628";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS17216";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS18450";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS18978";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS19084";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS19318";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS19437";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS19531";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS19624";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS19871";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS19969";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS20021";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS20264";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS20454";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS20473";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS20598";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS21859";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS22363";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS22552";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS22781";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS23033";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS23342";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS23352";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS25780";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS29838";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS29854";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS30083";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS30475";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS30633";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS32097";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS32181";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS32244";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS32475";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS32780";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS33083";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS33182";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS33302";
	download_data($outputfile, $URL);
	
	//$URL="https://asn.ipinfo.app/api/text/list/AS33330";
	//download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS33480";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS33724";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS35908";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS35916";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS36114";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS36351";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS36666";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS40156";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS40244";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS40676";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS40824";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS46261";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS46475";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS46664";
	download_data($outputfile, $URL);
	
	//$URL="https://asn.ipinfo.app/api/text/list/AS46816";
	//download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS46844";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS53340";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS53559";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS53597";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS53667";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS53755";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS53850";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS54455";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS54489";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS54500";
	download_data($outputfile, $URL);
	
	//$URL="https://asn.ipinfo.app/api/text/list/AS62471";
	//download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS63018";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS63199";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS63473";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS64245";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS394380";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS395111";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS35830";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS45102";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS206728";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS398722";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS212027";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS142002";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS398324";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS51167";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS208091";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS214422";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS396356";
	download_data($outputfile, $URL);

	$URL="https://asn.ipinfo.app/api/text/list/AS62744";
	download_data($outputfile, $URL);
		
	$URL="https://asn.ipinfo.app/api/text/list/AS56971";
	download_data($outputfile, $URL);
		
	$URL="https://asn.ipinfo.app/api/text/list/AS210644";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS47890";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS29802";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS14956";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS62904";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS200373";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS984";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS24669";
	download_data($outputfile, $URL);
	
	$URL="https://asn.ipinfo.app/api/text/list/AS62240 ";
	download_data($outputfile, $URL);
}

$domains_blocked_counter=$domains_blocked_counter + process_data($outputfile, "web_block1", $debug, $theFiles, $email_address, $smtp_server, $SMTPAuth_type, $smtp_user, $smtp_pass, $SMTPSecure_type, $smtp_port, $from_email_address);

//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************


//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************
//*******************************************************************************************************************

print "<H1 style=\"color:red;\">TOTAL DOMAINS BLOCKED: ".$domains_blocked_counter."</H1>";


?>
