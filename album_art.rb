#!/usr/bin/env ruby
require 'rubygems'	#Gem Support
require 'lastfm'
require 'pathname'
require 'active_record'#ORM
require 'logger'	#database.log
require 'funcs'
require 'models'	#Track,Album etc
require 'yaml'
require 'json'

##Setup the database

puts "Initialized all gems"

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))
ActiveSupport::LogSubscriber.colorize_logging=false
ActiveRecord::Base.logger.formatter = proc { |severity, datetime, progname, msg|
  "#{msg}\n"
}
puts "initialized database"

pics_folder=ARGV[0]
exit if pics_folder.length==0
lastfm = Lastfm.new("1046bf7d632bb797c7d3430962cc2549", "a973b39e259ec530d08d0daad7ac718d")
Album.all(:conditions => { :language => 'English' }, :order=>"id DESC").each do |album|
	puts album.name
	next if File.exist?("#{pics_folder}/#{album.id}.jpg")
	bandName = Band.find(Track.find_by(:album_id, album.id).band).name
	begin
		album_info = lastfm.album.get_info(bandName,album.name)
	rescue
		next
	end
	next unless album_info['image'].length >0
	album_info['image'].each do |img|
		if img["size"]=='large' and img['content']
			puts img["content"]
			filename = "#{pics_folder}/#{album.id}.jpg"
			`wget -nv "#{img["content"]}" -O #{filename}`
		end
	end
end
