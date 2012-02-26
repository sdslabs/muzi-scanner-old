#!/bin/bash
while read album
do
	echo $album
	ruby -W0 scan_album.rb "$album" "English"
done < <(find $1 -mindepth 2 -maxdepth 2  -type d)
