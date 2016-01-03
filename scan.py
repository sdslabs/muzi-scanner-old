import os
import sys
import pylast
import glob
import credentials
from mutagen import easymp4
from mutagen import mp3
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import IntegrityError
from sqlalchemy.sql.expression import ClauseElement
from sqlalchemy import create_engine
from schema import Track, Album, Band, Year, Genre
from utils import utils, Variables
from pics import pics

class Scanner:
    def add_track(self, variables, audio_file_path):
        filename_in_database = os.path.relpath(audio_file_path, variables.dirs.base_dir)
        if utils.check_if_track_exists(variables, filename_in_database):
            return

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
            # TODO: need to hadle exceptions more carefully here as
            # I dont what might happen in case the format of track number changes
            # TODO: lot of hardcoding, try to find better way
            # assuming that audio_file.tag.track_num[0] is in the format '2/15'
            year = int(audio_file['date'][0][:4])
            track_number = int(audio_file['tracknumber'][0].split('/')[0])
            track_duration = int(audio_file.info.length)
            genre = audio_file['genre'][0]

        except Exception as e:
            print ' %s' % e
            year = 2000
            track_number = '0'
            genre = 'Unknown'
            track_duration = 240

        try:
            track_object = variables.network.get_track(artist_name, song_title)
            song_title = track_object.get_correction()

            if variables.is_band_new:
                try:
                    artist_object = track_object.get_artist()
                    artist_name = artist_object.get_name()
                    artist_info = artist_object.get_bio_content()

                    variables.band_name = artist_name
                    session = variables.session()
                    band_instance, new = utils.get_or_create(session, Band,
                                        name=artist_name,
                                        language='English',
                                        info=artist_info)

                    variables.add_band(artist_name, False, band_instance.id)
                    session.close()
                    pics.get_band_thumbnail(variables)
                    pics.get_band_cover(variables)

                except Exception as e:
                    print "[-] Caught exception in new band " + str(e)
                    pass

            if variables.is_album_new:
                try:
                    album_object = track_object.get_album()
                    album_name = album_object.get_name()
                    album_info = album_object.get_wiki_content()

                    session = variables.session()
                    album_instance, new = utils.get_or_create(session, Album,
                                        name=album_name,
                                        info=album_info,
                                        language='English',
                                        band_id=variables.band_id,
                                        band_name=variables.band_name)
                    variables.add_album(album_name, False, album_instance.id)
                    session.close()
                    pics.get_album_thumbnail(variables)

                except Exception as e:
                    print "[-] Caught exception in new album " + str(e)
                    pass

            track_duration_from_pylast = track_object.get_duration()/1000
            # Track_duration has been assigned either 240 or the appropriate value from file tag
            # so if track_duration_from_pylast is 0 then track_duration will be used
            track_duration = track_duration_from_pylast if(track_duration_from_pylast is not 0)\
                                                else track_duration if track_duration!=0 else 240
            genre = track_object.get_top_tags(limit=1)[0].item.name

        except pylast.WSError as e:
            if e == 'Track not found':
                # Fallback to track
                track_duration = audio_file.info.length
                genre = audio_file['genre'][0]
            else:
                print '[-]pylast Exception:'+str(e)

        except AttributeError as e:
            # AttributeError here occurs when track_object was retrieved
            # but the album name could not be retrieved
            track_duration = audio_file.info.length
            genre = audio_file['genre'][0]

        except Exception as e:
            print '[-]Unkown Exception while fetching track attributes:'+str(e)
            pass

        session = variables.session()

        # If still new create using folder names
        if variables.is_band_new:
            band_instance, new = utils.get_or_create(session, Band,
                                        name=variables.band_name,
                                        language='English',
                                        info=None)
            variables.add_band(variables.band_name, False, band_instance.id)

        if variables.is_album_new:
            album_instance, new = utils.get_or_create(session, Album,
                                        name=variables.album_name,
                                        info=None,
                                        language='English',
                                        band_id=variables.band_id,
                                        band_name=variables.band_name)
            variables.add_album(variables.album_name, False, album_instance.id)

        year_instance, new = utils.get_or_create(session, Year,
                                  name = year)

        genre_instance, new = utils.get_or_create(session, Genre,
                                   name = genre)

        track, new = utils.get_or_create(session, Track,
                                   file = filename_in_database,
                                   title = song_title,
                                   album_id = variables.album_id,
                                   band_id = variables.band_id,
                                   genre_id = genre_instance.id,
                                   artist = variables.band_name,
                                   year_id = year_instance.id,
                                   length = track_duration,
                                   track = track_number)
        session.close()
        print '[+] %s - %s (%s) added' % (variables.band_name, song_title, variables.album_name)


    def add_album(self, variables, artist_dir, album):
        new, album_id = utils.check_if_album_exists(variables, album, variables.band_name)
        new = not new
        variables.add_album(album, new, album_id)

        album_dir = os.path.join(artist_dir, album)

        # Assuming that all songs are of mp3 or m4a or mp4 format
        glob_parameters = [os.path.join(album_dir,ext) for ext in ['*.mp3','*.m4a','*.mp4']]

        # Songs_path will contain the absolute path to every mp3 file in album_directory
        # reference: http://www.diveintopython.net/file_handling/os_module.html
        songs_path = []
        for glob_parameter in glob_parameters:
            songs_path.extend(glob.glob(glob_parameter))

        for audio_file_path in songs_path:
            self.add_track(variables, audio_file_path)


    def add_band(self, variables, artist):
        artist_dir = os.path.join(variables.dirs.artists, artist)
        new, band_id = utils.check_if_band_exists(variables, artist)
        new = not new
        variables.add_band(artist, new, band_id)

        for album in os.listdir(artist_dir):
            print '[+] Adding ' + album
            self.add_album(variables, artist_dir, album)

    def __init__(self):
        # Configure Session class with desired options
        Session = sessionmaker()

        # Import credentials
        db_name = credentials.get_db_name()
        db_user_name = credentials.get_db_user_name()
        db_host = credentials.get_db_host()
        db_password = credentials.get_db_password()
        db_backend = credentials.get_db_backend()

        # Later, we create the engine
        engine = create_engine('{backend}://{user}:{password}@{host}/{name}?charset=utf8'
                                .format(backend=db_backend,
                                        user=db_user_name,
                                        password=db_password,
                                        host=db_host,
                                        name=db_name),
                                        # echo=True
                                        )

        # Associate it with our custom Session class
        Session.configure(bind=engine)

        # API Credentials
        API_KEY = credentials.get_lastfm_api_key()
        API_SECRET = credentials.get_lastfm_api_secret()
        DB_NAME = credentials.get_db_name()

        network = pylast.LastFMNetwork(api_key=API_KEY,
                                       api_secret=API_SECRET,)


        # Arguments check
        if len(sys.argv) is not 5:
            print
            """Usage: $ python scan.py /path/to/songs/ /path/to/artists/cover/image directory/
            /path/to/albums/cover/image directory/ /path/to/artist/thumbnail directory/"""
            sys.exit()

        variables = Variables(sys, Session, network)

        #TODO: evaluate listdir for artists_dir lazily
        for artist in os.listdir(variables.dirs.artists):
            print '[+]>>>> Adding ' + artist
            self.add_band(variables, artist)

# Run
Scanner()
