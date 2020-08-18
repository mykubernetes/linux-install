1、安装
```
wget  http://nchc.dl.sourceforge.net/project/extundelete/extundelete/0.2.4/extundelete-0.2.4.tar.bz2
tar jxvf extundelete-0.2.4.tar.bz2
cd  extundelete-0.2.4
./configure 
make
make  install
```

2、扫描误删除的文件
```
# extundelete  --inode 2 /dev/vdb1
NOTICE: Extended attributes are not restored.
Loading filesystem metadata ... 8 groups loaded.
Group: 0
Contents of inode 2:
.
.省略N行
File name                                       | Inode number | Deleted status
.                                                 2
..                                                2
lost+found                                        11             Deleted
deletetest                                        12             Deleted
passwd                                            14             Deleted`
```


3、恢复单一文件passwd
```
# extundelete /dev/vdb1 --restore-file passwd   
NOTICE: Extended attributes are not restored.
Loading filesystem metadata ... 8 groups loaded.
Loading journal descriptors ... 46 descriptors loaded.
Successfully restored file passwd
```

恢复文件是放到了当前目录RECOVERED_FILES。 查看恢复的文件：
```
# tail  -5  RECOVERED_FILES/passwd 
mysql:x:497:500::/home/mysql:/bin/false
nginx:x:496:501::/home/nginx:/sbin/nologin
zabbix:x:495:497:Zabbix Monitoring System:/var/lib/zabbix:/sbin/nologin
haproxy:x:500:502::/home/haproxy:/bin/bash
tcpdump:x:72:72::/:/sbin/nologin
```

4、恢复目录deletetest
```
# extundelete /dev/vdb1 --restore-directory  deletetest 
NOTICE: Extended attributes are not restored.
Loading filesystem metadata ... 8 groups loaded.
Loading journal descriptors ... 46 descriptors loaded.
Searching for recoverable inodes in directory deletetest ... 
5 recoverable inodes found.
Looking through the directory structure for deleted files ... 

# cat  RECOVERED_FILES/deletetest/mail/test.py 
hello Dj
```

5、恢复所有
```
# extundelete /dev/vdb1 --restore-all
NOTICE: Extended attributes are not restored.
Loading filesystem metadata ... 8 groups loaded.
Loading journal descriptors ... 46 descriptors loaded.
Searching for recoverable inodes in directory / ... 
5 recoverable inodes found.
Looking through the directory structure for deleted files ... 
0 recoverable inodes still lost. 

# cd RECOVERED_FILES/
# tree
.
├── deletetest
│   └── mail
│       └── test.py
└── passwd
2 directories, 2 files
```

6、恢复指定inode
```
# extundelete /dev/vdb1 --restore-inode 14
NOTICE: Extended attributes are not restored.
Loading filesystem metadata ... 8 groups loaded.
Loading journal descriptors ... 46 descriptors loaded.

# tail  -5   /RECOVERED_FILES/file.14 
mysql:x:497:500::/home/mysql:/bin/false
nginx:x:496:501::/home/nginx:/sbin/nologin
zabbix:x:495:497:Zabbix Monitoring System:/var/lib/zabbix:/sbin/nologin
haproxy:x:500:502::/home/haproxy:/bin/bash
tcpdump:x:72:72::/:/sbin/nologin
```

