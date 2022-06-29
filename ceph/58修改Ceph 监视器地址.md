您是否有过因为大意将Ceph Monitor地址配置错的经历？ 我曾经就因为马大哈，将Ceph Monitor的地址配置成了管理网络地址，而且是在使用了2天后才发现。(⊙﹏⊙)b

您是否有过由于公司网络重新规划需要修改Ceph Monitor地址的需求？ 我在QQ群中就有遇到网友咨询相关处理办法。

直接修改ceph.conf配置不就行了么？真有这么简单！要知道Ceph是将Monitor配置信息存储在monmap中的，修改ceph.conf中的配置后，重新启动Monitor，读取monmap时必然会出现信息不匹配，该Monitor就无法加入仲裁，也就没法与其他的Monitor通信，整个操作就是失败的！

既然直接修改ceph.conf配置不行，那遇到这种情况，该怎么处理呢？ 请看下文：:)

在不破坏原有集群的情况下，需要按如下方式动态修改Monitor的地址配置：

下文的操作方法在CentOS7.1 上安装的Hammer 0.94.1上验证有效；配置信息来自真实的环境，为保证安全，抹去了具体地址信息

# 获取monmap

转储当前Ceph集群的monmap到/tmp/monmap文件
```
[root@ceph-xxx-xxx ~]# ceph mon getmap -o /tmp/monmap
got monmap epoch 4
```

# 查看monmap内容

我的示例Ceph集群中包含三个Monitor节点
```
root@ceph-xxx-xxx ~]# monmaptool --print /tmp/monmap
monmaptool: monmap file /tmp/monmap
epoch 4
fsid 1ee20ded-caae-419d-9fe3-5919f129cf55
last_changed 2016-02-26 17:10:47.603764
created 0.000000
0: 192.168.xxx.xxx:6789/0 mon.ceph-xxx-xxx
1: 192.168.xxx.xxy:6789/0 mon.ceph-xxx-xxy
2: 192.168.xxx.xxz:6789/0 mon.ceph-xxx-xxz
```

# 删除monitor节点信息

逐一删除monmap中的节点信息：
```
[root@ceph-xxx-xxx ~]# monmaptool --rm ceph-xxx-xxx /tmp/monmap 
monmaptool: monmap file /tmp/monmap
monmaptool: removing ceph-xxx-xxx
monmaptool: writing epoch 4 to /tmp/monmap (2 monitors)

//按照上述方法删除三个节点后，/tmp/monmap的内容如下：
[root@ceph-xxx-xxx ~]# monmaptool --print /tmp/monmap
monmaptool: monmap file /tmp/monmap
epoch 4
fsid 1ee20ded-caae-419d-9fe3-5919f129cf55
last_changed 2016-02-26 17:10:47.603764
created 0.000000
```

# 添加monitor节点

原有的monitor信息删除后，添加三个新的monitor节点，如下：
```
[root@ceph-xxx-xxx ~]# monmaptool --add ceph-xxx-xxm 192.168.xxx.xxm:6789 /tmp/monmap 
monmaptool: monmap file /tmp/monmap
monmaptool: writing epoch 4 to /tmp/monmap (1 monitors)

//添加完成三个新的monitor节点后，/tmp/monmap内容如下
[root@ceph-xxx-xxx ~]# monmaptool --print /tmp/monmap
monmaptool: monmap file /tmp/monmap
epoch 4
fsid 1ee20ded-caae-419d-9fe3-5919f129cf55
last_changed 2016-02-26 17:10:47.603764
created 0.000000
0: 192.168.xxx.xxm:6789/0 mon.ceph-xxx-xxm
1: 192.168.xxx.xxn:6789/0 mon.ceph-xxx-xxn
2: 192.168.xxx.xxl:6789/0 mon.ceph-xxx-xxl
```

# 修改节点ip地址

通过修改/etc/sysconfig/network-scripts/ifcfg-eth*文件，修改各节点ip地址，然后重启网络服务完成ip的修改，命令如下：
```
[root@ceph-xxx-xxx ~]#ifdown eth* && ifup eth*
[root@ceph-xxx-xxy ~]#ifdown eth* && ifup eth*
[root@ceph-xxx-xxz ~]#ifdown eth* && ifup eth*
```

# 修改ceph.conf

在admin节点上修改ceph.conf中的mon_host 配置,然后通过ceph-deploy推送到所有monitor节点:
```
[root@ceph-xxx-xxm ~]#cat ceph.conf
[global]
......

mon_host = 192.168.xxx.xxm,192.168.xxx.xxn,192.168.xxx.xxl

......

[root@ceph-xxx-xxm ~]#ceph-deploy admin overwrite-conf ceph-xxx-xxm ceph-xxx-xxn ceph-xxx-xxl
```

# 停止monitor并注入新的monmap

停止各节点上的monitor服务，将/tmp/monmap文件文件拷贝到其他节点，并注入新的monmap记录：
```
[root@ceph-xxx-xxm ~]#/etc/init.d/ceph stop mon
[root@ceph-xxx-xxm ~]#ceph-mon -i ceph-xxx-xxm --inject-monmap /tmp/monmap

[root@ceph-xxx-xxn ~]#/etc/init.d/ceph stop mon
[root@ceph-xxx-xxn ~]#ceph-mon -i ceph-xxx-xxn --inject-monmap /tmp/monmap

[root@ceph-xxx-xxl ~]#/etc/init.d/ceph stop mon
[root@ceph-xxx-xxl ~]#ceph-mon -i ceph-xxx-xxl --inject-monmap /tmp/monmap
```

# 启动monitor

启动各节点上的monitor服务：
```
[root@ceph-xxx-xxm ~]# /etc/init.d/ceph start mon
[root@ceph-xxx-xxn ~]# /etc/init.d/ceph start mon

[root@ceph-xxx-xxl ~]# /etc/init.d/ceph start mon
```

# 重启OSD

最后重启所有的OSD服务：
```
[root@ceph-xxx-xxm ~]# /etc/init.d/ceph restart osd
[root@ceph-xxx-xxn ~]# /etc/init.d/ceph restart osd
[root@ceph-xxx-xxn ~]# /etc/init.d/ceph restart osd
```

参考：
- https://blog.csdn.net/lzw06061139/category_6187085.html?spm=1001.2014.3001.5482
