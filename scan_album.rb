#!/usr/bin/env ruby
require 'rubygems'	#Gem Support
require "vendor/ruby-audioinfo/lib/audioinfo.rb"	#reading id3 tags
require "vendor/ruby-audioinfo/lib/audioinfo/album.rb"	#reading id3 tags
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
language = "English"

#Get the band name from parent folder
band_name = File.basename File.expand_path "..", ARGV[0]

#The album alternative name is the name of the current folder
album_folder = File.basename ARGV[0]

#Conflict in Album titles
#if album.title != File.basename(ARGV[0])
	#puts Album.title + " v/s " + File.basename(ARGV[0])

#end
puts "MUSIC ROOT: " + music_root

album.files.each do |track|
	puts track.path
	filename_in_database = Pathname.new(track.path).relative_path_from(Pathname.new(music_root))
	puts filename_in_database
	next if Track.find_by_file filename_in_database
	album_title = album.title.empty? ? album_folder : album.title
	if track.info
		year  = track.info.tag1.year || track.info.tag2.TDAT || track.info.tag2.TDRC || track.info.tag2.TORY || 2000
	else
		year = 2000
	end
	artist= track.artist || track.info.tag.artist || track.info.tag2.TP1 || "Unknown Artist"
	genre = getGenre(track.info.tag.genre_s) || "Unknown Genre"
	track = Track.new(
		# Each || offers an alternative, some ternary for cases where it may not exist
		:file	=> filename_in_database,
		:title	=> track.title || track.info.tag.title || track.info.tag2.TT2 || File.basename(track.path,"."+track.extension),
		:album	=> Album.find_or_create_by_name_and_language(album_title,language),
		:genre	=> Genre.find_or_create_by_name(genre),
		:year	=> Year.find_or_create_by_name(year),
		:artist	=> artist,
		:track	=> track.info.tag.tracknum  || ( track.info.tag2.TRCK ? track.info.tag2.TRCK.split('/').first	 : 0 ) ||  0,
		:band	=> Band.find_or_create_by_name_and_language(band_name,language), #Also called the Album Artist/Band
		:plays	=> 0,
		:length	=> track.length
	)
	track.save
	puts "Saved:" track.title
end
