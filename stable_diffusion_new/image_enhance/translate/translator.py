from googletrans import Translator as google_translator

import os
import sys
import urllib.request
import json
client_id = "svCGQTdoy11rxE4nZbBV"
client_secret = "0UTjq3OsV0"


class Translator:
    def __init__(self):
        self.googletranslator = google_translator(service_urls=['translate.google.com'])
        pass
    
    def decode(self, string):
        string = string.replace("%", "%0x")
        string = string.replace(" ", "%20")
        string_list = string.split("%")[1:]
        string_to_int = [int(string,16) for string in string_list]
        decoded_string = bytearray(string_to_int).decode('utf-8')
        return decoded_string
    
    def google_translate(self, string, decode=True, dest="en"):
        if decode:
            string = self.decode(string)
            
        return self.googletranslator.translate(string, dest=dest).text
    
    def papago_translate(self, string, decode=True, dest="en"):
        if decode:
            string = self.decode(string)
            
        encQuery = urllib.parse.quote(string)
        data = "query=" + encQuery
        url = "https://openapi.naver.com/v1/papago/detectLangs"
        request = urllib.request.Request(url)
        request.add_header("X-Naver-Client-Id",client_id)
        request.add_header("X-Naver-Client-Secret",client_secret)
        response = urllib.request.urlopen(request, data=data.encode("utf-8"))
        rescode = response.getcode()
        if(rescode==200):
            response_body = response.read()
            language = response_body.decode('utf-8').split('"')[3]
            print("language: ", language)
            if language == dest:
                return string
        else:
            print("Error Code:" + rescode)
        data = "source="+language+"&target="+dest+"&text=" + encQuery
        url = "https://openapi.naver.com/v1/papago/n2mt"
        request = urllib.request.Request(url)
        request.add_header("X-Naver-Client-Id",client_id)
        request.add_header("X-Naver-Client-Secret",client_secret)
        response = urllib.request.urlopen(request, data=data.encode("utf-8"))
        rescode = response.getcode()
        if(rescode==200):
            response_body = response.read()
            json_data = json.loads(response_body.decode('utf-8'))
            return (json_data["message"]["result"]["translatedText"])
        else:
            print("Error Code:" + rescode)