#!/usr/bin/env ruby

require 'rubygems'
require 'audioinfo'
require 'audioinfo/album'
require 'rexml/document'
require 'active_record'
require 'pathname'
require 'httparty'
require 'logger'
require 'yaml'
require 'json'
require 'uri'

require './app/utils.rb'
require './app/models.rb'
include REXML

config = YAML::load(File.open('config/config.yml'))

$musicFolder = $artistPicFolder = $albumArtFolder = nil

if ARGV.length == 3
  $musicFolder = ARGV[0]
  $albumArtFolder = ARGV[1]
  $artistPicFolder = ARGV[2]
elsif ARGV.length == 2
  $musicFolder = ARGV[0]
  $albumArtFolder = ARGV[1]
elsif ARGV.length == 1
  $musicFolder = ARGV[0]
else
  puts "Invalid number of arguments provided"
  exit
end

ActiveRecord::Base.establish_connection(config.db)
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
ActiveRecord::Base.logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }

File.open('album_path.txt', 'r') do |infile|
  while (album_path = infile.gets)
    saveAlbum(album_path)
  end
end
