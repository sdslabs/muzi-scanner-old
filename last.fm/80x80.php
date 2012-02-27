<?php
	$root = "/home/pranav/.gvfs/SFTP for sdslabs on 192.168.208.206/media/Data/Muzi/English";
	$dirlist = scandir($root);
	chdir($root);
	foreach ($dirlist as $v){if($v != "." && $v != ".."){
		//chdir("/home/pranav/.gvfs/SFTP for sdslabs on 192.168.208.206/media/Data/Muzi/English");
		$dir = scandir($v);
		foreach ($dir as $a){if($a != "." && $a != ".."){
			if(is_dir($v.'/'.$a)){
				$v = "A Perfect Circle";
				$a = "Thirteenth Step";
				if(file_exists($v.'/'.$a.'/lastfm_cover.jpg') || file_exists($v.'/'.$a.'/lastfm_cover.png')){
					if(file_exists($v.'/'.$a.'/lastfm_cover.jpg') || file_exists($v.'/'.$a.'/lastfm_cover.png')){
						echo $v."/".$a."file exists, comressing...\n\n";
						//chdir("/home/pranav/.gvfs/SFTP for sdslabs on 192.168.208.206/media/Data/Muzi/English/".$v."/".$a);
						$ext = (file_exists($v.'/'.$a.'/lastfm_cover.jpg'))?"jpg":"png";
						$source = ($ext == "jpg")?imagecreatefromjpeg($v.'/'.$a.'/lastfm_cover.jpg'):imagecreatefrompng($v.'/'.$a.'/lastfm_cover.png');
						$thumb = imagecreatetruecolor(80,80);
						$size = getimagesize($v.'/'.$a.'/lastfm_cover.'.$ext);
						imagecopyresampled($thumb, $source, 0, 0, 0, 0, 80, 80, $size[0],$size[1]);
						//$source = imagefilter($source,IMG_FILTER_GAUSSIAN_BLUR);
						$data = imagejpeg($thumb,$v.'/'.$a.'/last_thumb.jpg',85);
						imagedestroy($source);
				}}
				else{
					echo "file not found\n\n";
			}}
			break;
		}}
break;
}}

?>
