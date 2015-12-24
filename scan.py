__author__ = 'gautham'

import os
import sys
import pylast
import glob
import urllib
import credentials
from mutagen import easymp4
from mutagen import mp3
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import IntegrityError
from sqlalchemy.sql.expression import ClauseElement
from sqlalchemy import create_engine
from schema import Track, Album, Band, Year, Genre

def save_image(url, path):
    """
    :param url:
    :param path:
    :return nothing:
    """
    image = urllib.URLopener()
    image.retrieve(url, path)
    print ' [+image] ' + path
    return
# previously used, was may be giving some problems
#http://stackoverflow.com/questions/2546207/does-sqlalchemy-have-an-equivalent-of-djangos-get-or-create
# new one
# https://gist.github.com/codeb2cc/3302754

def get_or_create(session, model, defaults={}, **kwargs):
    try:
        query = session.query(model).filter_by(**kwargs)

        instance = query.first()

        if instance:
            return instance, False
        else:
            session.begin(nested=True)
            try:
                params = dict((k, v) for k, v in kwargs.iteritems() if not isinstance(v, ClauseElement))
                params.update(defaults)
                instance = model(**params)

                session.add(instance)
                session.commit()

                return instance, True
            except IntegrityError as e:
                session.rollback()
                instance = query.one()

                return instance, False
    except Exception as e:
        raise e
# configure Session class with desired options
Session = sessionmaker()

# import credentials
db_name = credentials.get_db_name()
db_user_name = credentials.get_db_user_name()
db_host = credentials.get_db_host()
db_password = credentials.get_db_password()
db_backend = credentials.get_db_backend()

# later, we create the engine
engine = create_engine('{backend}://{user}:{password}@{host}/{name}?charset=utf8'.format(backend=db_backend,
                                                                            user=db_user_name,
                                                                             password=db_password,
                                                                             host=db_host,
                                                                             name=db_name))

# associate it with our custom Session class
Session.configure(bind=engine)

# work with the session
session = Session()

# arguments check
if len(sys.argv) is not 5:
    print """ Usage: $ python scan.py /path/to/songs/ /path/to/artists/cover/image directory/ 
    /path/to/albums/cover/image directory/ /path/to/artist/thumbnail directory/"""
    sys.exit()
# parse the arguments
artists_directory = sys.argv[1]
artists_cover_image_directory = sys.argv[2]
albums_cover_image_directory = sys.argv[3]
artists_thumbnail_directory = sys.argv[4]

# Convert the path to absolute path
artists_directory = os.path.abspath(artists_directory)
artists_cover_image_directory = os.path.abspath(artists_cover_image_directory)
albums_cover_image_directory = os.path.abspath(albums_cover_image_directory)
artists_thumbnail_directory = os.path.abspath(artists_thumbnail_directory)

# API Credentials

API_KEY = credentials.get_lastfm_api_key()
API_SECRET = credentials.get_lastfm_api_secret()
DB_NAME = credentials.get_db_name()

network = pylast.LastFMNetwork(api_key=API_KEY,
                               api_secret=API_SECRET,
                               )

#TODO: evaluate listdir for artists_dir lazily
for artistName in os.listdir(artists_directory):
    artist_directory = os.path.join(artists_directory, artistName)
    for albumName in os.listdir(artist_directory):
        # album_data is a list which will hold the attributes of
        # all songs of the album, to write to db one album at a time
        album_data = []
        album_directory = os.path.join(artist_directory, albumName)
        # Assuming that all songs are of mp3 or m4a or mp4 format
        glob_parameters = [os.path.join(album_directory,ext) for ext in ['*.mp3','*.m4a','.mp4']]
        # songs_path will contain the absolute path to every mp3 file in album_directory
        # reference: http://www.diveintopython.net/file_handling/os_module.html
        songs_path = []
        for glob_parameter in glob_parameters:
            songs_path.extend(glob.glob(glob_parameter))

        for audio_file_path in songs_path:
            file_type = 'mp3' if '.mp3' in audio_file_path else 'm4a'
            # Get the title,artist from id3 tags
            if file_type is 'mp3':
                file_handler = mp3.EasyMP3
            elif file_type is 'm4a':
                file_handler = easymp4.EasyMP4

            audio_file = file_handler(audio_file_path)
            song_title = audio_file['title'][0]
            artist_name = audio_file['artist'][0]
            try:
                #TODO: need to hadle exceptions more carefully here as I dont what might happen in case the format of track number changes
                #TODO: lot of hardcoding, try to find better way
                # assuming that audio_file.tag.track_num[0] is in the format '2/15'
                year = int(audio_file['date'][0][:4])
                track_number = int(audio_file['tracknumber'][0].split('/')[0])
            except Exception as e:
                print ">>> %s"%e
                year = 2000
                track_number = '0'
            album_info = 'NOT AVAILABLE'
            artist_info = 'NOT AVAILABLE'

            try:
                # Make an API call get the track object for artist_name, song_title
                track_object = network.get_track(artist_name, song_title)
                # Get the required attributes(Title, Artist, Duration, Genre, Album)
                song_title = track_object.get_correction()
                artist_object = track_object.get_artist()
                artist_name = artist_object.get_name()
                artist_info = artist_object.get_bio_content()
                # Convert to seconds from milliseconds
                track_duration = track_object.get_duration()/1000
                # get_top_tags returns a list of TopItems
                # Each TopItem has item and weight attributes
                # genre can be obtained by accessing the item.name attribute
                genre = track_object.get_top_tags(limit=1)[0].item.name
                # If the album is not found, an exception is raised, and attributes are
                # obtained from id3 tags
                album_object = track_object.get_album()
                album_name = album_object.get_name()
                album_info = album_object.get_wiki_content()

            except pylast.WSError as e:
                if e=='Track not found':
                    # that means the track is not found , may be a hindi song
                    # hence fetch attributes from id3 tags
                    album_name = albumName
                    track_duration = audio_file.info.length
                    genre = audio_file['genre'][0]
                else:
                    print 'pylast Exception:'+str(e)

            except AttributeError as e:
                # AttributeError here occurs when track_object was retrieved
                # BUT the album name could not be retrieved
                # Hence, fall back to using folder names to get album_name attribute
                # Album , duration, Genre
                album_name = albumName
                track_duration = audio_file.info.length
                genre = audio_file['genre'][0]

            except Exception as e:
                # some unknown(unexpected) error
                print 'Unkown Exception while fetcing track attributes:'+str(e)
                # don't insert anything into DB
                continue
    # newly_created is True if the object is newly created
    print '>>>>>', artist_name
    band, newly_created = get_or_create(session, Band,
                         name = artist_name,
                         language = 'English',
                         info = artist_info
                         )
    album, newly_created = get_or_create(session, Album,
                          album_title = album_name,
                          language = 'English',
                          info = album_info,
                          band_id = band.id,
                          band_name = band.name
                          )
    year, newly_created = get_or_create(session, Year,
                         year = year
                         )
    genre, newly_created = get_or_create(session, Genre,
                          genre = genre
                          )
    track, newly_created = get_or_create(session, Track,
                          file = audio_file_path,
                          title = song_title,
                          album_id = album.id,
                          genre_id = genre.id,
                          artist = band.name,
                          year = year.year,
                          length = track_duration,
                          track = track_number
                          )
    # Fetching the album art, artist's cover images
    artist_id = 'NULL'

    album_id = 'NULL'
    if newly_created:
        try:
            artist_object = network.get_artist(artist_name)
            album_object = network.get_album(artist_name, album_name)
            artist_id = str(band.id)
            album_id = str(album.id)
            # save the cover images named as their respective mbid
            artist_image_path = os.path.join(artists_cover_image_directory, artist_id)+'.png'
            album_image_path = os.path.join(albums_cover_image_directory, album_id)+'.png'
            # save the artist thumbnails
            artist_thumbnail_path = os.path.join(artists_thumbnail_directory, artist_id)+'.png'

            save_image(artist_object.get_cover_image(), artist_image_path)
            save_image(album_object.get_cover_image(), album_image_path)
            # note the size argument which returns the url for a smaller image
            save_image(artist_object.get_cover_image(size=2), artist_thumbnail_path)
            # Inserting the picture paths and committing the insert
            band.cover_picture_path = artist_image_path
            band.thumbnail_path = artist_thumbnail_path
            session.add(band)
            album.cover_picture_path = album_image_path
            session.add(album)
            session.commit()
        except Exception as e:
            print 'Something wrong with cover pics: %s'%str(e)

    # Log it in console just for information
    print ' [+] %s,%s,%s,%s,%s,%s,%s,%s' % (song_title, audio_file_path, album_name, artist_name, genre.genre, track_duration,
                                      artist_id, album_id)


# Close the connection as the db is now populated
session.close()
