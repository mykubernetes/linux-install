
1、通过openssl对密码进行加密
```
cd /etc/nginx/conf.d
指定用户名
echo -n "test:" > passwd
指定密码  
openssl passwd abc123456 >> passwd
```

2、修改nginx配置文件
```
    server {
        listen       80 default_server;
        listen       [::]:80 default_server;
        server_name  _;
        root         /usr/share/nginx/html;

        auth_basic "Please input password";      ##输入用户名密码提示框
        auth_basic_user_file /etc/nginx/conf.d/passwd;  ##配置用户名密码验证文件路径
```
