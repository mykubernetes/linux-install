1、Mongostat 实用程序可以快速概览当前正在运行的 mongod 或 mongos 实例的状态，mongostat 在功能上类似于 UNIX / Linux 文件系统实用程序 vmstat，但提供有关的数据 mongod 和 mongos 实例  

| 参数 | 参数说明 |
|------|----------|
| insert | 每秒插入量 |
| query | 每秒查询量 |
| update | 每秒更新量 |
| delete | 每秒删除量 |
| conn | 当前连接数 |
| qr|qw | 客户端查询排队长度（读|写）最好为0，如果有堆积，数据库处理慢。 |
| ar|aw | 活跃客户端数量（读|写） |
| time | 当前时间 |

```
$ mongostat 
insert query update delete getmore command dirty used flushes vsize   res qrw arw net_in net_out conn                time
    *0    *0     *0     *0       0     1|0  0.0% 0.0%       0  950M 35.0M 0|0 0|0   155b   44.6k    1 Aug  3 03:42:47.505
    *0    *0     *0     *0       0     2|0  0.0% 0.0%       0  950M 35.0M 0|0 0|0   159b   45.9k    1 Aug  3 03:42:48.494
    *0    *0     *0     *0       0     1|0  0.0% 0.0%       0  950M 35.0M 0|0 0|0   156b   44.9k    1 Aug  3 03:42:49.505
    *0    *0     *0     *0       0     1|0  0.0% 0.0%       0  950M 35.0M 0|0 0|0   157b   45.2k    1 Aug  3 03:42:50.510
    *0    *0     *0     *0       0     2|0  0.0% 0.0%       0  950M 35.0M 0|0 0|0   159b   46.0k    1 Aug  3 03:42:51.498
    *0    *0     *0     *0       0     1|0  0.0% 0.0%       0  950M 35.0M 0|0 0|0   157b   45.3k    1 Aug  3 03:42:52.500
    *0    *0     *0     *0       0     2|0  0.0% 0.0%       0  950M 35.0M 0|0 0|0   159b   45.9k    1 Aug  3 03:42:53.490
    *0    *0     *0     *0       0     1|0  0.0% 0.0%       0  950M 35.0M 0|0 0|0   157b   45.3k    1 Aug  3 03:42:54.493
    *0    *0     *0     *0       0     2|0  0.0% 0.0%       0  950M 35.0M 0|0 0|0   158b   45.5k    1 Aug  3 03:42:55.492
    *0    *0     *0     *0       0     2|0  0.0% 0.0%       0  950M 35.0M 0|0 0|0   158b   45.6k    1 Aug  3 03:42:56.489
```  

2、Mongotop 提供了一种跟踪 MongoDB 实例读取和写入数据的时间量的方法，mongotop 提供每个收集级别的统计信息。默认情况下，mongotop 每秒返回一次值  
```
$ mongotop 
2019-08-03T03:43:58.741-0400	connected to: 127.0.0.1

                  ns    total    read    write    2019-08-03T03:43:59-04:00
  admin.system.roles      0ms     0ms      0ms                             
  admin.system.users      0ms     0ms      0ms                             
admin.system.version      0ms     0ms      0ms                             
   local.startup_log      0ms     0ms      0ms                             
local.system.replset      0ms     0ms      0ms           
```  

3、Mongoperf 是一种独立于 MongoDB 检查磁盘 I / O 性能的实用程序。它是随机磁盘 I / O 的测试并呈现结果。  
```
$ echo "{nThreads:16, fileSizeMB:1000, r:true, w:true}" | mongoperf 
mongoperf
use -h for help
parsed options:
{ nThreads: 16, fileSizeMB: 1000, r: true, w: true }
creating test file size:1000MB ...
testing...
options:{ nThreads: 16, fileSizeMB: 1000, r: true, w: true }
wthr 16
new thread, total running : 1
read:1 write:1
9981 ops/sec 38 MB/sec
14228 ops/sec 55 MB/sec
14162 ops/sec 55 MB/sec
14282 ops/sec 55 MB/sec
14158 ops/sec 55 MB/sec
14351 ops/sec 56 MB/sec
13509 ops/sec 52 MB/sec
7854 ops/sec 30 MB/sec
```  

4、mongodb监控之serverStatus
- serverStatus可用来获取mongodb的状态信息
- db.serverStatus()   #查看所有的监控信息
- db.serverStatus().network #单独查看网络流量信息
- db.serverStatus().opcounters #统计增、删、改、查的次数
- db.serverStatus().connections#连接
