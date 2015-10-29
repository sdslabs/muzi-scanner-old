__author__ = 'gautham'

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, ForeignKey, Float, DateTime
from sqlalchemy.orm import relationship, backref

Base = declarative_base()


class Track(Base):
    __tablename__ = 'tracks'

    id = Column(Integer, primary_key=True)
    file = Column(String)
    title = Column(String)
    album_id = Column(Integer, ForeignKey('album.id'))
    genre_id = Column(Integer, ForeignKey('genre.id'))
    artist = Column(String)
    # track number
    track = Column(Integer)
    plays = Column(Integer, default=0)
    year = Column(Integer)
    length = Column(Float)
    creation_time = Column(DateTime, default=func.now())


    album = relationship("Album", backref=backref('tracks'))
    genre = relationship("Genre", backref=backref('genres'))


class Album(Base):
    __tablename__ = 'albums'

    id = Column(Integer, primary_key=True)
    album_title = Column(String)
    language = Column(String)
    info = Column(String)
    band_id = Column(Integer, ForeignKey('band.id'))
    band_name = Column(String, ForeignKey('band.name'))

    band = relationship("Band", backref=backref('bands'))


class Band(Base):
    __tablename__ = 'bands'

    id = Column(Integer, primary_key=True)
    name = Column(String)
    language = Column(String)
    info = Column(String)


class Year(Base):
    __tablename__ = 'years'

    id = Column(Integer, primary_key=True)