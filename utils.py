import urllib
import os
from sqlalchemy.exc import IntegrityError
from sqlalchemy.sql.expression import ClauseElement
from schema import Track, Album, Band, Year, Genre

class Utils:
    def save_image(self, url, path):
        """
        :param url:
        :param path:
        :return nothing:
        """
        image = urllib.URLopener()
        image.retrieve(url, path)

    def get_or_create(self, session, model, **kwargs):
        try:
            query = session.query(model).filter_by(**kwargs)

            instance = query.first()

            if instance:
                return instance, False
            else:
                try:
                    params = dict((k, v) for k, v in kwargs.iteritems() if not isinstance(v, ClauseElement))

                    instance = model(**params)
                    session.add(instance)
                    session.commit()

                    return instance, True
                except IntegrityError as e:
                    # We have failed to add track, rollback current session and continue
                    session.rollback()
                    print "[-]Failed to add, continuing"

        except Exception as e:
            raise e

    def check_if_track_exists(self, variables, file_path):
        session = variables.session()
        query = session.query(Track).filter_by(file=file_path)
        instance = query.first()
        session.close()

        if instance:
            return True
        else:
            return False

    def check_if_band_exists(self, variables, name):
        session = variables.session()
        query = session.query(Band).filter_by(name=name)
        instance = query.first()
        session.close()
        if instance:
            return True, instance.id
        else:
            return False, None

    def check_if_album_exists(self, variables, name, band_name):
        session = variables.session()
        query = session.query(Album).filter_by(name=name, band_name=band_name)
        instance = query.first()
        session.close()
        if instance:
            return True, instance.id
        else:
            return False, None

    def update_model(self, session, model, id, name, info):
        instance = session.query(model).filter_by(id=id).first()
        instance.info = info
        instance.name = name
        session.commit()
        session.close()

    def check_if_album_thumbnail_exists(self, variables):
        return str(variables.album_id) in \
               [img.strip('.png') for img in os.listdir(variables.dirs.albums_thumbnail)]

    def check_if_artist_thumbnail_exists(self, variables):
        return str(variables.band_id) in \
               [img.strip('.png') for img in os.listdir(variables.dirs.artist_thumbnail)]

    def check_if_artist_cover_exists(self, variables):
        return str(variables.band_id) in \
               [img.strip('.jpg') for img in os.listdir(variables.dirs.artists_cover)]


class Dirs:
    def __init__(self, arguments):
        artists = arguments.artists_dir
        artists_cover = arguments.artist_cover_dir
        albums_thumbnail = arguments.album_thumbnail_dir
        artist_thumbnail = arguments.artist_thumbnail_dir

        # Convert the path to absolute path
        self.artists = os.path.abspath(artists)

        # Base dir should be where both English and Hindi songs are present
        self.base_dir = os.path.abspath(artists + '/..')

        self.artists_cover = os.path.abspath(artists_cover)
        self.albums_thumbnail = os.path.abspath(albums_thumbnail)
        self.artist_thumbnail = os.path.abspath(artist_thumbnail)


class Variables:
    def __init__(self, arguments, session, network):
        self.dirs = Dirs(arguments)
        self.arguments = arguments
        self.session = session
        self.network = network
        self.track_data = {'year':2000,'track_number':'0','track_duration':240,'genre':'unknown'}

    def add_band(self, band_name, is_new, band_id = None):
        self.band_id = band_id
        self.is_band_new = is_new
        self.band_name = band_name

    def add_album(self, album_name, is_new, album_id = None):
        self.album_id = album_id
        self.is_album_new = is_new
        self.album_name = album_name

    def store_track_data(self, keys, values):
        for key,value in zip(keys,values):
            if (value is None and not self.track_data.has_key(key)) or (value is not None):
                self.track_data[key] = value

    def reset_track_data(self):
        self.track_data = {'year':2000,'track_number':'0','track_duration':240,'genre':'unknown'}

utils = Utils()
