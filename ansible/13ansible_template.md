# template模块

| 参数 | 描述 |
|------|------|
| src | 本地Jinjia2模版的template文件位置。 |
| dest | 远程节点上的绝对路径，用于放置template文件。 |
| owner | 指定最终生成的文件拷贝到远程主机后的属主。 |
| group | 指定最终生成的文件拷贝到远程主机后的属组。 |
| mode | 指定最终生成的文件拷贝到远程主机后的权限，如果你想将权限设置为"rw-r–r--"，则可以使用mode=0644表示，如果你想要在user对应的权限位上添加执行权限，则可以使用mode=u+x表示。 |
| force | 当远程主机的目标路径中已经存在同名文件，并且与最终生成的文件内容不同时，是否强制覆盖，可选值有yes和no，默认值为yes，表示覆盖，如果设置为no，则不会执行覆盖拷贝操作，远程主机中的文件保持不变。 | 
| backup | 当远程主机的目标路径中已经存在同名文件，并且与最终生成的文件内容不同时，是否对远程主机的文件进行备份，可选值有yes和no，当设置为yes时，会先备份远程主机中的文件，然后再将最终生成的文件拷贝到远程主机 |


```
# 1、编写template文件并修改配置对应到变量
# cat /opt/src/redis.conf |grep ^bind
bind {{ ansible_enp0s3.ipv4.address }}

# 2、编写playbook文件
# cat first.yaml
- hosts: node01
  remote_user: root
  tasks:
   - name: install redis
     yum: name=redis state=present
   - name: copy config file
     template: src=/opt/src/redis.conf dest=/etc/redis.conf owner=redis
     notify: restart redis
     tags: conf
   - name: start redis
     service: name=redis state=started enabled=true
  handlers:
   - name: restart redis
     service: name=redis state=restarted

# 3、运行后查看配置文件是否更换
# cat /etc/redis.conf |grep ^bind
bind 192.168.1.70
```
