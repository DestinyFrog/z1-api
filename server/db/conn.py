import sqlite3

def get_conn():
    return sqlite3.connect('z1.sqlite3')
