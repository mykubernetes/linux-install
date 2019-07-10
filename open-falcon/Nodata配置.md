nodata用于检测监控数据的上报异常

```
{
    "debug": true,
    "http": {
        "enabled": true,
        "listen": "0.0.0.0:6090"
    },
    "plus_api":{
        "connectTimeout": 500,
        "requestTimeout": 2000,
        "addr": "http://127.0.0.1:8080",  #falcon-plus api模块的运行地址
        "token": "default-token-used-in-server-side"  #用于和falcon-plus api模块的交互认证token
    },
    "config": {
        "enabled": true,
        "dsn": "root:@tcp(127.0.0.1:3306)/falcon_portal?loc=Local&parseTime=true&wait_timeout=604800",
        "maxIdle": 4
    },
    "collector":{
        "enabled": true,
        "batch": 200,
        "concurrent": 10
    },
    "sender":{
        "enabled": true,
        "connectTimeout": 500,
        "requestTimeout": 2000,
        "transferAddr": "127.0.0.1:6060",  #transfer的http监听地址,一般形如"domain.transfer.service:6060"
        "batch": 500
    }
}
```  


```
# 启动服务
./open-falcon start nodata

# 停止服务
./open-falcon stop nodata

# 检查日志
./open-falcon monitor nodata
```  
