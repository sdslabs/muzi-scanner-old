#!/bin/bash
find $1 -mindepth 2 -maxdepth 2  -type d > album_path.txt
./scan.rb
