MHA工具介绍  
---
1、MHA软件由两部分组成，Manager工具包和Node工具包，具体的说明如下：  
Manager工具包主要包括以下几个工具：  
```
masterha_check_ssh              #检查MHA的ssh-key
masterha_check_repl             #检查主从复制情况
masterha_manger                 #启动MHA
masterha_check_status           #检测MHA的运行状态
masterha_master_monitor         #检测master是否宕机
masterha_master_switch          #手动故障转移
masterha_conf_host              #手动添加server信息
masterha_secondary_check        #建立TCP连接从远程服务器
masterha_stop                   #停止MHA
```
Node工具包主要包括以下几个工具：  
```
save_binary_logs                #保存宕机的master的binlog
apply_diff_relay_logs           #识别relay log的差异
filter_mysqlbinlog              #防止回滚事件
purge_relay_logs                #清除中继日志
```  
