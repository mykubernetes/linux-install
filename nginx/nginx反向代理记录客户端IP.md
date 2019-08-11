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
