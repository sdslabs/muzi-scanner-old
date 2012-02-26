#!/usr/bin/env ruby
require 'rubygems'	#Gem Support
require "audioinfo"	#reading id3 tags
require "audioinfo/album"	#reading id3 tags
require 'pathname'
require 'active_record'#ORM
require 'logger'	#database.log
require 'funcs'
require 'models'	#Track,Album etc
require 'yaml'

album = AudioInfo::Album.new(ARGV[0])

#We are passed just the Album folder by bash


#Check if the album is empty
exit if album.empty?

##Setup the database

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))
ActiveSupport::LogSubscriber.colorize_logging=false
ActiveRecord::Base.logger.formatter = proc { |severity, datetime, progname, msg|
  "#{msg}\n"
}

Dir.chdir(ARGV[0])

#Get the music root
#The immediate parent directory is the Artist directory
#The one above that is the language directory
#And the one above that is the music root
music_root =  File.expand_path "../../..", ARGV[0]

#The language is passed as the second argument
language = ARGV[1]

#Get the band name from parent folder
band_name = File.basename File.expand_path "..", ARGV[0]

#Conflict in Album titles
#if album.title != File.basename(ARGV[0])
	#puts Album.title + " v/s " + File.basename(ARGV[0])

#end

album.files.each do |track|
	puts track.path
	filename_in_database = Pathname.new(track.path).relative_path_from(Pathname.new(music_root)).to_s
	next if Track.find_by_file filename_in_database
	album_title = album.title.empty? ? album_folder : album.title
	puts track.to_yaml
	puts track.vbr
	puts track.info
	exit
	if track.responds_to 'info'
		year  = track.info.tag1.year || track.info.tag2.TDAT || track.info.tag2.TDRC || track.info.tag2.TORY || 2000
	else
		year = 2000
	end
	put year
	artist= track.tag.artist || track.tag2.TP1 || "Unknown Artist"
	genre = getGenre(track.tag.genre_s) || "Unknown Genre"
	track = Track.new(
		# Each || offers an alternative, some ternary for cases where it may not exist
		:file	=> track.path,
		:title	=> track.title || track.tag.title || track.tag2.TT2 || File.basename(track.path,"."+track.extension),
		:album	=> Album.find_or_create_by_name_and_language(album_title,language),
		:genre	=> Genre.find_or_create_by_name(genre),
		:year	=> Year.find_or_create_by_name(year),
		:artist	=> artist,
		:track	=> track.tag.tracknum  || ( track.tag2.TRCK ? track.tag2.TRCK.split('/').first	 : 0 ) ||  0,
		:band	=> Band.find_or_create_by_name_and_language(band_name,language), #Also called the Album Artist/Band
		:plays	=> 0,
		:length	=> track.length
	)
	track.save
	put track.title
end
