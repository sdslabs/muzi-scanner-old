class Track < ActiveRecord::Base
	belongs_to :album, :foreign_key => 'album'
	belongs_to :genre, :foreign_key => 'genre'
	belongs_to :band, :foreign_key => 'band'
	belongs_to :year, :foreign_key => 'year'
	
	def pic_data(apic)
		max_size_apic = max_size_folder = 0
		pic_data_apic = pic_data_folder = ''
		if apic
			if apic.is_a?(Array)
				puts "* APIC is ARRAY"
				for i in 0...apic.length
					image_size=1
					text_encoding,mime_type,picture_type,description,picture_data = apic[i].unpack("c Z* c Z* a*")
					ImageSize.new(picture_data).size.each {|i| image_size = image_size > i ? image_size : i }
					puts image_size
					if image_size > max_size_apic 
						pic_data_apic = picture_data
						max_size_apic = image_size
					end
				end
			else
				puts "* APIC is single"
				image_size=1
				text_encoding,mime_type,picture_type,description,picture_data = apic.unpack("c Z* c Z* a*")
				ImageSize.new(picture_data).size.each {|i| image_size = image_size > i ? image_size : i }
				pic_data_apic = picture_data
				max_size_apic = image_size;
				puts image_size
			end
		end
		
		for image in Dir[File.dirname(self.file)+"/*.{{{p,P}{n,N}{g,G}},{{j,J}{p,P}*{g,G}}}"]
			puts "* Trying dir files"
			puts image
			image_size=1
			pic_data = IO.read(image)
			ImageSize.new(pic_data_folder).size.each {|i| image_size = (image_size > i ? image_size : i) }
			puts image_size
			if image_size > max_size_folder
				max_size_folder = image_size
				pic_data_folder = pic_data
			end
		end
		#Now for the decision making part
		if max_size_folder > max_size_apic
			puts "Folder pic choosen"
			return pic_data_folder
		elsif max_size_apic > 0
			puts "APIC choosen"
			return pic_data_apic
		else
			return false
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
