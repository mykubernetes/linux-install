#!/usr/bin/python
# -*- coding: utf-8 -*-
import requests
import json
import sys
import os
  
headers = {'Content-Type': 'application/json;charset=utf-8'}
api_url = "https://oapi.dingtalk.com/robot/send?access_token=d4228bafa2a6ee69354752bc6e4a6a618c571610109a43115cbfc38b144596a0"    #钉钉webhook
  
def msg(text):
    json_text= {
     "msgtype": "text",
     "text": {
         "content": text                 #内容
     },
     "at": {
         "atMobiles": [
             "186..."                    #主动@的人
         ], 
         "isAtAll": False                #是否@所有人
     }
    }
    print requests.post(api_url,json.dumps(json_text),headers=headers).content
      
if __name__ == '__main__':
    text = sys.argv[1]
    msg(text)
