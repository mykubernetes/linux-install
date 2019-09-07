https://blog.csdn.net/chinawangfei/article/details/81912372  
https://blog.csdn.net/qq_25934401/article/details/82225289  

github托管代码  
https://github.com/Supervisor/supervisor  
官网  
http://supervisord.org/  

安装  
---
```
yum install python-setuptools
easy_install supervisor 或者使用 pip install supervisor
```  



配置
---
输出supervisor配置，可以使用echo_supervisord_conf重定向到文件中  
运行supervisord服务的时候，需要指定supervisor配置文件，如果没有显示指定，默认在以下目录查找  
```
###$CWD表示运行supervisord程序的目录。
$CWD/supervisord.conf 
$CWD/etc/supervisord.conf
/etc/supervisord.conf
/etc/supervisor/supervisord.conf (since Supervisor 3.3.0)
../etc/supervisord.conf (Relative to the executable)
../supervisord.conf (Relative to the executable)
```  

重定向配置文件到/etc/目录下面  
```
mkdir /etc/supervisor.d
echo_supervisord_conf > /etc/supervisord.conf
```  



配置文件参数说明
---
```
# vim /etc/supervisord.conf
[unix_http_server]
file=/tmp/supervisor.sock   ;UNIX socket 文件，supervisorctl会使用其与supervisord通信
;chmod=0700                 ;socket文件的mode，默认是0700
;chown=nobody:nogroup       ;socket文件的owner，格式：uid:gid
 
;[inet_http_server]         ;HTTP服务器，提供web管理界面
;port=127.0.0.1:9001        ;Web管理后台运行的IP和端口，如果开放到公网，需要注意安全性
;username=user              ;登录管理后台的用户名
;password=123               ;登录管理后台的密码
 
[supervisord]
logfile=/tmp/supervisord.log ;日志文件，默认是 $CWD/supervisord.log
logfile_maxbytes=50MB        ;日志文件大小，超出会rotate，默认 50MB。如果设成0，表示不限制大小
logfile_backups=10           ;日志文件保留备份数量默认10，设为0表示不备份
loglevel=info                ;日志级别，默认info，其它: debug,warn,trace
pidfile=/tmp/supervisord.pid ;pid 文件
nodaemon=false               ;是否在前台启动，默认是false，即以 daemon 的方式启动
minfds=1024                  ;可以打开的文件描述符的最小值，默认 1024
minprocs=200                 ;可以打开的进程数的最小值，默认 200
 
[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ;通过UNIX socket连接supervisord，路径与unix_http_server部分的file一致
;serverurl=http://127.0.0.1:9001 ; 通过HTTP的方式连接supervisord
 
; [program:xx]是被管理的进程配置参数，xx是进程的名称
[program:xx]
command=/opt/apache-tomcat-8.0.35/bin/catalina.sh run  ; 程序启动命令
autostart=true       ; 在supervisord启动的时候也自动启动
startsecs=10         ; 启动10秒后没有异常退出，就表示进程正常启动了，默认为1秒
autorestart=true     ; 程序退出后自动重启,可选值：[unexpected,true,false]，默认为unexpected，表示进程意外杀死后才重启
startretries=3       ; 启动失败自动重试次数，默认是3
user=tomcat          ; 用哪个用户启动进程，默认是root
priority=999         ; 进程启动优先级，默认999，值小的优先启动
redirect_stderr=true ; 把stderr重定向到stdout，默认false
stdout_logfile_maxbytes=20MB  ; stdout 日志文件大小，默认50MB
stdout_logfile_backups = 20   ; stdout 日志文件备份数，默认是10
; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动创建目录（supervisord 会自动创建日志文件）
stdout_logfile=/opt/apache-tomcat-8.0.35/logs/catalina.out
stopasgroup=false     ;默认为false,进程被杀死时，是否向这个进程组发送stop信号，包括子进程
killasgroup=false     ;默认为false，向进程组发送kill信号，包括子进程
 
;包含其它配置文件
[include]
files = /etc/supervisor.d/*.conf   ;可以指定一个或多个以.conf结束的配置文件
```  

服务配置模板
---
```
# vim /etc/supervisor.d/usercenter.conf
[program:usercenter] 
directory = /home/leon/projects/usercenter ; 程序的启动目录
command = gunicorn -w 8 -b 0.0.0.0:17510 wsgi:app  ; 启动命令
autostart = true     ; 在 supervisord 启动的时候也自动启动
startsecs = 5        ; 启动 5 秒后没有异常退出，就当作已经正常启动了
autorestart = true   ; 程序异常退出后自动重启
startretries = 3     ; 启动失败自动重试次数，默认是 3
user = leon          ; 用哪个用户启动
redirect_stderr = true  ; 把 stderr 重定向到 stdout，默认 false
stdout_logfile_maxbytes = 20MB  ; stdout 日志文件大小，默认 50MB
stdout_logfile_backups = 20     ; stdout 日志文件备份数
; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动创建目录（supervisord 会自动创建日志文件）
stdout_logfile = /data/logs/usercenter_stdout.log
如果只杀死主进程，子进程就可能变成孤儿进程。通过这下面两项配置来确保所有子进程都能正确停止
stopasgroup=true
killasgroup=true
```  
- Supervisor 只能管理在前台运行的程序，所以如果应用程序有后台运行的选项，需要关闭。

node_prometheus 启动的例子
---
```
# cat /etc/supervisor.d/node_exporter.conf 
[program:node_exporter]
command=/usr/local/bin/node_exporter
stdout_logfile=/usr/local/prometheus/prometheus.log
autostart=true
autorestart=true
startsecs=5
priority=1
user=root
stopasgroup=true
killasgroup=true
```  


管理supervisor下的服务
---
```
###启动服务
supervisorctl start all
supervisorctl start service_name
###关闭服务
supervisorctl stop all
supervisorctl stop service_name
###查看状态
supervisorctl status [service_name]
###重新启动所有服务或者是某个服务
supervisorctl restart all
supervisorctl restart service_name
实例：
# supervisorctl 
node_exporter                    RUNNING   pid 26950, uptime 0:23:25
supervisor> 
```  


开机启动Supervisor服务
---
1、配置systemctl服务
```
# vim /lib/systemd/system/supervisor.service
[Unit]
Description=supervisor
After=network.target
 
[Service]
Type=forking
ExecStart=/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
ExecStop=/usr/bin/supervisorctl $OPTIONS shutdown
ExecReload=/usr/bin/supervisorctl $OPTIONS reload
KillMode=process
Restart=on-failure
RestartSec=42s
 
[Install]
WantedBy=multi-user.target
```  

2、设置开机启动
```
$ systemctl enable supervisor.service
$ systemctl daemon-reload
```  

3、修改文件权限为766  
```
$ chmod 766 /lib/systemd/system/supervisor.service 
```  

4、启动supervisor  
```
systemctl start supervisor.service
```  
