# Ceph动态调整参数有两种方式：

## 一、查看运行配置
```
命令格式：
# ceph daemon {daemon-type}.{id} config show 

命令举例：
# ceph daemon osd.0 config show 
```


## 二、daemon子命令：
- 使用`daemon`进行设置的方式就是一个个的去设置，这样可以比较好的反馈，此方法是需要在设置的角色所在的主机上进行设置。
```
ceph daemon {daemon-type}.{id} config set {name}={value}         # ceph daemon <mon/osd/mds>.<id> config set <参数名> <参数值>

比如，设置OSD 1的heartbeat超时时间：
ceph daemon osd.1 config set osd_heartbeat_grace 60
```

## 三、tell子命令格式：
- 使用 tell 的方式适合对整个集群进行设置，使用 * 号进行匹配，就可以对整个集群的角色进行设置。而出现节点异常无法设置时候，只会在命令行当中进行报错，不太便于查找。
```
ceph tell {daemon-type}.{daemon id or *} injectargs --{name}={value} [--{name}={value}]               # ceph tell <mon/osd/mds>.1 injectargs '--<参数名> <参数值> --<参数名> <参数值>'

设置OSD 1的heartbeat超时时间：
ceph tell osd.1 injectargs '--osd_heartbeat_grace 60'
```
- daemon-type：为要操作的对象类型如osd、mon、mds等。
- daemon id：该对象的名称，osd通常为0、1等，mon为ceph -s显示的名称，这里可以输入*表示全部。
- injectargs：表示参数注入，后面必须跟一个参数，也可以跟多个

#### tell子命令还有两个比较好用的地方：

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
