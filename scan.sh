#!/bin/bash
while read album
do
	#echo $album
	ruby scan_album.rb "$album"
done < <(find $1 -mindepth 2 -maxdepth 2  -type d)
