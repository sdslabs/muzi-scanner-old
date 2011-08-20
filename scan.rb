require 'rubygems'
require 'activerecord'
require 'logger'
require 'yaml'
require "mp3info"

root = ARGV[1] || '/media/Entertainment/Music'

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))
ActiveRecord::Base.colorize_logging = false

class Track < ActiveRecord::Base
	belongs_to :album, :foreign_key => 'album'
	belongs_to :genre, :foreign_key => 'genre'
	belongs_to :band, :foreign_key => 'band'
	belongs_to :year, :foreign_key => 'year'
end

class Album < ActiveRecord::Base
	has_many :track
end

class Genre < ActiveRecord::Base
	has_many :track
end

class Year < ActiveRecord::Base
	has_many :track
end

class Band < ActiveRecord::Base
	has_many :track
end

Dir.chdir(root)
for file in  Dir["**/*.{m,M}{P,p}3"]
	mp3info = Mp3Info.open(file)
	track = Track.new(
		:file	=> mp3info.filename,
		:title	=> mp3info.tag.title || url.split('/').last.split('.').first,
		:album	=> Album.find_or_create_by_name(mp3info.tag.album || "Unknown Album"),
		:genre	=> Genre.find_or_create_by_name(mp3info.tag.genre_s || "Unknown Genre"),
		:year	=> Year.find_or_create_by_name(mp3info.tag1.year || mp3info.tag2.TDAT || mp3info.tag2.TDRC || mp3info.tag2.TORY),
		:artist	=> mp3info.tag.artist || "Unknown Artist",
		:track	=> mp3info.tag.tracknum  || mp3info.tag2.TRCK.split('/').first || "0",
		:band	=> Band.find_or_create_by_name(mp3info.tag2.TPE2  || mp3info.tag.artist || "Unkown Artist"), #Also called the Album Artist/Band
		:plays	=> 0,
	)
	track.save
	
end
