1、创建 swift api 子用户  
``` # radosgw-admin subuser create --uid=radosgw --subuser=radosgw:swift --access=full ```  
注意：请把 secret_key 保存下来 ，如果忘记可使用：radosgw-admin user info --uid …  

2、安装软件  
```
yum install -y python-pip
pip install --upgrade python-swiftclient
swift -A http://node01:7480/auth/1.0 -U radosgw:swift -K …. list
swift -A http://node01:7480/auth/1.0 -U radosgw:swift -K …. post second-bucket
swift -A http://node01:7480/auth/1.0 -U radosgw:swift -K …. list
```  
