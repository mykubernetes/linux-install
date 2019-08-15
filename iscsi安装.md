服务器端配置
---
1、安装  
```
# yum install -y scsi-target-utils
```  

2、配置  
```
# vim /etc/tgt/targets.conf# This is a sample config file for tgt-admin.
#
# The "#" symbol disables the processing of a line.

# Set the driver. If not specified, defaults to "iscsi".
default-driver iscsi

# Set iSNS parameters, if needed
#iSNSServerIP 192.168.111.222
#iSNSServerPort 3205
#iSNSAccessControl On
#iSNS On

# Continue if tgtadm exits with non-zero code (equivalent of
# --ignore-errors command line option)
#ignore-errors yes

<target iqn.2019-08.cn.node03.www:target_san1>
         backing-store  /dev/sdb
         initiator-address 192.168.101.67
         vendor_id  huawei
         product_id   target1
</target>
```  
- default-driver iscsi #此配置文件默认全部注释，使用iscsi驱动  
<tarrget iqn.2018-1.cn.xuegod.www:target_san1>  # iscsi正规名字格式：iqn.年－月.主机名倒着写: target端名字
- backing-store /dev/hda4 #可以是具体的分区，也可以是DD出来的文件。不能小于5G。         
- initiator-address 192.168.1.67 #指定允许访问的此存储主机
- vendor_id "huawei" #vendor是供应厂商编号标识这个设备
- product_id "TARGET1" # 产品编号  
</target>  

3、启动  
```
# systemctl start tgtd
# netstat  -antup | grep 3260
tcp        0      0 0.0.0.0:3260            0.0.0.0:*               LISTEN      7267/tgtd           
tcp6       0      0 :::3260                 :::*                    LISTEN      7267/tgtd  

# tgt-admin -show
Target 1: iqn.2019-08.cn.node03.www:target_san1
    System information:
        Driver: iscsi
        State: ready
    I_T nexus information:
    LUN information:
        LUN: 0
            Type: controller
            SCSI ID: IET     00010000
            SCSI SN: beaf10
            Size: 0 MB, Block size: 1
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: null
            Backing store path: None
            Backing store flags: 
        LUN: 1
            Type: disk
            SCSI ID: IET     00010001
            SCSI SN: beaf11
            Size: 5369 MB, Block size: 512
            Online: Yes
            Removable media: No
            Prevent removal: No
            Readonly: No
            SWP: No
            Thin-provisioning: No
            Backing store type: rdwr
            Backing store path: /dev/sdb
            Backing store flags: 
    Account information:
    ACL information:
        192.168.101.67
```  

配置客户端
---

1、安装  
```
# yum install -y iscsi-initiator-utils
```  

2、启动服务  
```
# systemctl start iscsid
```  

3、发现共享存储  
```
# iscsiadm -m discovery -t sendtargets -p 192.168.101.68:3260
192.168.101.68:3260,1 iqn.2019-08.cn.node03.www:target_san1
```  

4查看发现的共享存储
```
# tree /var/lib/iscsi/
/var/lib/iscsi/
├── ifaces
├── isns
├── nodes
│   └── iqn.2019-08.cn.node03.www:target_san1
│       └── 192.168.101.68,3260,1
│           └── default
├── send_targets
│   ├── 192.168.101.68,3260
│   │   ├── iqn.2019-08.cn.node03.www:target_san1,192.168.101.68,3260,1,default -> /var/lib/iscsi/nodes/iqn.2019-08.cn.node03.www:target_san1/192.168.101.68,3260,1
│   │   └── st_config
│   └── 192.168.1.68,3260
│       └── st_config
├── slp
└── static

11 directories, 3 files
```  

5、先启动iscsid，再启动iscsi，iscsi是根据/var/lib/iscsi/中发现的信息，识别设备
```
# systemctl start iscsid  #先启动iscsid
# systemctl start iscsi   #根据/var/lib/iscsi/  中发现的信息，识别设备
```  

6、设置开启启动  
```
开机自动启动：
# systemctl enable iscsi
# systemctl enable iscsid
```  

7、查看发现的硬盘  
```
# ll /dev/sdb
brw-rw----. 1 root disk 8, 16 Mar 22 05:47 /dev/sdb
```  

8、关闭过程  
```
# systemctl stop iscsi 
# systemctl stop iscsid 
```  

9、卸载硬盘  
```
# iscsiadm -m node -T iqn.2019-08.cn.node03.www:target_san1 -u
Logging out of session [sid: 1, target: iqn.2019-08.cn.node03.www:target_san1, portal: 192.168.101.68,3260]
Logout of [sid: 1, target: iqn.2019-08.cn.node03.www:target_san1, portal: 192.168.101.68,3260] successful.

#查看是否卸载
# ls /dev/sdb
ls: cannot access /dev/sdb: No such file or directory
```  

