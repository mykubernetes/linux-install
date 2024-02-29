软件下载https://www.keepalived.org/software/  


1、安装编译依赖插件
```
yum install -y gcc openssl-devel popt-devel
```  

2、下载源码包  
```
wget http://www.keepalived.org/software/keepalived-1.4.2.tar.gz
tar -zxvf keepalived-1.4.2.tar.gz
```  

3、编译  
```
cd keepalived-1.4.2
mkdir /usr/local/keepalived
./configure --prefix=/usr/local/keepalived  
make && make install
```  

4、配置keepalived  
```
cp keepalived/etc/init.d/keepalived /etc/init.d/
vim /etc/keepalived/keepalived.conf
```  

5、启动keepalived并设置开机自启动  
```
systemctl start keepalived
systemctl enable keepalived
```  


6、脚本启动
```
#!/bin/bash

KEEPALIVED_BIN="/usr/local/keepalived/sbin/keepalived"  # 替换为你的keepalived二进制文件的实际路径
CONFIG_FILE="/etc/keepalived/keepalived.conf"  # 替换为你的keepalived配置文件的实际路径

# 启动keepalived服务
start_keepalived() {
    echo "Starting Keepalived..."
    $KEEPALIVED_BIN -n -f $CONFIG_FILE
}

# 停止keepalived服务（如果需要）
stop_keepalived() {
    echo "Stopping Keepalived..."
    pid=$(pidof keepalived)
    if [ -n "$pid" ]; then
        kill -TERM $pid
    fi
}

# 根据参数决定执行的操作
case "$1" in
    start)
        start_keepalived
        ;;
    stop)
        stop_keepalived
        ;;
    restart)
        stop_keepalived
        sleep 2
        start_keepalived
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac

exit 0
```

```
chmod +x /usr/local/bin/manage_keepalived.sh
```


```
/usr/local/bin/manage_keepalived.sh start
/usr/local/bin/manage_keepalived.sh stop
/usr/local/bin/manage_keepalived.sh restart
```
