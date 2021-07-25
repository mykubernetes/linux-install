Ceph 服务的管理
===

常见命令
---
| 命令 | 含义 |
|-----|------|
| systemctl stop ceph-$type@$id | 停止特定守护进程。 |
| systemctl stop ceph-osd.target | 停止所有OSD守护进程。 |
| systemctl stop ceph.target | 停止所有ceph守护进程。 |
| systemctl start ceph-$type@$id | 启动特定守护进程。 |
| systemctl start ceph-osd.target | 启动所有OSD守护进程。 |
| systemctl start ceph.target | 启动所有ceph守护进程。 |
| systemctl restart ceph-$type@$id | 重启特定守护进程。 |
| systemctl restart ceph-osd.target | 重启所有OSD守护进程。 |
| systemctl restart ceph.target | 重启所有ceph守护进程。 |

查看配置
---
```
#查看所有参数和值  命令：ceph daemon type.id config show		
示例：ceph daemon osd.0 config show

#查看指定参数 命令：ceph daemon type.id config get parameter	
示例：ceph daemon type.id config get mds_data
```

1、启动和停止所有守护进程
---

> 启动当前节点的所有Ceph服务
```
systemctl start ceph.target
```

> 停止当前节点上的所有ceph服务
```
systemctl stop ceph\*.service ceph\*.target
```

> 启动远端节点的所有ceph服务
```
sudo systemctl -H node02 start ceph.target
```

> 停止远端节点的所有ceph服务
```
sudo systemctl -H node02 stop ceph\*.service ceph\*.target
```
注意：要执行远端服务，必须ceph.conf一致，并且能够ssh到所有节点


2、查询Ceph服务
---
> 查看当前节点上运行的所有Ceph服务
```
systemctl status ceph\*.service ceph\*.target
```

> 查看当前节点上特定服务的状态
```
systemctl status ceph-mon@node01    #主机名
systemctl status ceph-osd@1         #osd 1号磁盘
```  

> 查看远端节点上所有服务
```
sudo systemctl -H node02 status ceph\*.service ceph\*.target
```

> 查看远端节点上特定服务
```
systemctl -H node02 status ceph-mon@node02
```

3、按类型启动和停止所有守护程序
---
按类型启动所有守护程序
> 启动当前节点 Ceph mon 守护程序
```
systemctl start ceph-mon.target
```

> 启动远端节点 Ceph mon 守护程序
```
systemctl -H node02 start ceph-mon.target
```

> 其它类型
```
systemctl start ceph-osd.target
systemctl start ceph-mds.target
systemctl start ceph-radosgw.target
```

按类型停止所有守护程序
> 停止当前节点 Ceph mon 守护程序
```
systemctl stop ceph-mon.target
```

> 停止远端节点 Ceph mon 守护程序
```
sudo systemctl -H node02 stop ceph.mon.target
```

> 其它类型
```
systemctl stop ceph-osd.target
systemctl stop ceph-mon.target
systemctl stop ceph-radosgw.target
```

4、启动和停止特定守护程序
---
按实例启动特定守护程序
启动当前节点的 ceph mon 守护进程
```
systemctl start ceph-mon@node01
```

其它类型
```
systemctl start ceph-osd@1
sudo systemctl -H node01 start ceph-mon@node01
systemctl stop ceph-radosgw@rgw-node01
```

按实例停止特定守护程序
停止当前节点的 ceph mon 守护程序
```
systemctl stop ceph-mon@node02
```

其它类型  
```
$ systemctl stop ceph-osd@1
$ sudo systemctl -H node01 stop ceph-mon@node01</kbd>
$ systemctl start ceph-radosgw@rgw-node01
```  
