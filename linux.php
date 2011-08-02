<?php
	//phpinfo();
	/* 
		scanner.php	
		Call from cli
	*/
	// Config:
	error_reporting('E_ERROR');
	$root="/media/Entertainment/Music";
	$music_ext=array('mp3','wma','m4a','ogg','MP3');
	$conn=new mysqli("localhost","root","nemoabhay","muzi");
	require_once "audioinfo.php";
	$au = new AudioInfo;
	$it = new RecursiveDirectoryIterator($root);
	$c=0;
	foreach(new RecursiveIteratorIterator($it) as $file) 
	{
	if(is_file($file))
	if(in_array(substr($file,-3),$music_ext))
	{
	$file2=$conn->escape_string($file);	
	$r=$conn->query("SELECT id from tracks where file='$file'");
	if($r)
	{
		if($r->num_rows)
			continue;
	}
	// echo ($file);
	echo $file . "\n";
	$ThisFileInfo = $au->Info($file);
	if(isset($ThisFileInfo['tags'])){
		list($band)=getAlbumArtist($ThisFileInfo['tags']);
		list($artist)=getArtist($ThisFileInfo['tags']);
		list($album)=getAlbum($ThisFileInfo['tags']);
		list($title)=getTitle($ThisFileInfo['tags']);
		list($track)=getTrack($ThisFileInfo['tags']);
		list($year)=getYear($ThisFileInfo['tags']);
		list($genre)=getGenre($ThisFileInfo['tags']);
	}
	else
	{
		$artist="Unknown Artist";
		$album="Unknown Album";
	}
	if(!$title)
		$title=substr(basename($file),0,strrpos(basename($file),'.'));
	$band=$conn->escape_string($band);
	$artist=$conn->escape_string($artist);
	$album=$conn->escape_string($album);
	$title=$conn->escape_string($title);
	$track=$conn->escape_string($track);
	$year=$conn->escape_string($year);
	$genre=$conn->escape_string($genre);
	//make the appopriate insertions if necessary:
	$bandId=getBandId($band);
	$albumId=getAlbumId($album);
	$genreId=getGenreId($genre);
	$yearId=getYearId($year);
$sql = "INSERT INTO tracks (title, album, year, artist, genre, track,file,band) VALUES ('$title', '$albumId', '$yearId', '$artist', '$genreId', '$track','$file2','$bandId');";
	$conn->query($sql) or die("Error in insertion");
	if($conn->error)
		die($conn->error);
	if(!file_exists("./pics/$albumId".".jpg")&&$album!='Unknown Album')
	{
		get_image($ThisFileInfo['tags'],$albumId,$file);
		//die("should be done");
	}
	elseif($album=='Unknown Album')
		copy("./unknown.jpg","./pics/$albumId.jpg");
	// echo "\n";
	$c++;
	}
	}
	//Update db a bit:
	$conn->query('update tracks set file= substring(file,10);update tracks set file= REPLACE(file, "\\", "/");');	
	
	
	
	/*List Of Some Useful Functions*/
	function getYearId($year)
	{
		// echo "\nBand :$band";
		//is already escaped
		global $conn;
		$result=$conn->query("SELECT id from years where name='$year'");
		if($result)
		{
			if($result->num_rows)
			{
				$r=$result->fetch_row();
				return $r[0];
			}
		}
		//has to run if anything above is false:
		$conn->query("INSERT INTO years (name) VALUES ('$year')");
		return $conn->insert_id;
	}
	
	function getBandId($band)
	{
		// echo "\nBand :$band";
		//is already escaped
		global $conn;
		$result=$conn->query("SELECT id from bands where name='$band'");
		if($result)
		{
			if($result->num_rows)
			{
				$r=$result->fetch_row();
				return $r[0];
			}
		}
		//has to run if anything above is false:
		$conn->query("INSERT INTO bands (name) VALUES ('$band')");
		return $conn->insert_id;
	}
	function getGenreId($genre)
	{
		// echo "\nBand :$band";
		//is already escaped
		global $conn;
		$result=$conn->query("SELECT id from genres where name='$genre'");
		if($result)
		{
			if($result->num_rows)
			{
				$r=$result->fetch_row();
				return $r[0];
			}
		}
		//has to run if anything above is false:
		$conn->query("INSERT INTO genres (name) VALUES ('$genre')");
		return $conn->insert_id;
	}
	
	function getAlbumId($album)
	{
		//is already escaped
		global $conn;
		$result=$conn->query("SELECT id from albums where name='$album'");
		if($result)
		{
			if($result->num_rows)
			{
				$r=$result->fetch_row();
				return $r[0];
			}
		}
		//has to run if anything above is false:
		$conn->query("INSERT INTO albums (name) VALUES ('$album')");
		return $conn->insert_id;
	}
	function getAlbumArtist($tags)
	{
		if(isset($tags['id3v2']['band']))
			return $tags['id3v2']['band'];
		else
			return getArtist($tags);
	}
	function getArtist($tags)
	{
		//Tries artist->band->composer
		if(isset($tags['id3v2']['artist']))
			return $tags['id3v2']['artist'];
		if(isset($tags['id3v1']['artist']))
			return $tags['id3v1']['artist'];
		if(isset($tags['id3v2']['band']))
			return $tags['id3v2']['band'];
		if(isset($tags['id3v1']['band']))
			return $tags['id3v1']['band'];
		if(isset($tags['id3v2']['composer']))
			return $tags['id3v2']['composer'];
		if(isset($tags['id3v1']['composer']))
			return $tags['id3v1']['composer'];
		return array("Unknown Artist");
	}

	function getGenre($tags)
	{
		if(isset($tags['id3v2']['genre']))
			return $tags['id3v2']['genre'];
		if(isset($tags['id3v1']['genre']))
			return $tags['id3v1']['genre'];
	}
	function getAlbum($tags)
	{
		if(isset($tags['id3v2']['album']))
			return $tags['id3v2']['album'];
		if(isset($tags['id3v1']['album']))
			return $tags['id3v1']['album'];
		return array("Unknown Album");
	}
	function getTitle($tags)
	{
		if(isset($tags['id3v2']['title']))
			return $tags['id3v2']['title'];
		if(isset($tags['id3v1']['title']))
			return $tags['id3v1']['title'];
	}
	function getYear($tags)
	{
		if(isset($tags['id3v2']['year']))
			return $tags['id3v2']['year'];
		if(isset($tags['id3v1']['year']))
			return $tags['id3v1']['year'];
	}
	function getTrack($tags)
	{
		if(isset($tags['id3v2']['track']))
			return $tags['id3v2']['track'];
		if(isset($tags['id3v1']['track']))
			return $tags['id3v1']['track'];
		if(isset($tags['id3v2']['tracknumber']))
			return $tags['id3v2']['tracknumber'];
		if(isset($tags['id3v1']['tracknumber']))
			return $tags['id3v1']['tracknumber'];
	}
	function get_image($id3,$image_name,$filename)
	{
		// echo "[IMG]";
		//uses the 1st found img
		//Should maybe use the largest one?
		if(isset($id3['PIC']))
			$idimg=$id3['PIC'][0];
		elseif(isset($id3['APIC']))
			$idimg=$id3['APIC'][0];
		else
			$idimg=false;
		$img=false;
		if($idimg):
			$ext=ext_from_mime($idimg['image_mime']);
			file_put_contents("temp".$ext,$idimg['data']);
			$img="temp".$ext;
		else:
			$dir=realpath(dirname($filename));$img=false;
			//Search for folder.jpg
			if(file_exists($dir."/folder.jpg"))
				$img=($dir."/folder.jpg");
			elseif(file_exists($dir."/folder.png"))
				$img=($dir."/folder.png");
			elseif(file_exists($dir."/folder.jpeg"))
				$img=($dir."/folder.jpeg");
		endif;
		if($img){
			`convert -sample 200x200 "$img" "./pics/$image_name.jpg"`;
		}
		else{
			copy("./unknown.jpg","./pics/$image_name.jpg");
		}
		// echo "Saved image for $filename at $image_name\n";
	}
	function ext_from_mime($mime){
	switch($mime){
		case 'image/png':
			return '.png';
			break;
		case 'image/jpeg':
		case 'image/jpg':
			return '.jpg';
			break;
		case 'image/gif':
			return '.gif';
			break;
		default:
			die("Unknown Image Format");
	}
}
