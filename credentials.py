__author__ = 'gautham'


import json
import os


def get_credentials_file_path():
    """
    Location for the standalone credentials file in json format,
    Here I am assuming it is in the same directory as this file
    :return: String
    """
    return (os.path.join(os.path.dirname(__file__), 'data.json'))



def getdata(func):
    """Decorator to Deserialize json data and passes it to functions """
    def inner():
        with open(get_credentials_file_path()) as data_file:
            # deserialize json data to python object
            try:
                # specifically get the credentials under default category
                data = json.load(data_file)['DEFAULT']
            except Exception as e:
                # http://stackoverflow.com/questions/4308182/getting-the-exception-value-in-python
                print type(e)
                print e.message
        # pass the appropriate parameters into the function
        credential = func(data)
        return credential

    return inner


@getdata
def get_lastfm_api_key(data):
    return data["lastfm_api_key"]


@getdata
def get_lastfm_api_secret(data):
    return data["lastfm_api_secret"]

@getdata
def get_db_name(data):
    return data["db_name"]

@getdata
def get_db_user_name(data):
    return data["db_user_name"]

@getdata
def get_db_host(data):
    return data["db_host"]

@getdata
def get_db_password(data):
    return data["db_password"]

@getdata
def get_db_backend(data):
    return data["db_backend"]
