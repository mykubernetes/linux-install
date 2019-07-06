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
