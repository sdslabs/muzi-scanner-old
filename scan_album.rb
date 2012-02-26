#!/usr/bin/env ruby
require 'rubygems'	#Gem Support
require "audioinfo"	#reading id3 tags
require "audioinfo/album"	#reading id3 tags
#require 'yaml'

Album = AudioInfo::Album.new(ARGV[0])
#Check if the album is empty
return if Album.empty?

if Album.title != File.basename(ARGV[0])
	puts Album.title + " v/s " + File.basename(ARGV[0])
end
