1、在服务器上创建基于s3a的swift api子用户  
```
$ radosgw-admin subuser create --uid=radosgw --subuser=radosgw:swift --access=full
...
"subusers": [
{
"id": "radosgw:swift",
"permissions": "full-control"
}
],
"keys": [
{
"user": "radosgw",
"access_key": "N5UJH6WDNT2FH5WUMHIC",
"secret_key": "ja0kAxtM0kSvhl2qY4Ruww4omZPvd72ulktguOYU"
}
],
"swift_keys": [
{
"user": "radosgw:swift",
"secret_key": "9c13SH3hJ2Uf06GVixFIF52fjMBm33qvQ5e00dOC"
}
],
...
```  
注意：请把 secret_key 保存下来 ，如果忘记可使用：radosgw-admin user info --uid …  

2、安装软件  
```
# yum install -y python-pip
# pip install --upgrade python-swiftclient

# swift -A http://node01:7480/auth/1.0 -U radosgw:swift -K 9c13SH3hJ2Uf06GVixFIF52fjMBm33qvQ5e00dOC list
first-bucket
# swift -A http://node01:7480/auth/1.0 -U radosgw:swift -K 9c13SH3hJ2Uf06GVixFIF52fjMBm33qvQ5e00dOC post second-bucket

# swift -A http://node01:7480/auth/1.0 -U radosgw:swift -K 9c13SH3hJ2Uf06GVixFIF52fjMBm33qvQ5e00dOC list
first-bucket
second-bucket
```  
