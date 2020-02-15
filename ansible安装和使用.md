ansible安装和使用
===========
1、安装ansible  
``` yum install -y ansible ```  
2、配置ansible可以获取的主机  
```
vim /etc/ansible/hosts
[webserver]
node01
node02
[dbserver]
192.168.1.[1:3]
```  
3、常用命令  
0)查看模块帮助
``` ansible-doc -s file ```  
1)ping测试  
``` ansible all -m ping ```  
2)group  
``` ansible webserver -m group -a "name=mygrp gid=3000 state=present system=no" ```  
3)user  
``` ansible all -m user -a "name=hadoop uid=3000 state=present system=no" ```  
4)copy  
``` ansible node02 -m copy -a "src=/etc/fstab dest=/opt/fstab.ansible mode=600 owner=hadoop group=hadoop" ```  
``` ansible node02 -m copy -a "src=/etc/pam.d/ dest=/tmp/ " ```  
5)command  
``` ansible all -m command -a "chdir=/opt/ touch new.ansible" ```  
6)shell  
``` ansible node02 -m shell -a "cat /etc/fstab |grep ^#" ```  
7)file  
``` ansible all -m file -a "path=/opt/test.dir state=directory" ```  
``` ansible all -m file -a "src=/etc/fstab path=/tmp/fstab.ansible state=link" ```  
8)cron  
``` ansible all -m cron -a "minute=*/3 job='/usr/bin/update 192.168.1.1 &> /dev/null' state=present name=update" ```  
9)yum  
``` ansible all -m yum -a "name=nginx state=installed" ```  
10)service  
``` ansible all -m service -a "name=httpd state=started enabled=true" ```  
11)script 本地脚本拷贝到目标主机执行  
``` ansible all -m script -a "/opt/script_file.sh" ```  

4、ansible playbook  
1)检查语法是否正确  
``` ansible-playbook --syntax-checak first.yaml ```  
2)不实际运行测试  
``` ansible-playbook -C first.yaml ```   
3)检查运行的主机  
``` ansible-playbook --list-host first.yaml ```  
4)基本语法  

在变更时执行操作（handlers）
notify：在任务结束时触发  
handlers：由特定条件触发Tasks  
```
- hosts: node01
  remote_user: root
  tasks:
   - name: install redis
     yum: name=redis state=present
   - name: copy config file
     copy: src=/opt/src/redis.conf dest=/etc/redis.conf owner=redis
     notify: restart redis
     tags: conf
   - name: start redis
     service: name=redis state=started enabled=true
  handlers:
   - name: restart redis
     service: name=redis state=restarted
```  
```
ansible-playbook first.yaml                    #运行playbook
ansible-playbook -t conf first.yaml        #运行tags里的命令
```  
5)ansible查看变量  
``` ansible node01 -m setup ```  
```
- hosts: node01
  remote_user: root
  tasks:
   - name: copy file
     copy: content={{ ansible_env }} dest=/tmp/ansible.env
```   
6)命令行传递变量  
```  
#  ansible-playbook -e pkgname=memcached  test.yaml
# cat test.yaml
- hosts: node01
  remote_user: root
  tasks:
   - name: install package {{ pkgname }}
     yum: name={{ pkgname }} state=latest
```  
7)invertory参数变量  
ansible_ssh_host  
ansible_ssh_port  
ansible_ssh_user  
ansible_ssh_pass  
ansible_ssh_sudo_pass  
```
# cat /etc/ansible/hosts
   [test]
   node01 ansible_ssh_port=5678 ansible_ssh_user=hadoop ansible_ssh_pass=123456
   [web]
   node01 http_port=80
   node02 http_port=8080
[test:vars]                  #组变量
   http_port=9090

#cat test.yaml
- hosts: web
  remote_user: root
  tasks:
   - name: http_port
     copy: content={{ http_port }} dest=/opt/test_http_port

# ansible test  -m shell -a "whoami"
   192.168.1.71 | SUCCESS | rc=0 >>
 hadoop
```  
8)playbook变量  
```
# cat test.yaml
- hosts: node01
  remote_user: root
  vars:
  - pbvar: plabook_variable_testing
  tasks:
   - name: host playbook var
     copy: content={{ pbvar }} dest=/tmp/playbook.var
```  
9)template文件
```
# cat /opt/src/redis.conf |grep ^bind
bind {{ ansible_enp0s3.ipv4.address }}

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

# cat /etc/redis.conf |grep ^bind
bind 192.168.1.70
```  
10)when判断
```
- hosts: web
  remote_user: root
  tasks:
   - name: install httpd
     yum: name=httpd state=latest
     when: ansible_os_family == "RedHat"
   - name: install apache2
     when: ansible_os_family == "Debian"
     apt: name=apache2 state=latest
```  
11)with_items迭代   
```
- hosts: web
  remote_user: root
  tasks:
   - name: install {{ item }} package
     yum: name={{ item }}  state=latest
     with_items:
      - tomcat
      - tomcat-webapps
      - tomcat-admin-webapps
```  
12)roles  
```
mkdir /etc/ansible/roles/nginx/{tasks,vars,templates,files,handlers,meta,default} -pv
# cat /opt/playbook/httpd.yaml
- hosts: web
  remote_user: root
  roles:
   - nginx

# tree /etc/ansible/roles/nginx/
/etc/ansible/roles/nginx/
├── files
│    └── index.html
├── handlers
│    └── main.yaml
├── tasks
│    └── main.yml
├── templates
│    └── vhost1.conf.j2
└── vars
    └── main.yaml

# cat nginx/files/index.html
<h1>Vhost1</h1>

# cat nginx/handlers/main.yaml
- name: restart nginx
  service: name=nginx state=restarted

# cat nginx/tasks/main.yml
- name: install httpd
  yum: name=nginx state=latest
- name: install conf
  template: src=vhost1.conf.j2 dest=/etc/nginx/conf.d/vhost1.conf
  tags: conf
  notify: restart nginx
- name: install site home directory
  file: path={{ ngxroot }} state=directory
- name: install index page
  copy: src=index.html dest={{ ngxroot }}/
- name: start nginx
  service: name=nginx state=started

# cat nginx/templates/vhost1.conf.j2
server {
        listen 8080;
        server_name {{ ansible_fqdn }};
        location / {
                root "/ngxdata/vhost1";
        }
}

# cat nginx/vars/main.yaml
ngxroot: /ngxdata/vhost1
```  


自动部署Tomcat
```
---
hosts: webservers 
   gather_facts: no
   vars:
     tomcat_version: 8.5.34
     tomcat_install_dir: /usr/local
  
  tasks:
    - name: Install jdk1.8
      yum: name=java-1.8.0-openjdk state=present
 
    - name: Download tomcat
      get_url: url=http://mirrors.hust.edu.cn/apache/tomcat/tomcat-8/v{{ tomcat_version }}/bin/
                   apache-tomcat-{{ tomcat_version }}.tar.gz dest=/tmp
 
    - name: Unarchive tomcat-{{ tomcat_version }}.tar.gz
      unarchive:
        src: /tmp/apache-tomcat-{{ tomcat_version }}.tar.gz 
        dest: "{{ tomcat_install_dir }}"
        copy: no 
 
    - name: Start tomcat 
      shell: cd {{ tomcat_install_dir }} &&
             mv apache-tomcat-{{ tomcat_version }} tomcat8 &&
             cd tomcat8/bin && nohup ./startup.sh &
```
