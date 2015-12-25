import urllib
from sqlalchemy.exc import IntegrityError
from sqlalchemy.sql.expression import ClauseElement

class Utils:
    def save_image(url, path):
        """
        :param url:
        :param path:
        :return nothing:
        """
        image = urllib.URLopener()
        image.retrieve(url, path)

    def get_or_create(session, model, **kwargs):
        try:
            query = session.query(model).filter_by(**kwargs)

            instance = query.first()

            if instance:
                return instance, False
            else:
                session.begin(nested=True)
                try:
                    params = dict((k, v) for k, v in kwargs.iteritems() if not isinstance(v, ClauseElement))

                    instance = model(**params)

                    session.add(instance)
                    session.commit()

                    return instance, True
                except IntegrityError as e:

                    # We have failed to add track, rollback current session and continue
                    session.rollback()
                    print "\t\t[-]Failed to add, continuing"

        except Exception as e:
            raise e

    def check_if_track_exists(variables, file_path):
        session = variables.session()
        query = session.query(Track).filter_by(file=file_path)
        instance = query.first()
        session.close()

        if instance:
            return True
        else:
            return False

    def update_model(session, model, id, name, info):
        instance = session.query(model).filter_by(id=id).first()
        instance.info = info
        instance.name = name
        session.commit()
        session.close()


class Dirs:
    def __init__(sys_param):
        artists = sys_param.argv[1]
        artists_cover = sys_param.argv[2]
        albums_thumbnail = sys_param.argv[3]
        artist_thumbnail = sys_param.argv[4]

        # Convert the path to absolute path
        self.artists = os.path.abspath(artists)

        # Base dir should be where both English and Hindi songs are present
        self.base_dir = os.path.abspath(artists + '/..')

        self.artists_cover = os.path.abspath(artists_cover)
        self.albums_thumbnail = os.path.abspath(albums_thumbnail)
        self.artist_thumbnail = os.path.abspath(artist_thumbnail)


class Variables:
    def __init__(sys_param, session, network):
        self.dirs = Dirs(sys_param)
        self.session = session
        self.network = network

    def add_band(band_id, band_name, is_new):
        self.band_id = band_id
        self.is_band_new = is_new
        self.band_name = band_name

    def add_album(album_id, album_name, is_new):
        self.album_id = album_id
        self.is_album_new = is_new
        self.album_name = album_name

utils = Utils()
