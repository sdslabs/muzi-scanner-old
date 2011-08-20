#!/usr/bin/env ruby
#Time Log at the end :

time = Time.now.to_i;
require 'ftools'
require 'rubygems'
require 'active_record'
require 'logger'
require 'yaml'
require "mp3info"
require 'image_size'
require 'ImageResize'
require 'models'
require 'modules'

root = Dir.pwd
music_root = ARGV[0] || '/media/Entertainment/Music/'
puts "Please wait, scanning directory"

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))


i=0
Dir.chdir(music_root)
for file in  Dir["**/*.{m,M}{P,p}3"]
	mp3info = Mp3Info.open(file)
	track = Track.find_by_file(mp3info.filename)
	if track.blank?
		track = Track.create(
			:file	=>	mp3info.filename,
			:title	=> mp3info.tag.title || mp3info.tag2.TT2 || File.basename(file,".mp3"),
			:album	=> Album.find_or_create_by_name(mp3info.tag.album || mp3info.tag2.TAL || "Unknown Album"),
			:genre	=> Genre.find_or_create_by_name(mp3info.tag.genre_s || "Unknown Genre"),
			:year	=> Year.find_or_create_by_name(mp3info.tag1.year || mp3info.tag2.TDAT || mp3info.tag2.TDRC || mp3info.tag2.TORY || 2000),
			:artist	=> mp3info.tag.artist || mp3info.tag2.TP1 || "Unknown Artist",
			:track	=> mp3info.tag.tracknum  || ( mp3info.tag2.TRCK ? mp3info.tag2.TRCK.split('/').first	 : 0 ) ||  0,
			:band	=> Band.find_or_create_by_name(  mp3info.tag2.TPE2  || mp3info.tag2.TP2 || mp3info.tag2.ALBUMARTIST || mp3info.tag.artist || "Unkown Artist"), #Also called the Album Artist/Band
			:plays	=> 0,
			:length	=> mp3info.length
		)
		track.save
		puts file
		unless File.exists?(root+'/pics/'+track.album.id.to_s)
			pic_data=track.pic_data(mp3info.tag2.APIC)
			if pic_data == false
				File.copy(root+'/unknown.jpg',root+'/pics/'+track.album.id.to_s)
			else
				f = File.new(root+'/pics/'+track.album.id.to_s,'w')
				f<<pic_data
			end
		end
		i=i+1
	end
end
puts "#{Time.now.to_i - time} seconds taken in parsing #{i} songs"
