
https://blog.csdn.net/monkeyblog/article/details/90247043

1、配置upstream
```
curl -XPOST http://localhost:8001/upstreams --data "name=httpserver"
```

2、配置target
```
curl -XPOST http://localhost:8001/upstreams/httpserver/targets --data "target=localhost:8080" --data "weight=100"
```

3、配置service
```
curl -XPOST http://localhost:8001/services --data "name="tomcat" --data "host=httpserver"
```

4、配置route
```
curl -XPOST http://localhost:8001/routes --data "paths[]=/index" --data "service.id=8695cc64-16c1-43b1-95a1-5d30d0a50409"
```

插件
1、为tomcat服务添加50次/秒的限流
```
curl -XPOST http://localhost:8001/services/tomcat/plugins --data "name=rate-limiting" --data "config.second=50"
```

2、为tomcat服务添加jwt插件
```
curl -XPOST http://localhost:8001/services/tomcat/plugins --data "name=jwt"
```

3、配置在route上
```
curl -XPOST http://localhost:8001/services/{routeID}/plugins --data "name=rate-limiting" --data "config.second=50"
curl -XPOST http://localhost:8001/services/{routeID}/plugins --data "name=jwt"

```
