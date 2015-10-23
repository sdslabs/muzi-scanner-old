__author__ = 'gautham'

import os
import sys
import sqlite3
import pylast
import glob
import eyed3
import urllib
import credentials


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


artists_directory = sys.argv[1]
# Convert the path to absolute path
artists_directory = os.path.abspath(artists_directory)

# API Credentials

API_KEY = credentials.get_lastfm_api_key()
API_SECRET = credentials.get_lastfm_api_secret()
DB_NAME = credentials.get_db_name()

network = pylast.LastFMNetwork(api_key=API_KEY,
                               api_secret=API_SECRET,
                               )
conn = sqlite3.connect(DB_NAME)
c = conn.cursor()
#TODO: evaluate listdir for artists_dir lazily
for artistName in os.listdir(artists_directory):
    artist_directory = os.path.join(artists_directory, artistName)
    for albumName in os.listdir(artist_directory):
        # album_data is a list which will hold the attributes of
        # all songs of the album, to write to db one album at a time
        album_data = []
        album_directory = os.path.join(artist_directory, albumName)
        # Assuming that all songs are of mp3 format
        glob_parameter = os.path.join(album_directory,'*.mp3')
        # songs_path will contain the absolute path to every mp3 file in album_directory
        # reference: http://www.diveintopython.net/file_handling/os_module.html
        songs_path = glob.glob(glob_parameter)
        for audio_file_path in songs_path:
            # Get the title,artist from id3 tags
            audio_file = eyed3.load(audio_file_path)
            song_title = audio_file.tag.title
            artist_name = audio_file.tag.artist
            try:
                # Make an API call get the track object for artist_name, song_title
                track_object = network.get_track(artist_name, song_title)
                # Get the required attributes(Title, Artist, Duration, Genre, Album)
                song_title = track_object.get_correction()
                artist_name = track_object.get_artist().get_name()
                # Convert to seconds from milliseconds
                track_duration = track_object.get_duration()/1000
                # get_top_tags returns a list of TopItems
                # Each TopItem has item and weight attributes
                # genre can be obtained by accessing the item.name attribute
                genre = track_object.get_top_tags(limit=1)[0].item.name
                # If the album is not found, an exception is raised, and attributes are
                # obtained from id3 tags
                album_name = track_object.get_album().get_name()

            except pylast.WSError as e:
                if e=='Track not found':
                    # that means the track is not found , may be a hindi song
                    # hence fetch attributes from id3 tags
                    album_name = albumName
                    track_duration = audio_file.info.time_secs
                    genre = audio_file.tag.genre.name
                else:
                    print 'pylast Exception:'+str(e)
            except AttributeError as e:
                # AttributeError here occurs when track_object was retrieved
                # BUT the album name could not be retrieved
                # Hence, fall back to using folder names to get album_name attribute
                # Album , duration, Genre
                album_name = albumName
                track_duration = audio_file.info.time_secs
                genre = audio_file.tag.genre.name
            except Exception as e:
                # some unknown(unexpected) error
                print 'Exception:'+str(e)
                # don't insert anything into DB
                continue
        # Fetching the album art, artist's cover images
        artist_mbid = 'NA'
        album_mbid = 'NA'
        try:
            artist_object = network.get_artist(artist_name)
            album_object = network.get_album(artist_name, album_name)
            # mbid == A unique MusicBiz ID exists for an artist as well as an album
            artist_mbid = artist_object.get_mbid()
            album_mbid = album_object.get_mbid()
            # save the cover images named as their respective mbid
            artist_image_path = os.path.join(artist_directory, artist_mbid)+'.png'
            album_image_path = os.path.join(album_directory, album_mbid)+'.png'
            save_image(artist_object.get_cover_image(), artist_image_path)
            save_image(album_object.get_cover_image(), album_image_path)
        except Exception as e:
            print str(e)
    # Log it in console just for information
    print ' [+] %s,%s,%s,%s,%s,%s,%s,%s' % (song_title, audio_file_path, album_name, artist_name, genre, track_duration,
                                      artist_mbid, album_mbid)

    album_data.append((song_title, audio_file_path, album_name, artist_name, genre, track_duration, artist_mbid, album_mbid))
    # Now that the album_data has attributes of all songs in album_name, we can INSERT into the table
    # reference: https://docs.python.org/2/library/sqlite3.html
    # (?,?,?,?,?,?) to mitigate SQL Injection
    # executemany to insert multiple rows at same time
    c.executemany('INSERT INTO SONGS VALUES (?,?,?,?,?,?,?,?)', album_data)
    # commit(save) the INSERT
    conn.commit()

# Close the connection as the db is now populated
conn.close()




