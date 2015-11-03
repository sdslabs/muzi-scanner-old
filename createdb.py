from schema import Base
from sqlalchemy import create_engine
from sqlalchemy_utils import database_exists, create_database, drop_database
import credentials
# import credentials
db_name = credentials.get_db_name()
db_user_name = credentials.get_db_user_name()
db_host = credentials.get_db_host()
db_password = credentials.get_db_password()

# later, we create the engine
engine = create_engine('postgresql://{user}:{password}@{host}/{name}'.format(user=db_user_name,
                                                                             password=db_password,
                                                                             host=db_host,
                                                                             name=db_name))


if __name__ == '__main__':
    # create db if it doesn't exist
    if database_exists(engine.url):
        print 'Dropping and recreating database'
        drop_database(engine.url)
    try:
        create_database(engine.url)
        Base.metadata.create_all(engine)
        print "database created."
    except Exception as e:
        print str(e)