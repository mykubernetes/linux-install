

http://nginx.org/download/


https://mp.weixin.qq.com/s/DN_YdsQe6wMqhVXRyM_aqw


设置nginx日志格式
===
1.安装nginx
```
# yum -y install nginx
```

2.配置nginx日志格式
```
# vim /etc/nginx/nginx.conf
http {
··············
    log_format  main '{"时间":"$time_iso8601",'
                       '"客户端外网地址":"$http_x_forwarded_for",'
                       '"客户端内网地址":"$remote_addr",'
                       '"状态码":$status,'
                       '"传输流量":$body_bytes_sent,'
                       '"跳转来源":"$http_referer",'
                       '"URL":"$request",'
                       '"浏览器":"$http_user_agent",'
                       '"请求响应时间":$request_time,'
                       '"后端地址":"$upstream_addr"}';

    access_log  /var/log/nginx/access.log  main;
··············
}
```

3.启动nginx
```
# systemctl start nginx
# systemctl enable nginx
```

4.访问产生日志查看效果
```
# curl 127.0.0.1

# tail /var/log/nginx/access.log 
{"时间":"2021-07-12T11:29:33+08:00","客户端外网地址":"-","客户端内网地址":"127.0.0.1","状态码":200,"传输流量":4833,"跳转来源":"-","URL":"GET / HTTP/1.1","浏览器":"curl/7.29.0","请求响应时间":0.000,"后端地址":"-"}
```
