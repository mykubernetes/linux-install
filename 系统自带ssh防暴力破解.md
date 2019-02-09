系统自带ssh防暴力破解
===================
通过pam 模块来防止暴力破解ssh
```
# vim /etc/pam.d/sshd
在第一行下面添加一行：
auth    required    pam_tally2.so    deny=3    unlock_time=600 even_deny_root root_unlock_time=1200
```  
说明：尝试登陆失败超过3次，普通用户600秒解锁，root用户1200秒解锁  

手动解除锁定：
查看某一用户错误登陆次数：
pam_tally2 –-user
例如，查看work用户的错误登陆次数：
pam_tally2 –-user work
清空某一用户错误登陆次数：
pam_tally2 –-user –-reset
例如，清空 work 用户的错误登陆次数，
pam_tally2 –-user work –-reset 
