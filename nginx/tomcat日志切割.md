Logrotate运行机制  
系统会定时运行logrotate，一般是每天一次  

安装配置Logrotate  
1、安装logrotate  
```
# yum install -y logrotate
```  

```
/usr/bin/logrotate 程序所在位置；
/etc/cron.daily/logrotate 默认让Cron每天执行logrotate一次；
/etc/logrotate.conf 全局配置文件；
/etc/logrotate.d 应用自个的配置文件存放目录，覆盖全局配置；
```  

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
