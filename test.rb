#!/usr/bin/env ruby
require 'rubygems'	#Gem Support
require "vendor/ruby-audioinfo/lib/audioinfo.rb"	#reading id3 tags
require "vendor/ruby-audioinfo/lib/audioinfo/album.rb"	#reading id3 tags
require 'yaml'

Album = AudioInfo::Album.new(ARGV[0])

Album.files.each do |track|
	puts track.info.tag.title
end
#puts mp3info.files.class.nameto_yaml
#http://www.multimediasoft.com/amp3dj/help/index.html?amp3dj_00003e.htm

def getGenre(string)
	return "Unknown Genre" if (string == null)
	genres = ['Blues','Classic Rock','Country','Dance','Disco','Funk','Grunge','Hip-Hop','Jazz','Metal','New Age','Oldies','Other','Pop','R&B','Rap','Reggae','Rock','Techno','Industrial','Alternative','Ska','Death Metal','Pranks','Soundtrack','Euro-Techno','Ambient','Trip-Hop','Vocal','Jazz+Funk','Fusion','Trance','Classical','Instrumental','Acid','House','Game','Soun','Gospel','Noise','Alternative Rock','Bass','Soul','Punk','Space','Meditative','Instrumental Pop','Instrumental Rock','Ethnic','Gothic','Darkwave','Techno-Industrial','Electronic','Pop-Folk','Euro','Dream','Southern Rock','Comedy','Cult','Gangsta','Top 40','Christian Rap','Pop/Funk','Jungle','Native US','Cabaret','New Wave','Psycha','Rave','Showtunes','Trailer','Lo-Fi','Tribal','Acid Punk','Acid Jazz','Polka','Retro','Musical','Rock & Roll','Hard Rock','Folk','Folk-Rock','National Folk','Swing','Fast Fusion','Bebob','Latin','Revival','Celtic','Bluegrass','Avantgar','Gothic Rock','Progressive Rock','Psyche','Symphonic Rock','Slow Rock','Big Ban','Chorus','Easy Listening','Acoustic','Humour','Speech','Chanson','Opera','Chamber Music','Sonata','Symphony','Booty Bass','Primus','Porn Groove','Satire','Slow Jam','Club','Tango','Samba','Folklore','Balla','Power Balla','Rhythmic Soul','Freestyle','Duet','Punk Rock','Drum Solo','Acapella','Euro-House','Dance Hall','Goa','Drum & Bass','ClubHouse','Hardcore','Terror','Indie','BritPop','Negerpunk','Polsk Punk','Beat','Christian Gangsta Rap','Heavy Metal','Black Metal','Crossover','Contemporary Christian','Christian Rock','Merengue','Salsa','Thrash Metal','Anime','JPop','Synthpop']
	if string =~ /\((\d+)\)/
		index = $1.to_i
		genres[index]
	else
		return string
	end
end

#puts getGenre "(34)asdsad"
