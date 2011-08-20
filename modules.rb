module Image
	def Image.resize(img_in, img_out, width, height)
		`#{Image.cmd} resize #{img_in} #{img_out} #{width} #{height}`
	end
end

