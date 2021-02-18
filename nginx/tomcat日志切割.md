Logrotate运行机制  
系统会定时运行logrotate，一般是每天一次  

安装配置Logrotate  
1、安装logrotate  
```
# yum install -y logrotate
```  

logrotate安装的文件
```
/usr/bin/logrotate              # 程序所在位置；
/etc/cron.daily/logrotate       # 默认让Cron每天执行logrotate一次；
/etc/logrotate.conf             # 全局配置文件；
/etc/logrotate.d                # 应用自个的配置文件存放目录，覆盖全局配置；
```  

logrotate命令支持以下参数
```
# logrotate --help
Usage: logrotate [OPTION...] <configfile>
  -d, --debug               Don\'t do anything, just test (implies -v)
  -f, --force               Force file rotation
  -m, --mail=command        Command to send mail (instead of \`/bin/mail\')
  -s, --state=statefile     Path of state file
  -v, --verbose             Display messages during rotation
  -l, --log=STRING          Log file
  --version                 Display version information

Help options:
  -?, --help                Show this help message
  --usage                   Display brief usage message
```
- -d, --debug #debug模式，测试配置文件是否有错误
- -f, --force #强制转储文件
- -m, --mail=command #压缩日志后，发送日志到指定邮箱
- -s, --state=statefile #使用指定的状态文件
- -v, --verbose #显示转储过程


logrotate配置文件
| 配置 | 说明 |
|-----|------|
| compress | 通过gzip 压缩转储以后的日志 |
| nocompress | 不做gzip压缩处理 |
| copytruncate | 用于还在打开中的日志文件，把当前日志备份并截断；是先拷贝再清空的方式，拷贝和清空之间有一个时间差，可能会丢失部分日志数据。 |
| nocopytruncate | 备份日志文件不过不截断 |
| create mode owner group | 轮转时指定创建新文件的属性，如create 0777 nobody nobody |
| nocreate | 不建立新的日志文件 |
| delaycompress | 和compress 一起使用时，转储的日志文件到下一次转储时才压缩 |
| nodelaycompress | 覆盖 delaycompress 选项，转储同时压缩。 |
| missingok | 如果日志丢失，不报错继续滚动下一个日志 |
| errors address | 专储时的错误信息发送到指定的Email 地址 |
| ifempty | 即使日志文件为空文件也做轮转，这个是logrotate的缺省选项。 |
| notifempty | 当日志文件为空时，不进行轮转 |
| mail address | 把转储的日志文件发送到指定的E-mail 地址 |
| nomail | 转储时不发送日志文件 |
| olddir directory | 转储后的日志文件放入指定的目录，必须和当前日志文件在同一个文件系统 |
| noolddir | 转储后的日志文件和当前日志文件放在同一个目录下 |
| sharedscripts | 运行postrotate脚本，作用是在所有日志都轮转后统一执行一次脚本。如果没有配置这个，那么每个日志轮转后都会执行一次脚本 |
| prerotate | 在logrotate转储之前需要执行的指令，例如修改文件的属性等动作；必须独立成行 |
| postrotate | 在logrotate转储之后需要执行的指令，例如重新启动 (kill -HUP) 某个服务！必须独立成行 |
| daily | 指定转储周期为每天 |
| weekly | 指定转储周期为每周 |
| monthly | 指定转储周期为每月 |
| rotate count | 指定日志文件删除之前转储的次数，0 指没有备份，5 指保留5 个备份 |
| dateext | 使用当期日期作为命名格式 |
| dateformat .%s | 配合dateext使用，紧跟在下一行出现，定义文件切割后的文件名，必须配合dateext使用，只支持 %Y %m %d %s 这四个参数 |
| size(或minsize) | 当日志文件到达指定的大小时才转储 |
| log-size | log-size能指定bytes(缺省)及KB (sizek)或MB(sizem).当日志文件 >= log-size 的时候就转储 |

2、配置文件logrotate  
```
# cat /etc/logrotate.d/tomcat
/application/tomcat/logs/catalina.out {
    daily
    copytruncate
    rotate 30
    compress
    notifempty
    dateext
    missingok
}
```  
- daily           表示每天整理一次    
- rotate 30       表示保留30天的备份文件
- dateext         文件后缀是日期格式,也就是切割后文件是:xxx.log-20171205.gz
- copytruncate    用于还在打开中的日志文件，把当前日志备份并截断
- compress        通过gzip压缩转储以后的日志（gzip -d xxx.gz解压）
- missingok       如果日志不存在则忽略该警告信息
- notifempty      如果是空文件的话，不转储
- #size 5M        #当catalina.out大于5M就进行切割，可用可不用！
注意:配置文件里一定要配置rotate 文件数目这个参数。如果不配置默认是0个，也就是只允许存在一份日志，刚切分出来的日志会马上被删除  



以下是不常用参数  
```
1. weekly                       指定转储周期为每周
2. monthly                      指定转储周期为每月
3. nocompress                   不需要压缩时，用这个参数 
4. nocopytruncate               备份日志文件但是不截断
5. create mode owner group      转储文件，使用指定的文件模式创建新的日志文件
6. nocreate                     不建立新的日志文件
7. delaycompress 和 compress    一起使用时，转储的日志文件到下一次转储时才压缩
8. nodelaycompress              覆盖 delaycompress 选项，转储同时压缩
9. errors address               转储时的错误信息发送到指定的Email 地址
10. ifempty                     即使是空文件也转储，这个是 logrotate 的缺省选项。
11. mail address                把转储的日志文件发送到指定的E-mail 地址
12. nomail                      转储时不发送日志文件
13. olddir directory            转储后的日志文件放入指定的目录，必须和当前日志文件在同一个文件系统 
14. noolddir                    转储后的日志文件和当前日志文件放在同一个目录
15. prerotate/endscript     在转储以前需要执行的命令可以放入这个对，这两个关键字必须单独成行
16. postrotate/endscript   在转储以后需要执行的命令可以放入这个对，这两个关键字必须单独成行
```  

3、测试  
```
# 1. 调试 （d = debug）参数为配置文件，不指定则执行全局配置文件
logrotate -d /etc/logrotate.d/tomcat.conf

# 2. 强制执行（-f = force），可以配合-v(-v =verbose）使用，注意调试信息默认携带-v；
logrotate -v -f /etc/logrotate.d/tomcat.conf
```  
