心跳服务器，公司所有agent都会连到HBS，每分钟发一次心跳请求  


```
{
    "debug": true,
    "database": "root:password@tcp(127.0.0.1:3306)/falcon_portal?loc=Local&parseTime=true", # Portal的数据库地址
    "hosts": "", # portal数据库中有个host表，如果表中数据是从其他系统同步过来的，此处配置为sync，否则就维持默认，留空即可
    "maxIdle": 100,
    "listen": ":6030", # hbs监听的rpc地址
    "trustable": [""],
    "http": {
        "enabled": true,
        "listen": "0.0.0.0:6031" # hbs监听的http地址
    }
}
```  
如果先部署了agent，后部署的hbs，那咱们部署完hbs之后需要回去修改agent的配置，把agent配置中的heartbeat部分enabled设置为true，addr设置为hbs的rpc地址。如果hbs的配置文件维持默认，rpc端口就是6030，http端口是6031，agent中应该配置为hbs的rpc端口。



启动停止  
```
# 启动
./open-falcon start hbs

# 停止
./open-falcon stop hbs

# 查看日志
./open-falcon monitor hbs

```  
