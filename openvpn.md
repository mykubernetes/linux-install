https://linuxops.org/blog/linux/openvpn.html

1.安装epel扩展源  
---
``` # yum -y install epel-release ```  

2.为了保证OpenVPN的安装，需要使用easy-rsa秘钥生成工具生成证书  
---
``` # yum -y install easy-rsa -y ```   
注：centos7安装的是三的版本easy-rsa.noarch 0:3.0.3-1.el7  
    centos6安装的是二的版本  

3.生成秘钥证书前，需要准备vars文件  
---
```
# mkdir /opt/easy-rsa
# cd /opt/easy-rsa/
# cp -a /usr/share/easy-rsa/3.0.3/* ./
# cp -a /usr/share/doc/easy-rsa-3.0.3/vars.example ./vars    #不拷贝，下边为精简配置
# cat vars
if [ -z "$EASYRSA_CALLER" ]; then
        echo "You appear to be sourcing an Easy-RSA 'vars' file." >&2
        echo "This is no longer necessary and is disallowed. See the section called" >&2
        echo "'How to use this file' near the top comments for more details." >&2
        return 1
fi
set_var EASYRSA_DN  "cn_only"
set_var EASYRSA_REQ_COUNTRY "CN"                    #所在的国家
set_var EASYRSA_REQ_PROVINCE "Shanghai"             #所在的省份
set_var EASYRSA_REQ_CITY "Shanghai"                 #所在的城市
set_var EASYRSA_REQ_ORG "YY"                        #所在的组织
set_var EASYRSA_REQ_EMAIL "123456@qq.com"           #邮箱的地址
set_var EASYRSA_NS_SUPPORT "yes"
```  

4.初始化生成证书
---

#1.初始化，在当前目录创建PKI目录，用于存储证书 
``` 
# ./easyrsa init-pki

Note: using Easy-RSA configuration from: ./vars

init-pki complete; you may now create a CA or requests.
Your newly created PKI dir is: /opt/easy-rsa/pki           #生产一个pki目录

# tree  pki/
pki/
├── private
└── reqs

2 directories, 0 files
```  

#2.创建根证书，会提示设置密码，用于ca对之后生成的server和client证书签名时使用，其他可默认  
```
# ./easyrsa build-ca

Note: using Easy-RSA configuration from: ./vars
Generating a 2048 bit RSA private key
.........................................................................+++
.............................................................+++
writing new private key to '/opt/easy-rsa/pki/private/ca.key.aAXtpvJrtQ'
Enter PEM pass phrase:               #输入密码
Verifying - Enter PEM pass phrase:        #确认密码
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:       #回车确认，不用输入

CA creation complete and you may now import and sign cert requests.
Your new CA certificate file for publishing is at:
/opt/easy-rsa/pki/ca.crt        #会创建ca文件
```  

#3.创建server端证书和私钥文件，nopass表示不加密私钥文件，其他可默认  
```
# ./easyrsa gen-req server nopass              #server为文件名，可更改

Note: using Easy-RSA configuration from: ./vars
Generating a 2048 bit RSA private key
..........................................................+++
.......................................+++
writing new private key to '/opt/easy-rsa/pki/private/server.key.pzw2afEph2'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [server]:           #回车

Keypair and certificate request completed. Your files are:
req: /opt/easy-rsa/pki/reqs/server.req                   #生成请求文件，下一步为server.req设置签名成为公钥
key: /opt/easy-rsa/pki/private/server.key                #生成私钥文件
```  

#4.给server端证书签名，首先是对一些信息的确认，可以输入yes，然后创建ca根证书时设置的密码  
```
# ./easyrsa sign server server

Note: using Easy-RSA configuration from: ./vars


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a server certificate for 3650 days:      #证书时间10年

subject=
    commonName                = server


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes                #输入yes
Using configuration from ./openssl-1.0.cnf
Enter pass phrase for /opt/easy-rsa/pki/private/ca.key:         #输入之前设置的密码
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'server'
Certificate is to be certified until Apr 22 02:50:42 2029 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /opt/easy-rsa/pki/issued/server.crt    #生成为公钥文件
```  

#5.创建Diffie-Hellman文件，秘钥交换时的Diffie-Hellman算法  
```
# ./easyrsa gen-dh        #速度有点慢
DH parameters of size 2048 created at /opt/easy-rsa/pki/dh.pem  #生产dh.pem交换文件
```  

#6.创建client端证书和私钥文件，nopass表示不加密私钥文件，其他可默认  
```
# ./easyrsa gen-req client nopass

Note: using Easy-RSA configuration from: ./vars
Generating a 2048 bit RSA private key
...........................+++
................................+++
writing new private key to '/opt/easy-rsa/pki/private/client.key.iKlNgvT9YZ'
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Common Name (eg: your user, host, or server name) [client]:          #回车

Keypair and certificate request completed. Your files are:
req: /opt/easy-rsa/pki/reqs/client.req        #客户端请求文件
key: /opt/easy-rsa/pki/private/client.key     #客户端私钥文件
```  

#7.给client端证书签名，首先是对一些信息的确认，可以输入yes，然后创建ca根证书时设置的密码  
```
# ./easyrsa sign client client

Note: using Easy-RSA configuration from: ./vars


You are about to sign the following certificate.
Please check over the details shown below for accuracy. Note that this request
has not been cryptographically verified. Please be sure it came from a trusted
source or that you have verified the request checksum with the sender.

Request subject, to be signed as a client certificate for 3650 days:

subject=
    commonName                = client


Type the word 'yes' to continue, or any other input to abort.
  Confirm request details: yes              #输入yes
Using configuration from ./openssl-1.0.cnf
Enter pass phrase for /opt/easy-rsa/pki/private/ca.key:     #输入密码
Check that the request matches the signature
Signature ok
The Subject's Distinguished Name is as follows
commonName            :ASN.1 12:'client'
Certificate is to be certified until Apr 22 03:03:53 2029 GMT (3650 days)

Write out database with 1 new entries
Data Base Updated

Certificate created at: /opt/easy-rsa/pki/issued/client.crt          #生成公钥证书
```  

5、安装openvpn
---
1.安装openvpn  
```
# yum install openvpn -y
```  

2.配置openvpn
```
# cd /etc/openvpn/
# cp /usr/share/doc/openvpn-2.4.7/sample/sample-config-files/server.conf /etc/openvpn/   #此处不拷贝使用精简版
# cat server.conf
port 1194                               #端口
proto udp                               #协议
dev tun                                 #采用路由隧道模式tun

ca ca.crt                               #ca证书文件位置
cert server.crt                         #服务端公钥名称
key server.key                          #服务端私钥名称
dh dh.pem                               #交换证书

server 10.8.0.0 255.255.255.0           #给客户端分配地址池，注意：不能和VPN服务器内网网段有相同
push "route 172.16.1.0 255.255.255.0"   #允许客户端访问内网172.16.1.0网段
ifconfig-pool-persist ipp.txt           #地址池记录文件位置

keepalive 10 120                        #存活时间，10秒ping一次,120 如未收到响应则视为断线
max-clients 100                         #最多允许100个客户端连接
client-to-client                        #如果客户端都是用一个证书和密钥连接VPN，需要打开这个选项

status openvpn-status.log               #状态日志路径
verb 3                                  #调试信息级别
log /var/log/openvpn.log                #运行日志

persist-key     #通过keepalive检测超时后，重新启动VPN，不重新读取keys，保留第一次使用的keys。
persist-tun     #检测超时后，重新启动VPN，一直保持tun是linkup的。否则网络会先linkdown然后再linkup
duplicate-cn
```  

3.根据配置需要文件中定义，需要拷贝openvpnServer端用到的证书至/etc/openvpn目录中  
```
# cd /etc/openvpn/
# cp /opt/easy-rsa/pki/ca.crt ./
# cp /opt/easy-rsa/pki/issued/server.crt ./
# cp /opt/easy-rsa/pki/private/server.key ./
# cp /opt/easy-rsa/pki/dh.pem ./

# ls
ca.crt  client  dh.pem  server  server.conf  server.crt  server.key
```  

4.配置openvpn，首先需要开启内核转发功能  
```
# echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
# systemctl restart network
```

5.启动openvpn服务并加入开机自启  
```
# systemctl -f enable openvpn@server.service    #设置启动文件
# systemctl start openvpn@server.service        #启动openvpn服务
# systemctl status openvpn@server.service       #查看是否启动
# systemctl enabled openvpn@server.service      #设置开机启动
```  

6、检查服务
```
$ netstat -lntup|grep 1194
tcp        0      0 0.0.0.0:1194            0.0.0.0:*               LISTEN      48091/openvpn       
```


客户端连接  
===
Windows  
---
1.下载windows的openvpn软件  
https://www.techspot.com/downloads/5182-openvpn.html  
2.下载服务端生成的客户端密钥文件和ca文件至windows指定C:\Program Files\OpenVPN\config 目录中  
```
# cd /etc/openvpn/
# sz /opt/easy-rsa/pki/ca.crt
# sz /opt/easy-rsa/pki/issued/client.crt
# sz /opt/easy-rsa/pki/private/client.key
```  
3.在C:\Program Files\OpenVPN\config  创建一个客户端配置文件，名称叫client.ovpn  
内容如下  
```
client                  #指定当前VPN是客户端
dev tun                 #使用tun隧道传输协议
proto udp               #使用udp协议传输数据
remote 10.0.0.102 1194   #openvpn服务器IP地址端口号
resolv-retry infinite   #断线自动重新连接，在网络不稳定的情况下非常有用
nobind                  #不绑定本地特定的端口号
ca ca.crt               #指定CA证书的文件路径
cert client.crt         #指定当前客户端的证书文件路径
key client.key          #指定当前客户端的私钥文件路径
verb 3                  #指定日志文件的记录详细级别，可选0-9，等级越高日志内容越详细
persist-key     #通过keepalive检测超时后，重新启动VPN，不重新读取keys，保留第一次使用的keys
persist-tun     #检测超时后，重新启动VPN，一直保持tun是linkup的。否则网络会先linkdown然后再linkup
```  

4.最终windows的目录中配置文件如下  
![image](https://github.com/mykubernetes/linux-install/blob/master/image/openvpn.png)  
注意：文件后缀名  

5.双击运行openvpn，然后连接即可。  
查看windows下route  
```
route print -4
```  

Linux  
---
1.安装openvpn  
```
# yum install openvpn -y
```  

2.下载证书文件  
```
# cd /etc/openvpn/
# scp root@172.16.1.102:/opt/easy-rsa/pki/ca.crt ./
# scp root@172.16.1.102:/opt/easy-rsa/pki/issued/client.crt ./
# scp root@172.16.1.102:/opt/easy-rsa/pki/private/client.key ./
```  

3.配置客户端  
```
# cat client.ovpn
client                  #指定当前VPN是客户端
dev tun                 #使用tun隧道传输协议
proto udp               #使用udp协议传输数据
remote 10.0.0.102 1194   #openvpn服务器IP地址端口号
resolv-retry infinite   #断线自动重新连接，在网络不稳定的情况下非常有用
nobind                  #不绑定本地特定的端口号
ca ca.crt               #指定CA证书的文件路径
cert client.crt         #指定当前客户端的证书文件路径
key client.key          #指定当前客户端的私钥文件路径
verb 3                  #指定日志文件的记录详细级别，可选0-9，等级越高日志内容越详细
persist-key     #通过keepalive检测超时后，重新启动VPN，不重新读取keys，保留第一次使用的keys
persist-tun     #检测超时后，重新启动VPN，一直保持tun是linkup的。否则网络会先linkdown然后再linkup
```  

4.启动Linux客户端的openvpn  
```
# openvpn --daemon --cd /etc/openvpn --config client.ovpn --log-append /var/log/openvpn.log
```  
- --daemon：openvpn以daemon方式启动。  
- --cd dir：配置文件的目录，openvpn初始化前，先切换到此目录。  
- --config file：客户端配置文件的路径。  
- --log-append file：日志文件路径，如果文件不存在会自动创建。  


mac安装openvpn
----
https://www.jianshu.com/p/a5fd8dc95ad4  
https://www.cnblogs.com/airoot/p/7252987.html  



OpenVPN访问内网网段  
----
#解决方式一，添加路由规则
```
# route add  -net 10.8.0.0/24 gw 172.16.1.102
```
抓包发现数据包已经是一来一回  
```
17:51:36.053959 IP zabbix-agent-sh-103 > 10.8.0.10: ICMP echo reply, id 1, seq 420, length 40
17:51:37.057545 IP 10.8.0.10 > zabbix-agent-sh-103: ICMP echo request, id 1, seq 421, length 40
```  

#解决方式二，在vpn服务器上配置防火墙转发规则  
```
# systemctl start firewalld
# firewall-cmd --add-service=openvpn --permanent
# firewall-cmd --add-masquerade --permanent
# firewall-cmd --reload
```  

配置证书+密钥双重认证，之前已经配置证书认证  
------
1.修改Server端配置文件，添加以下三行代码
```
# vim /etc/openvpn/server.conf
script-security 3   #允许使用自定义脚本
auth-user-pass-verify /etc/openvpn/check.sh via-env
username-as-common-name #用户密码登陆方式验证
```  
#注：如果加上client-cert-not-required则代表只使用用户名密码方式验证登录，如果不加，则代表需要证书和用户名密码双重验证登录！
```
# cat /etc/openvpn/check.sh
#!/bin/sh
###########################################################
PASSFILE="/etc/openvpn/openvpnfile"
LOG_FILE="/var/log/openvpn-password.log"
TIME_STAMP=`date "+%Y-%m-%d %T"`

    if [ ! -r "${PASSFILE}" ]; then
      echo "${TIME_STAMP}: Could not open password file \"${PASSFILE}\" for reading." >> ${LOG_FILE}
      exit 1
    fi

    CORRECT_PASSWORD=`awk '!/^;/&&!/^#/&&$1=="'${username}'"{print $2;exit}' ${PASSFILE}`

    if [ "${CORRECT_PASSWORD}" = "" ]; then
      echo "${TIME_STAMP}: User does not exist: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
          exit 1
          fi
    if [ "${password}" = "${CORRECT_PASSWORD}" ]; then
      echo "${TIME_STAMP}: Successful authentication: username=\"${username}\"." >> ${LOG_FILE}
      exit 0
    fi
    echo "${TIME_STAMP}: Incorrect password: username=\"${username}\", password=\"${password}\"." >> ${LOG_FILE}
exit 1
```
#记得添加执行权限，否则会无法重启openvpn服务  
```
# chmod +x /etc/openvpn/check.sh
```  

准备用户名密码文件  
```
# cat /etc/openvpn/openvpnfile
huy 123456
```  

重载openvpn服务  
```
# systemctl restart openvpn@server
```  

查看日志  
```
# tail -f /var/log/openvpn-password.log 
2019-01-19 18:24:30: Successful authentication: username="huy".
2019-01-19 18:26:14: Successful authentication: username="jingjing".
2019-01-19 18:26:58: User does not exist: username="yy", password="123456".		#尝试使用不存在的用户的连接
```  


