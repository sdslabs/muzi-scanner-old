# nefarious-octo-lamp

This project aims to populate a database with attributes of various songs, given the path to songs root directory.

Songs are placed in a hierarchical directory structure inside the songs root directory as follows: 

- Artist Name > AlbumName > SongName

So, a song "Problem" by Ariana Grande will be in the folder as "Arian Grande > My Everything > Problem.mp3" with rest of "My Everything" album's songs in it. 



### Libraries used:
Specified in [requirements.txt]

```sh
$ pip install -r requirements.txt
```

### USAGE
Create a data.json file in the project root. It should look something like below:
```json
{
    "DEFAULT": {
        "lastfm_api_key": "your_lastfm_api_key",
        "lastfm_api_secret": "your_lastfm_api_secret",
        "db_name": "test.db"
    },
    "PRODUCTION":{
    }
}
```
Since the present database is sqlite, no need to install database backend. Just run the below command to create a database with table SONGS

```sh
$ python createdb.py
```
And then run the below command to populate the database.
```sh
$ python getnames.py PATH/to/songs/root
```
[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does it's job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)

   [requirements.txt]: <https://raw.githubusercontent.com/GauthamGoli/nefarious-octo-lamp/master/requirements.txt>
   
   

