#!/usr/bin/env ruby
#Time Log at the end :
time = Time.now.to_i;

require 'ftools'	#FileUtils
require 'rubygems'	#Gem Support
require 'active_record'#ORM
require 'logger'	#database.log
require 'yaml'		#databas.yml reading configuration
require "mp3info"	#reading id3 tags
require 'RMagick'	#Image Thumbnailing

require 'funcs'
require 'models'	#Track,Album etc
require 'modules'	#Some custom functions
include Magick		#RMagick module

root = Dir.pwd	#Current directory
music_root = ARGV[0] || '/media/Entertainment/Music/muzi_test/'	#Read from command line
puts "Please wait, scanning directory"

#Setup database
dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))
ActiveSupport::LogSubscriber.colorize_logging=false
ActiveRecord::Base.logger.formatter = proc { |severity, datetime, progname, msg|
  "#{msg}\n"
}
i=0
Dir.chdir(music_root)
for file in  Dir["**/*.{m,M}{P,p}3"]
	language =  file.split('/').first()
	mp3info = Mp3Info.open(file)
	track = Track.find_by_file(mp3info.filename)
	if track.blank?	#If no such track in database
		track = Track.new(
			# Each || offers an alternative, some ternary for cases where it may not exist
			:file	=>	mp3info.filename,
			:title	=> mp3info.tag.title || mp3info.tag2.TT2 || File.basename(file,".mp3"),
			:album	=> Album.find_or_create_by_name_and_language(mp3info.tag.album || mp3info.tag2.TAL || "Unknown Album",language),
			:genre	=> Genre.find_or_create_by_name(getGenre(mp3info.tag.genre_s) || "Unknown Genre"),
			:year	=> Year.find_or_create_by_name(mp3info.tag1.year || mp3info.tag2.TDAT || mp3info.tag2.TDRC || mp3info.tag2.TORY || 2000),
			:artist	=> mp3info.tag.artist || mp3info.tag2.TP1 || "Unknown Artist",
			:track	=> mp3info.tag.tracknum  || ( mp3info.tag2.TRCK ? mp3info.tag2.TRCK.split('/').first	 : 0 ) ||  0,
			:band	=> Band.find_or_create_by_name_and_language(  mp3info.tag2.TPE2  || mp3info.tag2.TP2 || mp3info.tag2.ALBUMARTIST || mp3info.tag.artist || "Unkown Artist",language), #Also called the Album Artist/Band
			:plays	=> 0,
			:length	=> mp3info.length
		)
		track.save
		puts file	#Display File name
		img_file = root + '/pics/' + track.album.id.to_s + '.jpg'
		if (!File.exists?(img_file))  	#If there is no such album art or the file is a symlink
			pics=pic_data mp3info.tag2.APIC	#Call our pic_data function, and get an array of pic data
			if pics.nil? || pics.empty?	#Empty array = no album art
				#File.symlink(root+'/unknown.jpg',img_file)  unless File.exists?(img_file) 	#Symlink the unknown pic
			else
				#Store it temporarily
				f = File.new('/tmp/muzi_pic','w')
				f<<pics[0]	#The first pic as of now
				f.close()
				begin
					img = Image.read("/tmp/muzi_pic").first
					#Generate the thumbnail
					thumbnail = img.thumbnail(100,100)
					thumbnail.write(img_file)
				rescue
					#File.symlink(root+'/unknown.jpg',img_file)  unless File.exists?(img_file) 	#Symlink the unknown pic
					#We could not find an inline tag. We just leave the file as it is, so that we can rescue it from client side
				end
			end
		end
		i=i+1
	end
end
#Ending happy debug message :)
puts "#{Time.now.to_i - time} seconds taken in parsing #{i} songs"
puts 'Debugging information stored in database.log'
