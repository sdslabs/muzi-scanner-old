#!/bin/bash
find $1  -mindepth 2 -maxdepth 2  -type d -mtime -2 >album_path.txt
./scan.rb
