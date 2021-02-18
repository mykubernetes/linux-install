
https://linuxops.org/category/Kong.html


https://blog.csdn.net/monkeyblog/article/details/90247043


```
upstream helloUpstream {                        #kong的upstream模块
    server localhost:3000 weight=100;           #kong的target模块
}

server { 
    listen  80;
    location /hello {                           #kong的route模块
        proxy_pass http://helloUpstream;        #kong的service模块
    }
}
```
- upstream 是对上游服务器的抽象；
- target 代表了一个物理服务，是 ip + port 的抽象；
- service 是抽象层面的服务，他可以直接映射到一个物理服务(host 指向 ip + port)，也可以指向一个 upstream 来做到负载均衡；
- route 是路由的抽象，他负责将实际的 request 映射到 service。

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
