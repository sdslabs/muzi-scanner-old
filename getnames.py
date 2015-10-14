__author__ = 'admin'

import os
import sys
import sqlite3
import glob
import eyed3
import credentials

artists_directory = sys.argv[1]

# API Credentials

API_KEY = credentials.get_lastfm_api_key()
API_SECRET = credentials.get_lastfm_api_secret()

network = pylast.LastFMNetwork(api_key=API_KEY,
                               api_secret=API_SECRET,
                               )

for artistName in os.listdir(artists_directory):
    artist_directory = os.path.join(artists_directory, artistName)
    for albumName in os.listdir(artist_directory):
        album_directory = os.path.join(artist_directory, albumName)
        # Assuming that all songs are of mp3 format
        glob_parameter = os.path.join(album_directory,'*.mp3')
        # songs_path will contain the absolute path to every mp3 file in album_directory
        # reference: http://www.diveintopython.net/file_handling/os_module.html
        songs_path = glob.glob(glob_parameter)
        for audio_file_path in songs_path:
            audio_file = eyed3.load(audio_file_path)
            song_name = audio_file.tag.title
            artist_name = audio_file.tag.artist
            track_object = network.get_track(artist_name, song_name)
            exit()


