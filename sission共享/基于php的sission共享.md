
部署nginx和redis
```
# yum install epel-release -y  
# yum install nginx redis -y
```

配置nginx代理php
```
# vi /etc/nginix/conf.d/www.test.conf
upstream static.wp {
   server 192.168.0.217:80;
   server 192.168.0.218:80;
}
upstream dynamic.wp {
   server 192.168.0.215:9000;
   server 192.168.0.216:9000;
}
server {
    listen       80;
    server_name  test.aliangedu.com;
    access_log  logs/wp.access.log  main;

# location ~ \.php$ {      
# 不能这么写，因为首页访问没有具体传递index.php，与JAVA隐藏后缀类似
location / {
        fastcgi_pass   dynamic.wp;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  /var/www/html$fastcgi_script_name;
        include        fastcgi_params;
}
    location ~ \.(html|css|js|jpg|png|gif)$ {
        proxy_pass http://static.wp; 
    }
}
```


1）安装php依赖的第三方库
```
# yum install gd-devel libxml2-devel libcurl-devel libjpeg-devel libpng-devel gcc -y
```

2）编译安装php
```
# wget http://docs.php.net/get/php-5.6.34.tar.gz/from/this/mirror
# tar zxvf php-5.6.34.tar.gz
# cd php-5.6.34
# ./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--with-mysql --with-mysqli \
--with-openssl --with-zlib --with-curl --with-gd \
--with-jpeg-dir --with-png-dir --with-iconv \
--enable-fpm --enable-zip --enable-mbstring

# make -j 4 && make install
```

注意： 如果在编译的时候报此错误configure: error: Cannot find OpenSSL's <evp.h> 需要安装如下软件
```
# yum install openssl openssl-devel -y
```

3) 配置php
```
# cp php.ini-production /usr/local/php/etc/php.ini
# vi /usr/local/php/etc/php.ini
date.timezone = Asia/Shanghai
```

4）配置php-fpm
```
# cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
# vim /usr/local/php/etc/php-fpm.conf
user = nginx
group = nginx
pid = run/php-fpm.pid

# cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
# chmod +x /etc/rc.d/init.d/php-fpm
# service php-fpm start
```

PHP基于Redis实现Seesion共享  
PHP安装Redis扩展模块：  
https://github.com/phpredis/phpredis  
https://github.com/phpredis/phpredis/releases  

```
# yum install autoconf
# wget https://github.com/phpredis/phpredis/archive/3.1.6.tar.gz
# tar zxvf 3.1.6.tar.gz
# cd phpredis-3.1.6/
# /usr/local/php/bin/phpize
# ./configure --with-php-config=/usr/local/php/bin/php-config
# make && make install
# /usr/local/php/bin/php -m |grep redis
# vi /usr/local/php/etc/php.ini
extension=/usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/redis.so
session.save_handler = redis
session.save_path = "tcp://192.168.0.219:6379?auth=123456"
# /etc/init.d/php-fpm restart
```
