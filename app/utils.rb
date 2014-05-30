$genres = ['Blues','Classic Rock','Country','Dance','Disco','Funk','Grunge','Hip-Hop','Jazz','Metal','New Age','Oldies','Other','Pop','R&B','Rap','Reggae','Rock','Techno','Industrial','Alternative','Ska','Death Metal','Pranks','Soundtrack','Euro-Techno','Ambient','Trip-Hop','Vocal','Jazz+Funk','Fusion','Trance','Classical','Instrumental','Acid','House','Game','Soun','Gospel','Noise','Alternative Rock','Bass','Soul','Punk','Space','Meditative','Instrumental Pop','Instrumental Rock','Ethnic','Gothic','Darkwave','Techno-Industrial','Electronic','Pop-Folk','Euro','Dream','Southern Rock','Comedy','Cult','Gangsta','Top 40','Christian Rap','Pop/Funk','Jungle','Native US','Cabaret','New Wave','Psycha','Rave','Showtunes','Trailer','Lo-Fi','Tribal','Acid Punk','Acid Jazz','Polka','Retro','Musical','Rock & Roll','Hard Rock','Folk','Folk-Rock','National Folk','Swing','Fast Fusion','Bebob','Latin','Revival','Celtic','Bluegrass','Avantgar','Gothic Rock','Progressive Rock','Psyche','Symphonic Rock','Slow Rock','Big Ban','Chorus','Easy Listening','Acoustic','Humour','Speech','Chanson','Opera','Chamber Music','Sonata','Symphony','Booty Bass','Primus','Porn Groove','Satire','Slow Jam','Club','Tango','Samba','Folklore','Balla','Power Balla','Rhythmic Soul','Freestyle','Duet','Punk Rock','Drum Solo','Acapella','Euro-House','Dance Hall','Goa','Drum & Bass','ClubHouse','Hardcore','Terror','Indie','BritPop','Negerpunk','Polsk Punk','Beat','Christian Gangsta Rap','Heavy Metal','Black Metal','Crossover','Contemporary Christian','Christian Rock','Merengue','Salsa','Thrash Metal','Anime','JPop','Synthpop']

def getGenre(string)
  return "Unknown Genre" if string.nil?
  if string =~ /\((\d+)\)/
    $genres[$1.to_i]
  else
    return string
  end
end

def downloadAlbumArt (album)
  return if $albumArtFolder.nil?
  return if File.exist?("#{$albumArtFolder}/#{album.id}.jpg")
  band = Band.find_by(id: Track.find_by(album: album.id).band)
  filename = "#{$albumArtFolder}/#{album.id}.jpg"
  begin
    response = HTTParty.get("http://www.musicbrainz.org/ws/2/release/?limit=1&fmt=json&query=release:#{URI.encode(album.name)}+artist:#{URI.encode(band.name)}")
    mbid = JSON.parse(response.body).releases[0].id.to_s
    response = HTTParty.get("http://www.coverartarchive.org/release/#{URI.encode(mbid)}")
    JSON.parse(response.body).images.each do |image|
      if image.types[0] == "Front"
        url = image.image
        `wget -nv "#{url}" -O #{filename}`
        downloadArtistPic(band)
        return
      end
    end
  rescue
    downloadArtistPic(band)
    return
  end
end

def saveAlbum (album_path)
  begin
    album_path = album_path.strip! || album_path

    Dir.chdir(album_path)
    band_name = File.basename(File.expand_path("..", album_path))
    album_name = File.basename(album_path)

    songs = Dir.entries album_path

    puts album_path
    songs.each do |song|
      begin
        ext = song[-3..-1]
        next if ext.nil?
        next unless ["mp3","m4a","mp4"].include? ext.downcase
        track = AudioInfo.new("#{album_path}/#{song}")
        addTrackToDatabase(track, album_name, band_name)
      rescue
        next
      end
    end

    album = Album.find_by(name: album_name)
    downloadAlbumArt(album)
  rescue
    return
  end
end

def addTrackToDatabase (track, album, band, language = "English")

  # Calculate the path which is stored in database
  filename_in_database = Pathname.new(track.path).relative_path_from(Pathname.new($musicFolder)).to_s

  # If track is already in database, skip to next
  if Track.find_by(file: filename_in_database)
    return
  end

  # Year
  year = nil
  if track.info.tag1
    year ||= track.info.tag1.year
  elsif track.info.tag2
    year ||= track.info.tag2.TDAT || track.info.tag2.TDRC || track.info.tag2.TORY
  else
    year ||= track.info.DAY || "2000"
  end
  year = "2000" if year.nil?

  # Artist
  artist = track.artist || track.info.tag.artist || track.info.tag2.TP1 || "Unknown Artist"

  # Genre
  if track.info.tag && track.info.tag.genre_s
    genre = getGenre(track.info.tag.genre_s) || "Unknown Genre"
  else
    genre = "Unknown genre"
  end

  # Track Number
  track_number   = track.info.tag.tracknum if track.info.tag
  track_number ||= track.info.tag2.TRCK.split('/').first if track.info.tag2 && track.info.tag2.TRCK
  track_number ||= 0

  # Title
  title   = track.title
  title ||= track.info.tag.title if track.info.tag
  title ||= track.info.tag2.TT2 if track.info.tag2

  # If all tags fail, use the filename
  title = File.basename(track.path, "." + track.extension) if title.chomp.length == 0

  track = Track.new(
    :file   => filename_in_database,
    :title  => title,
    :album  => Album.find_or_create_by(name: album, language: language),
    :genre  => Genre.find_or_create_by(name: genre),
    :year   => Year.find_or_create_by(name: year),
    :artist => artist,
    :track  => track_number,
    :band   => Band.find_or_create_by(name: band, language: language),
    :plays  => 0,
    :length => track.length
  )
  track.save
end

def downloadArtistPic (artist)
  return if $artistPicFolder.nil?
  return if File.exist?("#{$artistPicFolder}/#{artist.id}.png")
  zune_root = 'http://catalog.zune.net/v3.2/en-US/music/artist'
  filename = "#{$artistPicFolder}/#{artist.id}.png"
  begin
    response = HTTParty.get("#{zune_root}?q=#{URI.encode(artist.name)}")
    xmldoc = Document.new(response.body)
    xmldoc.elements.each('a:feed/a:entry/a:id') do |element|
      id = element.text.to_s
      response = HTTParty.get("#{zune_root}/#{URI.encode(id[9..-1])}/images")
      xml = Document.new(response.body)
      xml.elements.each('a:feed/a:entry/instances/imageInstance/url') do |elem|
        url = elem.text
        `wget -nv "#{url}" -O #{filename}`
        return
      end
      return
    end
  end
end