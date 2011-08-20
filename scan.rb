#!/usr/bin/env ruby
require 'rubygems'
require 'active_record'
require 'logger'
require 'yaml'
require "mp3info"
require 'image_size'
require 'ImageResize'

root = ARGV[1] || '/media/Entertainment/Music/Rock'

# @see http://www.ruby-forum.com/topic/178706
if RUBY_VERSION =~ /1.9/
    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = Encoding::UTF_8
end

dbconfig = YAML::load(File.open('database.yml'))
ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))

class Track < ActiveRecord::Base
	belongs_to :album, :foreign_key => 'album'
	belongs_to :genre, :foreign_key => 'genre'
	belongs_to :band, :foreign_key => 'band'
	belongs_to :year, :foreign_key => 'year'
	
	def pic_data(apic)
		max_size_apic = max_size_folder = 0
		if apic
			if apic.is_a?(Array)
				for i in 0...APIC.length
					image_size=1
					text_encoding,mime_type,picture_type,description,picture_data = apic[i].unpack("c Z* c Z* a*")
					ImageSize.new(picture_data).size.each {|i| image_size*=i}
					if image_size > max_size_apic 
						pic_data_apic = picture_data
						max_size_apic = image_size
					end
				end
			else
				image_size=1
				text_encoding,mime_type,picture_type,description,picture_data = apic.unpack("c Z* c Z* a*")
				ImageSize.new(picture_data).size.each {|i| image_size*=i}
				pic_data_apic = picture_data
				max_size_apic = image_size;
			end
		end
		
		for image in Dir[File.dirname(self.file)+"/*.{{{p,P}{n,N}{g,G}},{{j,J}{p,P}*{g,G}}}"]
			image_size=1
			pic_data_folder = IO.read(image)
			ImageSize.new(pic_data_folder).size.each {|i| image_size*=i}
			if image_size > max_size_folder
				max_size_folder = image_size
			end
		end
		#Now for the decision making part
		if max_size_folder > max_size_apic
			return pic_data_folder 
		else
			return pic_data_apic
		end
	end
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

#Dir.chdir(root)
for file in  Dir[root+"**/*.{m,M}{P,p}3"]
	puts file
	mp3info = Mp3Info.open(file)
	track = Track.new(
		:file	=> mp3info.filename,
		:title	=> mp3info.tag.title || url.split('/').last.split('.').first,
		:album	=> Album.find_or_create_by_name(mp3info.tag.album || "Unknown Album"),
		:genre	=> Genre.find_or_create_by_name(mp3info.tag.genre_s || "Unknown Genre"),
		:year	=> Year.find_or_create_by_name(mp3info.tag1.year || mp3info.tag2.TDAT || mp3info.tag2.TDRC || mp3info.tag2.TORY || 2000),
		:artist	=> mp3info.tag.artist || "Unknown Artist",
		:track	=> mp3info.tag.tracknum  || ( mp3info.tag2.TRCK ? mp3info.tag2.TRCK.split('/').first : 0 ) ||  0,
		:band	=> Band.find_or_create_by_name(mp3info.tag2.TPE2  || mp3info.tag.artist || "Unkown Artist"), #Also called the Album Artist/Band
		:plays	=> 0,
		:length	=> mp3info.length
	)
	track.save
	f = File.new('tmp','w')
	pic_data = track.pic_data(mp3info.tag2.APIC)
	f<<pic_data
	Image.resize('tmp','./pics/'+track.album.id.to_s+'.jpg',200,200);
end
File.delete('tmp')
