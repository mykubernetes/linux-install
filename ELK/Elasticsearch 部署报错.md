# 问题一：
报错：
```
[2019-03-06T17:21:21,129][WARN ][o.e.b.JNANatives ] [unknown] unable to install syscall filter: java.lang.UnsupportedOperationException: seccomp unavailable: requires kernel 3.5+ with CONFIG_SECCOMP and CONFIG_SECCOMP_FILTER compiled in
```

原因：
- 报了一大串错误，大家不必惊慌，其实只是一个警告，主要是因为你 Linux 版本过低造成的。

解决方案：
```
1、重新安装新版本的 Linux 系统
2、警告不影响使用，可以忽略
```
# 问题二：
报错：
```
[1]ERROR: bootstrap checks failed max file descriptors [4096] for elasticsearch process likely too low, increase to at least [65536]
```

原因：
- 无法创建本地文件问题,用户最大可创建文件数太小

解决方案：
```
切换到 root 用户，编辑 limits.conf 配置文件， 添加类似如下内容：
vi /etc/security/limits.conf
添加如下内容:
* soft nofile 65536
* hard nofile 131072
* soft nproc 2048
* hard nproc 4096
备注：* 代表 Linux 所有用户名称（比如 es）
保存、退出、重新登录才可生效
```

# 问题三：
报错：
```
[2]max number of threads [1024] for user [es] likely too low, increase to at least [2048]
```

原因：
- 无法创建本地线程问题,用户最大可创建线程数太小

解决方案：
```
切换到 root 用户，进入 limits.d 目录下，修改 90-nproc.conf 配置文件。
vi /etc/security/limits.d/90-nproc.conf
找到如下内容：
* soft nproc 1024
#修改为
* soft nproc 4096
```

# 问题四：
报错：
```
[3]max virtual memory areas vm.max_map_count [65530] likely too low, increase to at least [262144]
```

原因：
- 最大虚拟内存太小

解决方案：
```
切换到 root 用户下，修改配置文件 sysctl.conf
vi /etc/sysctl.conf
添加下面配置：
vm.max_map_count=655360
并执行命令(配置生效)：
sysctl -p
然后重新启动 elasticsearch，即可启动成功。
```

# 问题五：
报错：
```
[4]ERROR: bootstrap checks failed system call filters failed to install; check the logs and fix your configuration or disable system call filters at your own risk
```

原因：
- 这是在因为 Centos6 不支持 SecComp，而 ES5.6.4 默认 bootstrap.system_call_filter 为 true 进行检测，所以导致检测失败，失败后直接导致 ES 不能启动。

解决：
```
在 elasticsearch.yml 中配置 bootstrap.system_call_filter 为 false，注意要在 Memory 下面:
bootstrap.memory_lock: false
bootstrap.system_call_filter: false
```
