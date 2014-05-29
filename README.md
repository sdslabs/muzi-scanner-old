# Muzi Scanner

This repository contains the scanner script for Muzi. It scans english songs and adds them to the database so that they can be accessed by the Muzi backend.

## Usage

* Use ruby version 2.0.0-p451 to ensure that the script run properly.
* Run `sudo apt-get install libmysqlclient-dev` to install a package needed for the mysql gem.
* If you don't have the bundler gem installed, install it using `gem install bundler`.
* Install all required gems using `bundle install`.
* Copy over the config file and add the database details.
* Create two new folders where the album and artist pics will be downloaded. Examples: `~/pictures/muzipics/albums` and `~/pictures/muzipics/artists`.
* Make sure your song collection is properly organized in folders such that the root folder contains folders named as artists each of which contains folders for different albums. A quick hack would be to create a folder structure like `Unknown Artist/Unknown Album` in your music root directory and place all your songs in it.
* Run `./scan.sh /path/to/songs /path/to/album/pics /path/to/artist/pics`.
