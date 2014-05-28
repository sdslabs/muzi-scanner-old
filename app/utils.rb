genres = ['Blues','Classic Rock','Country','Dance','Disco','Funk','Grunge','Hip-Hop','Jazz','Metal','New Age','Oldies','Other','Pop','R&B','Rap','Reggae','Rock','Techno','Industrial','Alternative','Ska','Death Metal','Pranks','Soundtrack','Euro-Techno','Ambient','Trip-Hop','Vocal','Jazz+Funk','Fusion','Trance','Classical','Instrumental','Acid','House','Game','Soun','Gospel','Noise','Alternative Rock','Bass','Soul','Punk','Space','Meditative','Instrumental Pop','Instrumental Rock','Ethnic','Gothic','Darkwave','Techno-Industrial','Electronic','Pop-Folk','Euro','Dream','Southern Rock','Comedy','Cult','Gangsta','Top 40','Christian Rap','Pop/Funk','Jungle','Native US','Cabaret','New Wave','Psycha','Rave','Showtunes','Trailer','Lo-Fi','Tribal','Acid Punk','Acid Jazz','Polka','Retro','Musical','Rock & Roll','Hard Rock','Folk','Folk-Rock','National Folk','Swing','Fast Fusion','Bebob','Latin','Revival','Celtic','Bluegrass','Avantgar','Gothic Rock','Progressive Rock','Psyche','Symphonic Rock','Slow Rock','Big Ban','Chorus','Easy Listening','Acoustic','Humour','Speech','Chanson','Opera','Chamber Music','Sonata','Symphony','Booty Bass','Primus','Porn Groove','Satire','Slow Jam','Club','Tango','Samba','Folklore','Balla','Power Balla','Rhythmic Soul','Freestyle','Duet','Punk Rock','Drum Solo','Acapella','Euro-House','Dance Hall','Goa','Drum & Bass','ClubHouse','Hardcore','Terror','Indie','BritPop','Negerpunk','Polsk Punk','Beat','Christian Gangsta Rap','Heavy Metal','Black Metal','Crossover','Contemporary Christian','Christian Rock','Merengue','Salsa','Thrash Metal','Anime','JPop','Synthpop']

def getGenre(string)
  return "Unknown Genre" if string.nil?
  if string =~ /\((\d+)\)/
    genres[$1.to_i]
  else
    return string
  end
end

def downloadAlbumArt (album, pics)
  return if File.exist?("#{pics}/#{album.id}.jpg")
  bandName = Band.find(Track.find_by_album(album.id).band).name
  begin
    album_info = $lastfm.album.get_info(bandName, album.name)
  # rescue
    # return
  end
  return unless album_info['image'].length > 0
  album_info['image'].each do |img|
    if img['size'] == 'large' and img['content']
      filename = "#{pics}/#{album.id}.jpg"
      `wget -nv "#{img["content"]}" -O #{filename}`
    end
  end
end

