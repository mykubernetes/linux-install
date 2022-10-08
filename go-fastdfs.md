1、部署go-fastdfs
```
wget --no-check-certificate  https://github.com/sjqzhang/go-fastdfs/releases/download/v1.3.1/fileserver -O fileserver && chmod +x fileserver && ./fileserver

# 运行
./fileserver

#部署多台修改conf下的cfg.json
#"集群": "集群列表,注意为了高可用，IP必须不能是同一个,同一不会自动备份，且不能为127.0.0.1,且必须为内网IP，默认自动生成",
"peers": ["http://192.168.103.47:7009","http://192.168.103.46:7009","http://192.168.103.48:7009"],
 "enable_distinct_file": false,
```


2、配置nginx代理
```
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;
    client_max_body_size 2048m;
    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;
    upstream go-fastdfs {
            server 192.168.101.66:7009;
            server 192.168.101.67:7009;
            server 192.168.101.68:7009;
    }
    server {
            listen       8881;
            server_name  localhost;
            location / {
                proxy_set_header Host $host; #notice:very important(注意)
                proxy_set_header X-Real-IP $remote_addr; #notice:very important(注意)
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; #notice:very important(注意)
                proxy_pass http://go-fastdfs;
            }
    }
    #gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
```
