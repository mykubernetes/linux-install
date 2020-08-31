1、安装 dnsmasq
```
# rhel
yum install dnsmasq
# archlinux
pacman -S dnsmasq
```

2、修改配置
```
# vim /etc/dnsmasq.conf
port=0 # 用不着 dns 功能，可以关闭
#interface=ens8u2u4u1 # 指定网卡
dhcp-range=10.0.86.1,10.0.86.9,255.255.255.0,1h
#dhcp-boot=pxelinux.0 # bios 引导
dhcp-boot=grubx64.efi # efi 引导
enable-tftp
tftp-root=/var/ftpd
```

3、启动 dnsmasq
```
systemctl start dnsmasq
```
