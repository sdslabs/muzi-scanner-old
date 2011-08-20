require 'rubygems'
require "mp3info"
require 'yaml'
#Dir.chdir("/media/Entertainment/Music")
#for file in  Dir["**/*.{m,M}{P,p}3"]
	#puts file
#end

mp3info = Mp3Info.open("/media/Entertainment/Music/Chase & Status - No More Idols/09 Brixton Briefcase.mp3")

puts mp3info.to_yaml
