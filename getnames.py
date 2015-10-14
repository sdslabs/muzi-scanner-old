__author__ = 'admin'

import os
import sys
import sqlite3
import pylast
import glob
import eyed3
import credentials

artists_directory = sys.argv[1]

# API Credentials

API_KEY = credentials.get_lastfm_api_key()
API_SECRET = credentials.get_lastfm_api_secret()
DB_NAME = credentials.get_db_name()

network = pylast.LastFMNetwork(api_key=API_KEY,
                               api_secret=API_SECRET,
                               )
conn = sqlite3.connect(DB_NAME)
c = conn.cursor()

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
                # Get the required attributes(Title, Album, Artist, Duration, Genre)
                song_title = track_object.get_title()
                # If the album is not found, an exception is raised, and attributes are
                # obtained from id3 tags
                album_name = track_object.get_album().get_name()
                artist_name = track_object.get_artist().get_name()
                # Convert to seconds from milliseconds
                track_duration = track_object.get_duration()/1000.0
                genre = track_object.get_top_tags()[0][0].get_name()
            except Exception as e:
                # Most probably the track could not be found, hence use id3 tags
                print str(e)
                # Album , duration, Genre
                album_name = albumName
                track_duration = audio_file.info.time_secs
                genre = audio_file.tag.genre.name
            album_data.append((song_title, audio_file_path, album_name, artist_name, genre, track_duration))
        # Now that the album_data has attributes of all songs in album_data we can INSERT into the table
        # reference: https://docs.python.org/2/library/sqlite3.html
        # (?,?,?,?,?,?) to mitigate SQL Injection
        # executemany to insert multiple rows at same time
        c.executemany('INSERT INTO SONGS VALUES (?,?,?,?,?,?)', album_data)
        # commit(save) the INSERT
        conn.commit()
# Close the connection as the db is now populated
conn.close()




