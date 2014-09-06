def getGenre(string)
	return "Unknown Genre" if string.nil?
	genres = ['Blues','Classic Rock','Country','Dance','Disco','Funk','Grunge','Hip-Hop','Jazz','Metal','New Age','Oldies','Other','Pop','R&B','Rap','Reggae','Rock','Techno','Industrial','Alternative','Ska','Death Metal','Pranks','Soundtrack','Euro-Techno','Ambient','Trip-Hop','Vocal','Jazz+Funk','Fusion','Trance','Classical','Instrumental','Acid','House','Game','Soun','Gospel','Noise','Alternative Rock','Bass','Soul','Punk','Space','Meditative','Instrumental Pop','Instrumental Rock','Ethnic','Gothic','Darkwave','Techno-Industrial','Electronic','Pop-Folk','Euro','Dream','Southern Rock','Comedy','Cult','Gangsta','Top 40','Christian Rap','Pop/Funk','Jungle','Native US','Cabaret','New Wave','Psycha','Rave','Showtunes','Trailer','Lo-Fi','Tribal','Acid Punk','Acid Jazz','Polka','Retro','Musical','Rock & Roll','Hard Rock','Folk','Folk-Rock','National Folk','Swing','Fast Fusion','Bebob','Latin','Revival','Celtic','Bluegrass','Avantgar','Gothic Rock','Progressive Rock','Psyche','Symphonic Rock','Slow Rock','Big Ban','Chorus','Easy Listening','Acoustic','Humour','Speech','Chanson','Opera','Chamber Music','Sonata','Symphony','Booty Bass','Primus','Porn Groove','Satire','Slow Jam','Club','Tango','Samba','Folklore','Balla','Power Balla','Rhythmic Soul','Freestyle','Duet','Punk Rock','Drum Solo','Acapella','Euro-House','Dance Hall','Goa','Drum & Bass','ClubHouse','Hardcore','Terror','Indie','BritPop','Negerpunk','Polsk Punk','Beat','Christian Gangsta Rap','Heavy Metal','Black Metal','Crossover','Contemporary Christian','Christian Rock','Merengue','Salsa','Thrash Metal','Anime','JPop','Synthpop']
	if string =~ /\((\d+)\)/
		index = $1.to_i
		genres[index]
	else
		return string
	end
end
# Copied from Rails
# https://github.com/rails/rails/blob/master/activesupport/lib/active_support/core_ext/object/blank.rb
class String #:nodoc:
  #This is a simple method to test if a string contains a whitespace
  def blank?
      self !~ /\S/
  end
  #http://stackoverflow.com/questions/971026/how-do-i-write-a-regular-expression-for-a-url-without-the-scheme
  def stripUrl
   # var regex=/^[A-Za-z\d][\w.-]+(:\d+)?(/.*)?$/
    
  end
end

def stripUrl(string)
    
end

def getCreationTime(string)
	return File.ctime(string).to_i
end
