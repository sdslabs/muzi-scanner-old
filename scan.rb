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
##Setup the database

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
ActiveSupport::LogSubscriber.colorize_logging=false
ActiveRecord::Base.logger.formatter = proc { |severity, datetime, progname, msg|
  "#{msg}\n"
}

File.open("album_path.txt", "r") do |infile|
    while (album_path = infile.gets)
		ActiveRecord::Base.establish_connection(dbconfig)
		album_path = album_path.strip! || album_path
		album = AudioInfo::Album.new(album_path)

		#Check if the album is empty
		if album.empty?
			puts "Album empty"
			next
		else
			#puts "THIS IS AWESOME"
			puts album_path
		end

		Dir.chdir(album_path)

		#Get the music root
		#The immediate parent directory is the Artist directory
		#The one above that is the language directory
		#And the one above that is the music root
		music_root =  File.expand_path "../../..", album_path

		#The language is passed as the second argument
		language = "English"

		#Get the band name from parent folder
		band_name = File.basename File.expand_path "..", album_path
		#The album alternative name is the name of the current folder
		album_folder = File.basename album_path

		#Conflict in Album titles
		#if album.title != File.basename(album_path)
			#puts Album.title + " v/s " + File.basename(album_path)

		#end

		#puts "MUSIC ROOT: " + music_root

		album.files.each do |track|
			#Check for file extension (wma etc need to be ignored)
			next unless ["mp3","m4a","mp4"].include? track.extension.downcase

			#Calculate the path which is stored in database
			#This begins with the Language
			filename_in_database = Pathname.new(track.path).relative_path_from(Pathname.new(music_root)).to_s

			#If track is already in database, skip to next
			if Track.find_by_file filename_in_database
				next
			end

			#Default album title is the name of the folder (unless one is
			#given by the album itself)
			album_title = album.title.empty? ? album_folder : album.title

			#Choose the year
			year = nil
			if track.info.tag1
				year ||= track.info.tag1.year
			elsif track.info.tag2
				year ||= track.info.tag2.TDAT || track.info.tag2.TDRC || track.info.tag2.TORY
			else
				year ||= track.info.DAY || "2000"
			end
			year = "2000" if year.nil?

			#Choose the artist
			artist= track.artist || track.info.tag.artist || track.info.tag2.TP1 || "Unknown Artist"

			#Choose the genre
			if track.info.tag && track.info.tag.genre_s
				genre = getGenre(track.info.tag.genre_s) || "Unknown Genre"
			else
				genre = "Unknown genre"
			end

			#Track Number
			track_number   = track.info.tag.tracknum if track.info.tag
			track_number ||= track.info.tag2.TRCK.split('/').first if track.info.tag2 && track.info.tag2.TRCK
			track_number ||= 0

			#Title
			title   = track.title
			title ||= track.info.tag.title if track.info.tag
			title ||= track.info.tag2.TT2 if track.info.tag2
			#If all tags fail, use the filename
			title = File.basename(track.path,"."+track.extension) if title.chomp.length==0

			band_id = Band.find_or_create_by_name_and_language(band_name,language).id
			#Create the track object
			track = Track.new(
				# Each || offers an alternative, some ternary for cases where it may not exist
				:file	=> filename_in_database,
				:title	=> title,
				:album_id	=> Album.find_or_create_by_name_and_language_and_band_id_and_band_name(album_title,language, band_id, band_name).id,
				:genre_id	=> Genre.find_or_create_by_name(genre).id,
				:year_id	=> Year.find_or_create_by_name(year).id,
				:artist	=> artist,
				:track	=> track_number,
				:band_id	=> band_id, #Also called the Album Artist/Band
				:plays	=> 0,
				:length	=> track.length
			)
			puts track.title
			track.save
			#puts "Saved:" +track.title
		end
	end
end
