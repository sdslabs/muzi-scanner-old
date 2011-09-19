def pic_data(apic)
	pic_data_apic = []
	if apic
		apic = [apic] unless apic.is_a?(Array)
		for i in 0...apic.length
			text_encoding,mime_type,picture_type,description,picture_data = apic[i].unpack("c Z* c Z* a*")
			pic_data_apic.push(picture_data)
		end
		return pic_data_apic
	end
end

	#Disabling the folder pics because it might lead to some
	#very bad situations with multiple albums with some
	#random pic
	
	#for image in Dir[File.dirname(self.file)+"/*.{{{p,P}{n,N}{g,G}},{{j,J}{p,P}*{g,G}}}"]
		#puts "* Trying dir files"
		#puts image
		#pic_data = IO.read(image)
		#image_size = higher_dimension(ImageSize.new(pic_data))
		#puts image_size
		#if image_size > max_size_folder
			#max_size_folder = image_size
			#pic_data_folder = pic_data
		#end
	#end
	
	#Now for the decision making part
	#if max_size_folder > max_size_apic
		#return pic_data_folder
	#elsif max_size_apic > 0
		#return pic_data_apic
	#else
		#return false
	#end

