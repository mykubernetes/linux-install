# 一、cosbench工具介绍

- cosbench是intel开源的针对对象存储开发的测试工具

# 二、cosbench安装

```
# 安装JDK
# yum install  java nmap-ncat

# 通过wget下载,或者直接通过浏览器输入下面的链接下载
# wget https://github.com/intel-cloud/cosbench/releases/download/v0.4.2.c4/0.4.2.c4.zip

# 解压
# unzip 0.4.2.c4.zip

# 解压后文件说明
# cd 0.4.2.c4

# ls -al *.sh
-rw-r--r-- 1 root root 2639 Jul  9  2014 cli.sh                                # munipulate workload through command line
-rw-r--r-- 1 root root 2944 Apr 27  2016 cosbench-start.sh                     # start internal scripts called by above scripts 
-rw-r--r-- 1 root root 1423 Dec 30  2014 cosbench-stop.sh                      # stop internal scripts called by above scripts 
-rw-r--r-- 1 root root  727 Apr 27  2016 start-all.sh                          # start both controller and driver on current node
-rw-r--r-- 1 root root 1062 Jul  9  2014 start-controller.sh                   # start controller only on current node 
-rw-r--r-- 1 root root 1910 Apr 27  2016 start-driver.sh                       # start driver only on current node 
-rw-r--r-- 1 root root  724 Apr 27  2016 stop-all.sh                           # stop both controller and driver on current node
-rw-r--r-- 1 root root  809 Jul  9  2014 stop-controller.sh                    # stop controller olny on current node 
-rw-r--r-- 1 root root 1490 Apr 27  2016 stop-driver.sh                        # stop diriver only on current node 
```

# 三、cosbench启动

1、运行cosbench之前先执行unset http_proxy
```
# 删除http_proxy环境变量
# unset http_proxy
```

2、启动cosbench
```
# sh start-all.sh 

Launching osgi framwork ... 
Successfully launched osgi framework!
Booting cosbench driver ... 
.
Starting    cosbench-log_0.4.2    [OK]
Starting    cosbench-tomcat_0.4.2    [OK]
Starting    cosbench-config_0.4.2    [OK]
Starting    cosbench-http_0.4.2    [OK]
Starting    cosbench-cdmi-util_0.4.2    [OK]
Starting    cosbench-core_0.4.2    [OK]
Starting    cosbench-core-web_0.4.2    [OK]
Starting    cosbench-api_0.4.2    [OK]
Starting    cosbench-mock_0.4.2    [OK]
Starting    cosbench-ampli_0.4.2    [OK]
Starting    cosbench-swift_0.4.2    [OK]
Starting    cosbench-keystone_0.4.2    [OK]
Starting    cosbench-httpauth_0.4.2    [OK]
Starting    cosbench-s3_0.4.2    [OK]
Starting    cosbench-librados_0.4.2    [OK]
Starting    cosbench-scality_0.4.2    [OK]
Starting    cosbench-cdmi-swift_0.4.2    [OK]
Starting    cosbench-cdmi-base_0.4.2    [OK]
Starting    cosbench-driver_0.4.2    [OK]
Starting    cosbench-driver-web_0.4.2    [OK]
Successfully started cosbench driver!
Listening on port 0.0.0.0/0.0.0.0:18089 ... 
Persistence bundle starting...
Persistence bundle started.
----------------------------------------------
!!! Service will listen on web port: 18088 !!!
----------------------------------------------

======================================================

Launching osgi framwork ... 
Successfully launched osgi framework!
Booting cosbench controller ... 
.
Starting    cosbench-log_0.4.2    [OK]
Starting    cosbench-tomcat_0.4.2    [OK]
Starting    cosbench-config_0.4.2    [OK]
Starting    cosbench-core_0.4.2    [OK]
Starting    cosbench-core-web_0.4.2    [OK]
Starting    cosbench-controller_0.4.2    [OK]
Starting    cosbench-controller-web_0.4.2    [OK]
Successfully started cosbench controller!
Listening on port 0.0.0.0/0.0.0.0:19089 ... 
Persistence bundle starting...
Persistence bundle started.
----------------------------------------------
!!! Service will listen on web port: 19088 !!!
----------------------------------------------
```

3、查看java进程
```
# ps -ef |grep java
root     2209528       1  1 11:13 pts/5    00:00:05 java -Dcosbench.tomcat.config=conf/driver-tomcat-server.xml -server -cp main/org.eclipse.equinox.launcher_1.2.0.v20110502.jar org.eclipse.equinox.launcher.Main -configuration conf/.driver -console 18089
root     2209784       1  1 11:13 pts/5    00:00:05 java -Dcosbench.tomcat.config=conf/controller-tomcat-server.xml -server -cp main/org.eclipse.equinox.launcher_1.2.0.v20110502.jar org.eclipse.equinox.launcher.Main -configuration conf/.controller -console 19089
root     2220882 2134956  0 11:21 pts/5    00:00:00 grep --color=auto java
```

4、浏览器访问

http://${IP}:19088/controller/


# 三、cosbench配置文件说明

## 参数说明

| 参数 | 描述 |
|------|-----|
| accesskey、secretkey | 密钥信息，分别替换为用户的 SecretId 和 SecretKey |
| cprefix | 存储桶名称前缀，例如 examplebucket |
| containers | 为存储桶名称数值区间，最后的存储桶名称由 cprefix 和 containers 组成，例如：examplebucket1，examplebucket2 |
| csuffix | 用户的 APPID，需注意 APPID 前面带上符号-，例如 -1250000000 |
| runtime | 压测运行时间 |
| ratio | 读和写的比例 |
| workers | 压测线程数 |


1、进入conf目录下，查看s3-config-sample.xml配置文件内容如下
```
# cat s3-config-sample.xml 

<?xml version="1.0" encoding="UTF-8" ?>
<workload name="s3-sample" description="sample benchmark for s3">

  <storage type="s3" config="accesskey=<accesskey>;secretkey=<scretkey>;proxyhost=<proxyhost>;proxyport=<proxyport>;endpoint=<endpoint>" />

  <workflow>

    <workstage name="init">
      <work type="init" workers="1" config="cprefix=s3testqwer;containers=r(1,2)" />
    </workstage>

    <workstage name="prepare">
      <work type="prepare" workers="1" config="cprefix=s3testqwer;containers=r(1,2);objects=r(1,10);sizes=c(64)KB" />
    </workstage>

    <workstage name="main">
      <work name="main" workers="8" runtime="30">
        <operation type="read" ratio="80" config="cprefix=s3testqwer;containers=u(1,2);objects=u(1,10)" />
        <operation type="write" ratio="20" config="cprefix=s3testqwer;containers=u(1,2);objects=u(11,20);sizes=c(64)KB" />
      </work>
    </workstage>

    <workstage name="cleanup">
      <work type="cleanup" workers="1" config="cprefix=s3testqwer;containers=r(1,2);objects=r(1,20)" />
    </workstage>

    <workstage name="dispose">
      <work type="dispose" workers="1" config="cprefix=s3testqwer;containers=r(1,2)" />
    </workstage>

  </workflow>

</workload>
```
- workload name : 测试时显示的任务名称，这里可以自行定义
- description : 描述信息，这里可以自己定义
- storage type: 存储类型，这里配置为s3即可
- config : 对该类型的配置，
- workstage name : cosbench是分阶段按顺序执行，此处为init初始化阶段，主要是进行bucket的创建，workers表示执行该阶段的时候开启多少个工作线程，创建bucket通过不会计算为性能，所以单线程也可以;config处配置的是存储桶bucket的名称前缀;containers表示轮询数，上例中将会创建以s3testqwer为前缀，后缀分别为1和2的bucket
- prepare阶段 : 配置为bucket写入的数据，workers和config以及containers与init阶段相同，除此之外还需要配置objects，表示一轮写入多少个对象，以及object的大小。
- main阶段 : 这里是进行测试的阶段，runtime表示运行的时间，时间默认为秒
- operation type : 操作类型，可以是read、write、delete等。ratio表示该操作所占有操作的比例，例如上面的例子中测试读写，read的比例为80%,write的比例为20%; config中配置bucket的前缀后缀信息。注意write的sizes可以根据实际测试进行修改
- cleanup阶段 : 这个阶段是进行环境的清理，主要是删除bucket中的数据，保证测试后的数据不会保留在集群中
- dispose阶段 : 这个阶段是删除bucket

2、手动修改配置后,启动测试。
```
# 配置文件示例如下
# cat s3-config-sample.xml 
<?xml version="1.0" encoding="UTF-8" ?>
<workload name="s3-sample" description="sample benchmark for s3">

  <storage type="s3" config="accesskey=UZJ537657WDBUXE2CY6G;secretkey=8nIQByhEIsSkIe70aCHoD5HD73lDNNaqXbCSb0Hj;endpoint=http://192.168.30.117:7480" />

  <workflow>

    <workstage name="init">
      <work type="init" workers="1" config="cprefix=cephcosbench;containers=r(1,2)" />
    </workstage>

    <workstage name="prepare">
      <work type="prepare" workers="1" config="cprefix=cephcosbench;containers=r(1,2);objects=r(1,10);sizes=c(64)KB" />
    </workstage>

    <workstage name="main">
      <work name="main" workers="10" runtime="60">
        <operation type="read" ratio="80" config="cprefix=cephcosbench;containers=u(1,2);objects=u(1,10)" />
        <operation type="write" ratio="20" config="cprefix=cephcosbench;containers=u(1,2);objects=u(11,20);sizes=c(64)KB" />
      </work>
    </workstage>

    <workstage name="cleanup">
      <work type="cleanup" workers="1" config="cprefix=cephcosbench;containers=r(1,2);objects=r(1,20)" />
    </workstage>

    <workstage name="dispose">
      <work type="dispose" workers="1" config="cprefix=cephcosbench;containers=r(1,2)" />
    </workstage>

  </workflow>

</workload>

# 执行启动
# sh cli.sh submit s3-config-sample.xml 
Accepted with ID: w1
```

任务配置主要包含如下五个阶段
- init 阶段：创建存储桶。
- prepare 阶段：worker 线程，PUT 上传指定大小的对象，用于 main 阶段读取。
- main 阶段：worker 线程混合读写对象，运行指定时长。
- cleanup 阶段，删除生成的对象。
- dispose 阶段：删除存储桶。


执行以下命令，停止测试服务
```
sh stop-all.sh
```
