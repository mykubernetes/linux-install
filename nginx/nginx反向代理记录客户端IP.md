```
user  nginx;
worker_processes  1;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  logs/access.log  main;

    sendfile        on;
    tcp_nopush     on;
    keepalive_timeout  65;

    gzip  on;

    server {


        listen       80;
        server_name  nginx.com;

        location / {
           proxy_pass http://test;
           proxy_set_header   Host             $host;
           proxy_set_header   X-Real-IP        $remote_addr;
           proxy_set_header  X-Forwarded-For  $proxy_add_x_forwarded_for;

        }

    }


    upstream test {
       server 192.168.101.67:8080;
       server 192.168.101.68:8080;
    }

}
```  


nginx WEB记录日志格式
```
http {
    include       mime.types;
    default_type  application/octet-stream;
 
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
 
    access_log  logs/access.log  main;
```  


修改nginx日志文件格式，并重启nginx  
```
# vim /etc/nginx/nginx.conf
log_format main '{"Request_time":"$time_local",'
                '"Request_Real_Client":"$remote_addr",'
                '"Request_Mothod":"$request",'
                '"Forward_Real_WebServer_Status_Code":"$status",'
                '"Request_Size":"$body_bytes_sent",'
                '"Request_Http_Referer":"$http_referer"}'
                '"Request_User_Agent":"$http_user_agent",'
                '"Forward_Real_WebServer":"$http_x_forwarded_for"';
# nginx -s reload


查看记录的日志
{"Request_time":"12/Jun/2019:14:52:47 +0800","Request_Real_Client":"192.168.7.80","Request_Mothod":"GET / HTTP/1.1","Forward_Real_WebServer_Status_Code":"304",
"Request_Size":"0","Request_Http_Referer":"-"}"Request_User_Agent":"Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) 
Chrome/74.0.3729.169 Safari/537.36","Forward_Real_WebServer":"192.168.1.50"
```  


- $remote_addr # 发起请求的客户端所在ip地址
- $remote_user # 发起请求的客户端用户名称，获取不到则显示为 -
- $time_local # 用来记录访问时间与时区(依赖nginx服务器本地时间)，获取不到则显示为 -
- $time_iso8601 #类似$time_local，不同的是这里采用ISO 8601标准格式 
- $request # 记录发起的请求，形如 POST /zentaopms/www/index.php?m=user&f=login&referer=L3plbnRhb3Btcy93d3cvaW5kZXgucGhw HTTP/1.1
- $status # 记录响应状态，比如 200
- $request_time # 记录请求处理时间（以秒为单位，携带毫秒的解决方案），从读取客户端第一个字节开始算起，到发送最后一个字节给客户端的时间间隔
- $upstream_response_time # 记录nginx从后端服务器(upstream server)获取响应的时间
- $request_length # 记录请求长度(包括请求行，请求头，请求体)
- $gzip_ratio # 记录nginx gzip压缩比例，获取不到则显示为 -
- $bytes_sent # 发送给客户端的字节数
- $body_bytes_sent # 发送给客户端的响应体字节数
- $connection_requests # 单个连接的并发请求数
- $http_referer # url跳转来源
- $http_user_agent # 记录用户代理信息（通常是浏览器信息
- $http_x_forwarded_for # 当为了承受更大的负载使用反向代理时，web服务器不能获取真实的客户端IP，$remote_addr获取到的是反向代理服务器的ip，这种情况下，代理服务器通常会增加一个叫做x_forwarded_for的信息头，把连接它的真实客户端IP加到这个信息头里，这样就能保证网站的web服务器能获取到真实IP，获取不到则显示为 -
- $connection # 连接序列号
- $msec # 写入日志的时间（以秒为单位，携带毫秒的解决方案）
- $pipe # 如果为管道请求则显示为p，否则显示为 .
- $http_host # 请求地址，即浏览器中你输入的地址（IP或域名）格式www.tom.com/192.168.101.71
- $upstream_addr # 后台upstream的地址，即真正提供服务的主机地址
- $upstream_status # upstream状态

阿里官方提供日志格式
https://help.aliyun.com/document_detail/28988.html?spm=a2c4g.11186623.6.744.68af49falEJ4wI
