```
# The number of milliseconds of each tick
# tickTime CS通信心跳数
tickTime=2000                                         # Zookeeper 服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个 tickTime 时间就会发送一个心跳。tickTime以毫秒为单位。
# The number of ticks that the initial 
# synchronization phase can take
# initLimit LF初始通信时限
initLimit=10                                          # 集群中的follower服务器(F)与leader服务器(L)之间初始连接时能容忍的最多心跳数（tickTime的数量）。
# The number of ticks that can pass between 
# sending a request and getting an acknowledgement
# syncLimit LF同步通信时限
syncLimit=5                                           # 集群中的follower服务器与leader服务器之间请求和应答之间能容忍的最多心跳数（tickTime的数量）。
# the directory where the snapshot is stored.
# do not use /tmp for storage, /tmp here is just 
# example sakes.
# dataDir：数据文件目录
dataDir=/data/zk/data                                 # Zookeeper保存数据的目录，默认情况下，Zookeeper将写数据的日志文件也保存在这个目录里。
# dataLogDir：日志文件目录，Zookeeper保存日志文件的目录。
dataLogDir=/data/zk/logs
# the port at which the clients will connect
clientPort=2181                                       # clientPort：客户端连接端口，通过这个端口可以连接zookeeper服务
# the maximum number of client connections.
# increase this if you need to handle more clients
#maxClientCnxns=60
#
# Be sure to read the maintenance section of the 
# administrator guide before turning on autopurge.
#
# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
#
# The number of snapshots to retain in dataDir
#autopurge.snapRetainCount=3
# Purge task interval in hours
# Set to "0" to disable auto purge feature
#autopurge.purgeInterval=1

## Metrics Providers
#
# https://prometheus.io Metrics Exporter
metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
metricsProvider.httpPort=7000
metricsProvider.exportJvmInfo=true
admin.enableServer=true
admin.serverPort=8000

server.1=hostname_02:2888:3888
server.2=hostname_03:2888:3888
server.3=hostname_05:2888:3888
```
