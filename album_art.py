# After hours of trying,
# I couldn't get the ruby script working
# So, I made a similar one for python

import sys
import pylast
import yaml
import MySQLdb
import os

API_KEY = "1046bf7d632bb797c7d3430962cc2549"
API_SECRET = "a973b39e259ec530d08d0daad7ac718d"

network = pylast.get_lastfm_network(API_KEY, API_SECRET)

print "Initialized all modules"

dbconfig = yaml.load(open('database.yml', 'r'))
db = MySQLdb.connect(dbconfig['host'], dbconfig['username'], dbconfig['password'], dbconfig['database'])

print "Initialized database"

try:
    pics_folder = sys.argv[1]
except Exception:
    raise SystemExit

cursor = db.cursor()
cursor.execute('SELECT * FROM albums WHERE language=\'English\'')
result = cursor.fetchall()
errors = []

for row in result:
    try:
        album_name = row[1]
        album_id = str(row[0])
        filename = pics_folder + '/' + album_id + '.jpg'
        if os.path.exists(filename):
            continue
        cursor.execute('SELECT artist FROM tracks WHERE album=\'' + album_id + '\'')
        artist_name = cursor.fetchall()[0][0]
        album_obj = pylast.Album(artist_name, album_name, network)
        album_uri = album_obj.get_cover_image()
        bash_command = 'wget -nv ' + album_uri + ' -O ' + filename
        print album_name, artist_name
        os.system(bash_command)
    except Exception:
        errors.append([album_name, artist_name])

print errors
