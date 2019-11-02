1、查看内核是否支持lvs模块  
```
查看内核版本
# uname -r
3.10.0-693.el7.x86_64


# grep -i IPVS /boot/config-3.10.0-693.el7.x86_64 
CONFIG_NETFILTER_XT_MATCH_IPVS=m
# IPVS transport protocol load balancing support
# IPVS scheduler
# IPVS SH scheduler
# IPVS application helper
```  

2、查看lvs支持的类型及调度
```
# grep -A 11 -i IPVS /boot/config-3.10.0-693.el7.x86_64 
CONFIG_NETFILTER_XT_MATCH_IPVS=m
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
CONFIG_NETFILTER_XT_MATCH_NFACCT=m
CONFIG_NETFILTER_XT_MATCH_OSF=m
CONFIG_NETFILTER_XT_MATCH_OWNER=m
CONFIG_NETFILTER_XT_MATCH_POLICY=m
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
--
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m
--
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=m
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=m

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=m
CONFIG_NF_CONNTRACK_IPV4=m
# CONFIG_NF_CONNTRACK_PROC_COMPAT is not set
```  

3、安装ipvsadm命令工具  
```
# yum install -y ipvsadm

# rpm -ql ipvsadm
/etc/sysconfig/ipvsadm-config
/usr/lib/systemd/system/ipvsadm.service    #加载规则服务
/usr/sbin/ipvsadm                          #客户端工具
/usr/sbin/ipvsadm-restore                  #重载配置到内核中
/usr/sbin/ipvsadm-save                     #保存规则
/usr/share/doc/ipvsadm-1.27
/usr/share/doc/ipvsadm-1.27/README
/usr/share/man/man8/ipvsadm-restore.8.gz
/usr/share/man/man8/ipvsadm-save.8.gz
/usr/share/man/man8/ipvsadm.8.gz
```  

4、ipvs规则的保存和重载  
```
保存
ipvsadm -S > /etc/sysconfig/ipvsadm
ipvsadm-save > /etc/sysconfig/ipvsadm

重载
ipvsadm -R < /etc/sysconfig/ipvsadm
ipvsadm-restore > /etc/sysconfig/ipvsadm
```  

5、查看
```
ipvsadm -L
  -n #显示数值
  --exact #精确值
  -c #显示IPVS连接
  --stats #统计数据
  --reate #速率

清空规则
ipvsadm -C      #clear意思

清空计数器
ipvsadm -Z
```  

6、使用方法
```
# ipvsadm -A -t 192.168.101.70:80 -s rr
# ipvsadm -a -t 192.168.101.70:80 -r 192.168.101.69 -m -w 1
# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.101.70:80 rr
  -> 192.168.101.69:80            Masq    1      0          0
```  
- -A 添加规则 -t tcp -u udp -f 防火墙规则 -s 调度方法
- -a 添加后端服务器 -r 真实服务器地址 -g dr模型  -l tun模型 -m nat模型 -w 权重

7、修改  
```
# ipvsadm -E -t 192.168.101.70:80 -s wrr
# ipvsadm -e -t 192.168.101.70:80 -r 192.168.101.69 -m -w 3
# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.101.70:80 wrr
  -> 192.168.101.69:80            Masq    3      0          0    
```  
- -E 修改规则
- -e 修改后端服务器
