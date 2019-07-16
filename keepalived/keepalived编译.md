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
