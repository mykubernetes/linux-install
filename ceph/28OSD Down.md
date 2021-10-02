# 事情起因

报警 OSD Down 与 OSD nearfull 警告，于是上 CEPH 服务器查看发现其中 osd.7 报警满，osd.19 不在 ceph 中。从目前的情况来看，应该是 osd.19 磁盘挂了，数据迁移至其它 OSD，造成 OSD.7 满的报警。于是尝试ceph osd in osd.19并启用ceph osd up osd.19发现不生效。

```
#查看CEPH状态
# ceph status
  cluster:
    id:     b1cf0cd3-28f9-4fc4-a495-d5bafb3195ec
    health: HEALTH_WARN
            1 nearfull osd(s)
            1 pool(s) nearfull
  services:
    mon: 3 daemons, quorum OB001,OB002,OB003
    mgr: OB002(active), standbys: OB001, OB003
    osd: 20 osds: 19 up, 19 in                                  #从这里可以看到有一个osd已经down了
  data:
    pools:   1 pools, 1024 pgs
    objects: 830.61k objects, 3.09TiB
    usage:   6.17TiB used, 2.13TiB / 8.29TiB avail
    pgs:     1024 active+clean
  io:
    client:   12.5KiB/s rd, 6.43MiB/s wr, 11op/s rd, 247op/s wr

#查看OSD状态
# ceph osd status
+----+-------+-------+-------+--------+---------+--------+---------+--------------------+
| id |  host |  used | avail | wr ops | wr data | rd ops | rd data |       state        |
+----+-------+-------+-------+--------+---------+--------+---------+--------------------+
| 0  | OB001 |  356G | 90.1G |   30   |  79.2k  |    0   |     0   |     exists,up      |
| 1  | OB001 |  342G |  104G |   17   |  86.8k  |    1   |     0   |     exists,up      |
| 2  | OB001 |  295G |  151G |    4   |  85.6k  |    0   |     0   |     exists,up      |
| 3  | OB001 |  321G |  125G |    2   |  8396   |    0   |     0   |     exists,up      |
| 4  | OB001 |  334G |  112G |    7   |  50.4k  |    0   |     0   |     exists,up      |
| 5  | OB002 |  238G |  208G |    4   |  27.3k  |    0   |     0   |     exists,up      |
| 6  | OB002 |  320G |  126G |    8   |   260k  |    0   |     0   |     exists,up      |
| 7  | OB002 |  383G | 63.4G |    2   |  11.8k  |    0   |     0   | exists,nearfull,up |     #报警OSD
| 8  | OB002 |  361G | 85.1G |   15   |   678k  |    0   |     0   |     exists,up      |
| 9  | OB002 |  291G |  155G |    7   |  28.0k  |    0   |     0   |     exists,up      |
| 10 | OB003 |  368G | 78.2G |   22   |   127k  |    0   |     0   |     exists,up      |
| 11 | OB003 |  323G |  123G |    3   |  52.9k  |    0   |     0   |     exists,up      |
| 12 | OB003 |  319G |  127G |    2   |  93.0k  |    1   |     0   |     exists,up      |
| 13 | OB003 |  374G | 72.9G |    2   |  18.1k  |    1   |     0   |     exists,up      |
| 14 | OB003 |  345G |  101G |   23   |   169k  |    1   |     0   |     exists,up      |
| 15 | OB004 |  305G |  141G |    4   |  47.2k  |    0   |     0   |     exists,up      |
| 16 | OB004 |  360G | 86.5G |    7   |  39.2k  |    1   |     0   |     exists,up      |
| 17 | OB004 |  358G | 88.7G |    4   |  48.8k  |    0   |     0   |     exists,up      |
| 18 | OB004 |  313G |  133G |   13   |   196k  |    0   |     0   |     exists,up      |
| 19 | OB004 |    0  |    0  |    0   |     0   |    0   |     0   |       exists       |     #Down的OSD
+----+-------+-------+-------+--------+---------+--------+---------+--------------------+
```

# 定位问题

```
#定位OSD所有物理节点
root@OB001:~# ceph osd find 19
{
    "osd": 19,
    "ip": "172.16.0.208:6816/3245",
    "osd_fsid": "75c6907d-942a-43b4-ba2a-ed8d90a416e2",
    "crush_location": {
        "host": "OB004", #OSD所在节点
        "root": "default"
    }
}

#连接至对应服务器OB004节点，通过dmesg命令，查看硬件检测或者断开连接的信息，可以看到sdf出现了I/O error。
root@OB004:~# dmesg -T
[Sat Apr 11 09:06:51 2020] sd 5:0:0:0: [sdf] tag#16 CDB: Read(10) 28 00 37 e4 36 00 00 00 08 00
[Sat Apr 11 09:06:51 2020] print_req_error: I/O error, dev sdf, sector 937702912
[Sat Apr 11 09:06:51 2020] sd 5:0:0:0: [sdf] tag#17 FAILED Result: hostbyte=DID_BAD_TARGET driverbyte=DRIVER_OK
[Sat Apr 11 09:06:51 2020] sd 5:0:0:0: [sdf] tag#17 CDB: Read(10) 28 00 37 e4 36 a0 00 00 08 00
[Sat Apr 11 09:06:51 2020] print_req_error: I/O error, dev sdf, sector 937703072
[Sat Apr 11 09:06:51 2020] sd 5:0:0:0: [sdf] tag#18 FAILED Result: hostbyte=DID_BAD_TARGET driverbyte=DRIVER_OK
[Sat Apr 11 09:06:51 2020] sd 5:0:0:0: [sdf] tag#18 CDB: Read(10) 28 00 00 00 00 00 00 00 08 00
[Sat Apr 11 09:06:51 2020] print_req_error: I/O error, dev sdf, sector 0
[Sat Apr 11 09:29:50 2020] XFS (sdf1): metadata I/O error: block 0x80 ("xfs_trans_read_buf_map") error 5 numblks 128
[Sat Apr 11 09:29:50 2020] XFS (sdf1): xfs_imap_to_bp: xfs_trans_read_buf() returned error -5.

#于是查看对应OSD日志，发现也是Input/output error。
root@OB004:~# tail -n 10 /var/log/ceph/ceph-osd.19.log
2020-04-11 09:30:48.726470 7f8e96983e00 -1  ** ERROR: unable to open OSD superblock on /var/lib/ceph/osd/ceph-19: (5) Input/output error
2020-04-11 09:31:08.962079 7ff8f2065e00  0 set uid:gid to 64045:64045 (ceph:ceph)
2020-04-11 09:31:08.962096 7ff8f2065e00  0 ceph version 12.2.11 (c96e82ac735a75ae99d4847983711e1f2dbf12e5) luminous (stable), process ceph-osd, pid 3613380
2020-04-11 09:31:08.963319 7ff8f2065e00 -1  ** ERROR: unable to open OSD superblock on /var/lib/ceph/osd/ceph-19: (5) Input/output error
2020-04-11 09:31:29.218118 7f480fc15e00  0 set uid:gid to 64045:64045 (ceph:ceph)
2020-04-11 09:31:29.218142 7f480fc15e00  0 ceph version 12.2.11 (c96e82ac735a75ae99d4847983711e1f2dbf12e5) luminous (stable), process ceph-osd, pid 3613437
2020-04-11 09:31:29.219493 7f480fc15e00 -1  ** ERROR: unable to open OSD superblock on /var/lib/ceph/osd/ceph-19: (5) Input/output error
2020-04-11 09:31:49.458303 7f863b073e00  0 set uid:gid to 64045:64045 (ceph:ceph)
2020-04-11 09:31:49.458321 7f863b073e00  0 ceph version 12.2.11 (c96e82ac735a75ae99d4847983711e1f2dbf12e5) luminous (stable), process ceph-osd, pid 3613502
2020-04-11 09:31:49.459655 7f863b073e00 -1  ** ERROR: unable to open OSD superblock on /var/lib/ceph/osd/ceph-19: (5) Input/output error

#vgs和lvs出现的都是IO error
root@OB004:~# vgs
  /dev/sdf: read failed after 0 of 4096 at 0: Input/output error
  /dev/sdf: read failed after 0 of 4096 at 480103890944: Input/output error
  /dev/sdf: read failed after 0 of 4096 at 480103972864: Input/output error
  /dev/sdf: read failed after 0 of 4096 at 4096: Input/output error
  /dev/sdf1: read failed after 0 of 512 at 104792064: Input/output error
  /dev/sdf1: read failed after 0 of 512 at 104849408: Input/output error
  /dev/sdf1: read failed after 0 of 512 at 0: Input/output error
  /dev/sdf1: read failed after 0 of 512 at 4096: Input/output error
  /dev/sdf1: read failed after 0 of 2048 at 0: Input/output error
  /dev/sdf2: read failed after 0 of 512 at 479997984768: Input/output error
  /dev/sdf2: read failed after 0 of 512 at 479998046208: Input/output error
  /dev/sdf2: read failed after 0 of 512 at 0: Input/output error
  /dev/sdf2: read failed after 0 of 512 at 4096: Input/output error
  /dev/sdf2: read failed after 0 of 2048 at 0: Input/output error
root@OB004:~# lvs
  /dev/sdf: read failed after 0 of 4096 at 0: Input/output error
  /dev/sdf: read failed after 0 of 4096 at 480103890944: Input/output error
  /dev/sdf: read failed after 0 of 4096 at 480103972864: Input/output error
  /dev/sdf: read failed after 0 of 4096 at 4096: Input/output error
  /dev/sdf1: read failed after 0 of 512 at 104792064: Input/output error
  /dev/sdf1: read failed after 0 of 512 at 104849408: Input/output error
  /dev/sdf1: read failed after 0 of 512 at 0: Input/output error
  /dev/sdf1: read failed after 0 of 512 at 4096: Input/output error
  /dev/sdf1: read failed after 0 of 2048 at 0: Input/output error
  /dev/sdf2: read failed after 0 of 512 at 479997984768: Input/output error
  /dev/sdf2: read failed after 0 of 512 at 479998046208: Input/output error
  /dev/sdf2: read failed after 0 of 512 at 0: Input/output error
  /dev/sdf2: read failed after 0 of 512 at 4096: Input/output error
  /dev/sdf2: read failed after 0 of 2048 at 0: Input/output error
```
综合以上情况来看，OSD 已经挂了，原因存在以下可能性
- 磁盘松动造成的 IO error。
- xfs 文件系统异常造成的 IO error。
- 磁盘挂了造成的 IO error。


# 解决问题
```
#获取当前服务器上的osd信息，确认ceph.19磁盘为/dev/sdf
# lsblk
NAME               MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sdb                  8:16   0 447.1G  0 disk
├─sdb1               8:17   0   100M  0 part /var/lib/ceph/osd/ceph-15
└─sdb2               8:18   0   447G  0 part
sdc                  8:32   0 447.1G  0 disk
├─sdc1               8:33   0   100M  0 part /var/lib/ceph/osd/ceph-16
└─sdc2               8:34   0   447G  0 part
sdd                  8:48   0 447.1G  0 disk
├─sdd1               8:49   0   100M  0 part /var/lib/ceph/osd/ceph-17
└─sdd2               8:50   0   447G  0 part
sde                  8:64   0 447.1G  0 disk
├─sde1               8:65   0   100M  0 part /var/lib/ceph/osd/ceph-18
└─sde2               8:66   0   447G  0 part
sdf                  8:80   0 447.1G  0 disk
├─sdf1               8:81   0   100M  0 part /var/lib/ceph/osd/ceph-19
└─sdf2               8:82   0   447G  0 part

#取消挂载
umount /var/lib/ceph/osd/ceph-19

#删除OSD前，它通常是up且in的，要先把它踢出集群，以使Ceph启动重新均衡、把数据拷贝到其他OSD。因为本身这个盘已经挂了，所以正常是已经out了，但我们还是按标准流程操作。
ceph osd out osd.19

#一旦把OSD踢出(out)集群， ceph就会开始重新均衡集群、把归置组迁出将删除的OSD。你可以用ceph工具观察此过程。
ceph -w

#你会看到归置组状态从active+clean变为active, some degraded objects 、迁移完成后最终回到active+clean状态。

#把OSD踢出集群后，它可能仍在运行，就是说其状态为up且out。删除前要先停止OSD进程。
ceph stop osd.19

#删除CRUSH Map中对应的OSD条目，它就不再接收数据了。你也可以反编译CRUSH Map、删除device列表中对应条目、删除host桶中对应条目，并重新编译CRUSH Map并应用它。
ceph osd crush remove osd.19

#删除OSD认证密钥
ceph auth del osd.19

#删除OSD
ceph osd rm 19

#删除对应挂载目录
rm -rf /var/lib/ceph/osd/ceph-19

#格式化分区
# mkfs.xfs -f /dev/sdf
meta-data=/dev/sdf               isize=512    agcount=4, agsize=29303222 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=0, rmapbt=0, reflink=0
data     =                       bsize=4096   blocks=117212886, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=57232, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

#重载分区表信息
partprobe

#创建OSD
pveceph createosd /dev/sdf

#这时候因为OSD19已经加入集群，所以数据迁移开始回退。
# ceph status
  cluster:
    id:     b1cf0cd3-28f9-4fc4-a495-d5bafb3195ec
    health: HEALTH_WARN
            1 nearfull osd(s)
            1 pool(s) nearfull
            136483/1661222 objects misplaced (8.216%) #当前值为8.216%
  services:
    mon: 3 daemons, quorum OB001,OB002,OB003
    mgr: OB002(active), standbys: OB001, OB003
    osd: 20 osds: 20 up, 20 in; 159 remapped pgs
  data:
    pools:   1 pools, 1024 pgs
    objects: 830.61k objects, 3.09TiB
    usage:   6.20TiB used, 2.53TiB / 8.73TiB avail
    pgs:     136483/1661222 objects misplaced (8.216%)
             865 active+clean
             151 active+remapped+backfill_wait
             8   active+remapped+backfilling
  io:
    client:   1.03MiB/s wr, 0op/s rd, 129op/s wr
    recovery: 297MiB/s, 0keys/s, 74objects/s

root@OB004:~# ceph status
  cluster:
    id:     b1cf0cd3-28f9-4fc4-a495-d5bafb3195ec
    health: HEALTH_WARN
            1 nearfull osd(s)
            1 pool(s) nearfull
            136308/1661222 objects misplaced (8.205%) #回退到8.205%,当回退到0的时候就完成了。
  services:
    mon: 3 daemons, quorum OB001,OB002,OB003
    mgr: OB002(active), standbys: OB001, OB003
    osd: 20 osds: 20 up, 20 in; 159 remapped pgs
  data:
    pools:   1 pools, 1024 pgs
    objects: 830.61k objects, 3.09TiB
    usage:   6.20TiB used, 2.53TiB / 8.73TiB avail
    pgs:     136308/1661222 objects misplaced (8.205%)
             865 active+clean
             151 active+remapped+backfill_wait
             8   active+remapped+backfilling
  io:
    client:   1.18MiB/s wr, 0op/s rd, 160op/s wr
    recovery: 304MiB/s, 76objects/s
```

# 结果验证

```
#CEPH状态
# ceph status
  cluster:
    id:     b1cf0cd3-28f9-4fc4-a495-d5bafb3195ec
    health: HEALTH_OK
  services:
    mon: 3 daemons, quorum OB001,OB002,OB003
    mgr: OB002(active), standbys: OB001, OB003
    osd: 20 osds: 20 up, 20 in
  data:
    pools:   1 pools, 1024 pgs
    objects: 820.63k objects, 3.02TiB
    usage:   6.03TiB used, 2.70TiB / 8.73TiB avail
    pgs:     1024 active+clean
  io:
    client:   52.1KiB/s rd, 6.79MiB/s wr, 0op/s rd, 684op/s wr

#OSD状态
# ceph osd status
+----+-------+-------+-------+--------+---------+--------+---------+-----------+
| id |  host |  used | avail | wr ops | wr data | rd ops | rd data |   state   |
+----+-------+-------+-------+--------+---------+--------+---------+-----------+
| 0  | OB001 |  342G |  104G |   71   |   155k  |    0   |     0   | exists,up |
| 1  | OB001 |  322G |  124G |    9   |  36.0k  |    1   |   819   | exists,up |
| 2  | OB001 |  270G |  176G |    0   |  4915   |    0   |   819   | exists,up |
| 3  | OB001 |  301G |  145G |    6   |   122k  |    0   |     0   | exists,up |
| 4  | OB001 |  308G |  138G |    8   |  51.3k  |    0   |     0   | exists,up |
| 5  | OB002 |  226G |  220G |    0   |     0   |    0   |     0   | exists,up |
| 6  | OB002 |  306G |  140G |   29   |   288k  |    0   |     0   | exists,up |
| 7  | OB002 |  358G | 88.4G |    5   |  25.7k  |    0   |     0   | exists,up |
| 8  | OB002 |  339G |  107G |    1   |  8192   |    0   |     0   | exists,up |
| 9  | OB002 |  272G |  174G |    1   |  7270   |    0   |     0   | exists,up |
| 10 | OB003 |  344G |  102G |   35   |  65.8k  |    0   |     0   | exists,up |
| 11 | OB003 |  309G |  137G |    0   |  1945   |    0   |     0   | exists,up |
| 12 | OB003 |  299G |  147G |    8   |   196k  |    0   |     0   | exists,up |
| 13 | OB003 |  356G | 91.0G |    1   |  7577   |    1   |     0   | exists,up |
| 14 | OB003 |  322G |  124G |    8   |  72.9k  |    1   |     0   | exists,up |
| 15 | OB004 |  261G |  185G |   10   |   153k  |    0   |     0   | exists,up |
| 16 | OB004 |  337G |  109G |    0   |  5734   |    1   |     0   | exists,up |
| 17 | OB004 |  307G |  139G |    0   |  3276   |    0   |     0   | exists,up |
| 18 | OB004 |  286G |  160G |  160   |   835k  |    0   |     0   | exists,up |
| 19 | OB004 |  297G |  149G |  308   |  1468k  |    0   |     0   | exists,up |
+----+-------+-------+-------+--------+---------+--------+---------+-----------+

# ceph osd tree
ID CLASS WEIGHT  TYPE NAME      STATUS REWEIGHT PRI-AFF
-1       8.73199 root default
-3       2.18300     host OB001
 0   ssd 0.43660         osd.0      up  1.00000 1.00000
 1   ssd 0.43660         osd.1      up  1.00000 1.00000
 2   ssd 0.43660         osd.2      up  1.00000 1.00000
 3   ssd 0.43660         osd.3      up  1.00000 1.00000
 4   ssd 0.43660         osd.4      up  1.00000 1.00000
-5       2.18300     host OB002
 5   ssd 0.43660         osd.5      up  1.00000 1.00000
 6   ssd 0.43660         osd.6      up  1.00000 1.00000
 7   ssd 0.43660         osd.7      up  1.00000 1.00000
 8   ssd 0.43660         osd.8      up  1.00000 1.00000
 9   ssd 0.43660         osd.9      up  1.00000 1.00000
-7       2.18300     host OB003
10   ssd 0.43660         osd.10     up  1.00000 1.00000
11   ssd 0.43660         osd.11     up  1.00000 1.00000
12   ssd 0.43660         osd.12     up  1.00000 1.00000
13   ssd 0.43660         osd.13     up  1.00000 1.00000
14   ssd 0.43660         osd.14     up  1.00000 1.00000
-9       2.18300     host OB004
15   ssd 0.43660         osd.15     up  1.00000 1.00000
16   ssd 0.43660         osd.16     up  1.00000 1.00000
17   ssd 0.43660         osd.17     up  1.00000 1.00000
18   ssd 0.43660         osd.18     up  1.00000 1.00000
19   ssd 0.43660         osd.19     up  1.00000 1.00000

#获取磁盘信息正常
# smartctl -a /dev/sdf
smartctl 6.6 2016-05-31 r4324 [x86_64-linux-4.15.18-12-pve] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     Q200 EX.
Serial Number:    29CS1024TQYT
LU WWN Device Id: 5 00080d 911346382
Firmware Version: JYRA0102
User Capacity:    480,103,981,056 bytes [480 GB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ACS-2 (minor revision not indicated)
SATA Version is:  SATA 3.1, 6.0 Gb/s (current: 3.0 Gb/s)
Local Time is:    Mon Apr 13 10:52:33 2020 CST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: PASSED

General SMART Values:
Offline data collection status:  (0x00) Offline data collection activity
                                        was never started.
                                        Auto Offline Data Collection: Disabled.
Self-test execution status:      (   0) The previous self-test routine completed
                                        without error or no self-test has ever 
                                        been run.
Total time to complete Offline
data collection:                (  120) seconds.
Offline data collection
capabilities:                    (0x5b) SMART execute Offline immediate.
                                        Auto Offline data collection on/off support.
                                        Suspend Offline collection upon new
                                        command.
                                        Offline surface scan supported.
                                        Self-test supported.
                                        No Conveyance Self-test supported.
                                        Selective Self-test supported.
SMART capabilities:            (0x0003) Saves SMART data before entering
                                        power-saving mode.
                                        Supports SMART auto save timer.
Error logging capability:        (0x01) Error logging supported.
                                        General Purpose Logging supported.
Short self-test routine
recommended polling time:        (   2) minutes.
Extended self-test routine
recommended polling time:        (  19) minutes.
SCT capabilities:              (0x003d) SCT Status supported.
                                        SCT Error Recovery Control supported.
                                        SCT Feature Control supported.
                                        SCT Data Table supported.

SMART Attributes Data Structure revision number: 16
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  1 Raw_Read_Error_Rate     0x000a   100   100   000    Old_age   Always       -       0
  2 Throughput_Performance  0x0005   100   100   050    Pre-fail  Offline      -       0
  3 Spin_Up_Time            0x0007   100   100   050    Pre-fail  Always       -       0
  5 Reallocated_Sector_Ct   0x0013   100   100   050    Pre-fail  Always       -       0
  7 Unknown_SSD_Attribute   0x000b   100   100   050    Pre-fail  Always       -       0
  8 Unknown_SSD_Attribute   0x0005   100   100   050    Pre-fail  Offline      -       0
  9 Power_On_Hours          0x0012   100   100   000    Old_age   Always       -       8778
 10 Unknown_SSD_Attribute   0x0013   100   100   050    Pre-fail  Always       -       0
 12 Power_Cycle_Count       0x0012   100   100   000    Old_age   Always       -       9
167 Unknown_Attribute       0x0022   100   100   000    Old_age   Always       -       0
168 Unknown_Attribute       0x0012   100   100   000    Old_age   Always       -       0
169 Unknown_Attribute       0x0013   100   100   010    Pre-fail  Always       -       100
173 Unknown_Attribute       0x0012   189   189   000    Old_age   Always       -       0
175 Program_Fail_Count_Chip 0x0013   100   100   010    Pre-fail  Always       -       0
192 Power-Off_Retract_Count 0x0012   100   100   000    Old_age   Always       -       6
194 Temperature_Celsius     0x0023   079   067   020    Pre-fail  Always       -       21 (Min/Max 14/33)
197 Current_Pending_Sector  0x0012   100   100   000    Old_age   Always       -       0
240 Unknown_SSD_Attribute   0x0013   100   100   050    Pre-fail  Always       -       0

SMART Error Log Version: 1
No Errors Logged

SMART Self-test log structure revision number 1
No self-tests have been logged.  [To run self-tests, use: smartctl -t]

SMART Selective self-test log data structure revision number 1
 SPAN  MIN_LBA  MAX_LBA  CURRENT_TEST_STATUS
    1        0        0  Not_testing
    2        0        0  Not_testing
    3        0        0  Not_testing
    4        0        0  Not_testing
    5        0        0  Not_testing
Selective self-test flags (0x0):
  After scanning selected spans, do NOT read-scan remainder of disk.
If Selective self-test is pending on power-up, resume after 0 minute delay.
```






