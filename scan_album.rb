#!/usr/bin/env ruby
require 'rubygems'	#Gem Support
require "audioinfo"	#reading id3 tags
require "audioinfo/album"	#reading id3 tags
#require 'yaml'

Album = AudioInfo::Album.new(ARGV[0])

Album.files.each do |track|
	puts " - " + track.title
	title = track.tag.title || track.tag2.TT2 || File.basename(track.filename,"."+track.extension)
	
end
