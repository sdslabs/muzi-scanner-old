# Muzi Scanner

This project aims to populate a database with attributes of various songs, given the path to songs root directory.
The songs can be of either mp3 or mp4 or m4a format.

Songs are placed in a hierarchical directory structure inside the songs root directory as follows: 

- Artist Name > AlbumName > SongName

So, a song "Problem" by Ariana Grande will be in the folder as "Arian Grande > My Everything > Problem.mp3" with rest of "My Everything" album's songs in it. 


## Prerequisites

Install following prerequisites:

- `apt-get install libmysqlclient-dev python-dev python-setuptools`

## Libraries used:
Specified in [requirements.txt]

```sh
$ pip install -r requirements.txt
```

## Usage

Create a data.json file in the project root. It should look something like below:

```json
{
    "DEFAULT": {
        "lastfm_api_key": "api_key",
        "lastfm_api_secret": "api_secret",
        "db_backend": "mysql",
        "db_name": "test",
        "db_user_name": "test",
        "db_password": "password",
        "db_host": "local"
    },
    "PRODUCTION":{
    }
}
```
After specifying the necessary credentials, run the below command to create database

```sh
$ python createdb.py
```

Scanner Usage Examples
```sh
$ python scan.py -a PATH/to/songs/root/ -atc ~/artist_cover_image_directory/ -abt ~/albums_thumb_image_directory/ -att ~/artist_thumbnail_directory/
```
To fix missing images use the option ```--fix-missing```

```sh
$ python scan.py --fix-missing -a PATH/to/songs/root/ -atc ~/artist_cover_image_directory/ -abt ~/albums_thumb_image_directory/ -att ~/artist_thumbnail_directory/
```

Scanner Usage Help:

```sh
$ python scan.py -h
```

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does it's job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [requirements.txt]: <https://raw.githubusercontent.com/GauthamGoli/nefarious-octo-lamp/master/requirements.txt>
   
   

