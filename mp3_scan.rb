#!/usr/bin/env ruby
require 'rubygems'	#Gem Support
require "mp3info"	#reading id3 tags
require 'yaml'
mp3info = Mp3Info.open(ARGV[0])
puts mp3info.to_yaml
