import sqlite3


def createdb(db_name='test.db'):
    db_name = 'test.db'
    # This will automatically create a db if it does not exist
    conn = sqlite3.connect(db_name)

    conn.execute('''CREATE TABLE SONGS
            (TITLE       TEXT     NOT NULL,
             FILEPATH    TEXT     NOT NULL,
             ALBUM       TEXT     NOT NULL,
             ARTIST      TEXT     NOT NULL,
             GENRE       CHAR(20) NOT NULL,
             LENGTH      INT      NOT NULL);''')

    print "Created db %s with TABLE SONGS" % db_name

    # Close the connection to db
    conn.close()


if __name__ == '__main__':
    createdb()