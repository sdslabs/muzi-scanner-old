require 'rubygems'
require 'active_record'
require "mp3info"
require 'image_size'

class Track
	def initialize(url)
		mp3info = Mp3Info.open(url)
		@filename = mp3info.filename	#Since the passed url is only the basename, we prefer this
		@artist = mp3info.tag.artist || "Unknown Artist"
		@genre =  mp3info.tag.genre_s || "Unknown Genre"
		@title =  mp3info.tag.title || url.split('/').last.split('.').first
		@album =  mp3info.tag.album || "Unknown Album"
		@track =  mp3info.tag.tracknum  || mp3info.tag2.TRCK.split('/').first || "0"
		@band =   mp3info.tag2.TPE2	|| mp3info.tag.artist || "Unkown Artist" #Also called the Album Artist/Band
		@year =   mp3info.tag1.year || mp3info.tag2.TDAT || mp3info.tag2.TDRC || mp3info.tag2.TORY #Year of release
		@apic = mp3info.tag2.APIC
	end
	def pic_data()
		apic = @apic
		max_size_apic = max_size_folder = 0
		if apic
			if apic.is_a?(Array)
				for i in 0...APIC.length
					image_size=1
					text_encoding,mime_type,picture_type,description,picture_data = apic[i].unpack("c Z* c Z* a*")
					ImageSize.new(picture_data).get_size.each {|i| image_size*=i}
					if image_size > max_size_apic 
						pic_data_apic = picture_data
						max_size_apic = image_size
					end
				end
			else
				image_size=1
				text_encoding,mime_type,picture_type,description,picture_data = apic.unpack("c Z* c Z* a*")
				ImageSize.new(picture_data).get_size.each {|i| image_size*=i}
				pic_data_apic = picture_data
				max_size_apic = image_size;
			end
		end
		
		for file in Dir[File.dirname(@filename)+"/*.{{{p,P}{n,N}{g,G}},{{j,J}{p,P}*{g,G}}}"]
			image_size=1
			pic_data_folder = File.open(file).read
			ImageSize.new(pic_data_folder).get_size.each {|i| image_size*=i}
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

Dir.chdir("/media/Entertainment/Music/AC-DC")
i=0
for file in  Dir["**/*.{m,M}{P,p}3"]
	t = Track.new(file)
	f = File.new(i.to_s,'w')
	f<<t.pic_data()
	i = i+1
end
