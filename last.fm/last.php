<?php
	$dirlist = scandir("/home/pranav/.gvfs/SFTP for sdslabs on 192.168.208.206/media/Data/Muzi/English");
	chdir("/home/pranav/.gvfs/SFTP for sdslabs on 192.168.208.206/media/Data/Muzi/English");
	foreach ($dirlist as $v){if($v != "." && $v != ".."){
		$dir = scandir($v);
		foreach ($dir as $a){if($a != "." && $a != ".."){
			if(is_dir($v.'/'.$a)){
				if(file_exists($v.'/'.$a.'/lastfm_cover.jpg') || file_exists($v.'/'.$a.'/lastfm_cover.png')){
					echo "file already exists\n";
				}
				else{
					$u = "http://ws.audioscrobbler.com/2.0/?method=album.getinfo&format=json&api_key=b25b959554ed76058ac220b7b2e0a026&artist=".urlencode($v)."&album=".urlencode($a);
					$c = json_decode(file_get_contents($u),true);
					if(isset($c['album'])){
						$picurl = $c['album']['image'][3]['#text'];
						echo "loading from ".$picurl."\n";
						if(strlen($picurl) != 0){
						$ext = explode(".",strrev($picurl));
						$ext = strrev($ext[0]);
						
						$addr = escapeshellarg("/home/pranav/.gvfs/SFTP for sdslabs on 192.168.208.206/media/Data/Muzi/English/".$v."/".$a."/lastfm_cover.".$ext);
						`wget -O $addr "$picurl"`;
						echo "saving to /media/Data/Muzi/English/".$v."/".$a."/lastfm_cover.".$ext."\n\n";
					}}
					else{
						echo "album not found\n";
					}
			}}
		}}
	}}

?>
