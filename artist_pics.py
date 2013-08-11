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
cursor.execute('SELECT * FROM bands WHERE language=\'English\'')
result = cursor.fetchall()
errors = []

for row in result:
    try:
        artist_name = row[1]
        artist_id = str(row[0])
        filename = pics_folder + '/' + artist_id + '.jpg'
        if os.path.exists(filename):
            continue
        artist_obj = pylast.Artist(artist_name, network)
        artist_uri = artist_obj.get_cover_image()
        bash_command = 'wget -nv ' + artist_uri + ' -O ' + filename
        print artist_name
        os.system(bash_command)
    except Exception:
        errors.append(artist_name)

print errors
