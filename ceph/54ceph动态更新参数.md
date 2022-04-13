# Ceph动态调整参数有两种方式：

## 第一种：
```
ceph daemon <mon/osd/mds>.<id> config set <参数名> <参数值>
 
比如，设置OSD 1的heartbeat超时时间：
ceph daemon osd.1 config set osd_heartbeat_grace 60
```

## 第二种：
```
ceph tell <mon/osd/mds>.<id> injectargs '--<参数名> <参数值>' 

设置OSD 1的heartbeat超时时间：
ceph tell osd.1 injectargs '--osd_heartbeat_grace 60'
```

### 第二种还有两个比较好用的地方：

1、单条命令可以改变所有的实例的某个参数值：
```
ceph tell <mon/osd/mds>.* injectargs '--<参数名> <参数值>'

设置所有OSD的heartbeat超时时间：
ceph tell osd.* injectargs '--osd_heartbeat_grace 60'
```

2、单条命令可以改变多个参数：
```
ceph tell <mon/osd/mds>.1 injectargs '--<参数名> <参数值> --<参数名> <参数值>'

设置OSD 1的heartbeat超时时间，及发起heartbeat的时间间隔
ceph tell osd.1 injectargs '--osd_heartbeat_grace 60 --osd_heartbeat_interval 10'
```

3、当然，上面两个可以结合使用：
```
ceph tell <mon/osd/mds>.* injectargs '--<参数名> <参数值> --<参数名> <参数值>'  

设置所有OSD的heartbeat超时时间，及发起heartbeat的时间间隔
ceph tell osd.* injectargs '--osd_heartbeat_grace 60 --osd_heartbeat_interval 10'
```
