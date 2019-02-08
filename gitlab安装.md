gitlab安装
=========
安装包下载  
链接：https://pan.baidu.com/s/1s_lhVwptdTcSOLj4I5niVg 提取码：qddn  
1、安装依赖库  
``` yum install curl policycoreutils openssh-server openssh-clients postfix -y ```  
2、下载gitlab软件  
``` https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/gitlab-ce-10.2.3-ce.0.el7.x86_64.rpm ```  
``` rpm -ivh gitlab-ce-10.2.3-ce.0.el7.x86_64.rpm ```  
3、启动邮件  
``` systemctl start postfix ；systemctl enable postfix ```  
4、初始化gitlab   
配置 gitlab 域名：  
```
# vim /etc/gitlab/gitlab.rb    #修改 gitlab 外部访问地址
 external_url 'http://192.168.1.63'
```
``` gitlab-ctl reconfigure ```  
5、查看gitlab运行状态  
```
# gitlab-ctl status        
run: gitlab-workhorse: (pid 3275) 169s; run: log: (pid 3151) 280s
run: logrotate: (pid 3169) 273s; run: log: (pid 3168) 273s
run: nginx: (pid 3157) 279s; run: log: (pid 3156) 279s
run: postgresql: (pid 3009) 349s; run: log: (pid 3008) 349s
run: redis: (pid 2926) 360s; run: log: (pid 2925) 360s
run: sidekiq: (pid 3142) 287s; run: log: (pid 3141) 287s
run: unicorn: (pid 3110) 293s; run: log: (pid 3109) 293s
```  
6、管理 gitlab  
```
# gitlab-ctl stop       关闭 gitlab： 
# gitlab-ctl start      启劢 gitlab：
# gitlab-ctl restart    重启 gitlab： 
```  
gitlab 主配置文件：  
``` /etc/gitlab/gitlab.rb //可以自定义一些邮件服务等 ```  
日志地址：  
``` /var/log/gitlab/ // 对应各服务 ```  
服务地址：  
``` /var/opt/gitlab/ // 对应各服务的主目录 ```  
仓库地址：  
``` /var/opt/gitlab/git-data //记录项目仓库等提交信息 ```  
重置配置：  
``` gitlab-ctl reconfigure //不要乱用，会重置为最原始的配置的 ```  
重启服务：  
``` gitlab-ctl stop/start/restart //启劢命令 ```  

