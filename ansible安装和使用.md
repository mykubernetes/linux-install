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

ansible playbook
===

1)检查语法是否正确  
---
``` ansible-playbook --syntax-checak first.yaml ```  

2)不实际运行测试  
---
``` ansible-playbook -C first.yaml ```   

3)检查运行的主机  
---
``` ansible-playbook --list-host first.yaml ```  

4)基本语法  
---
在变更时执行操作（handlers）  
notify：在任务结束时触发  
handlers：由特定条件触发Tasks  
任务控制（tags）  
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
ansible-playbook first.yaml                #运行playbook
ansible-playbook -t conf first.yaml        #运行tags里的命令
```  

5)ansible查看变量  
---
``` ansible node01 -m setup ```  
```
- hosts: node01
  remote_user: root
  tasks:
   - name: copy file
     copy: content={{ ansible_env }} dest=/tmp/ansible.env
```   

6)命令行传递变量  
---
```  
#  ansible-playbook -e pkgname=memcached  test.yaml
# cat test.yaml
- hosts: node01
  remote_user: root
  tasks:
   - name: install package {{ pkgname }}
     yum: name={{ pkgname }} state=latest
```  

7)在Playbook中定义变量
---
```
- hosts: webservers
    gather_facts: no
    vars:
      var_name: value
      var_name: value
    tasks:
      - name: hello
        shell: "echo {{var_name}}"
```

8）注册变量（register）
---
```
- hosts: webservers 
    gather_facts: no
    tasks:
      - name: Get date 
        command: date +"%F_%T"
        register: date_output
      - name: Echo date_output
        command: touch /tmp/{{date_output.stdout}}
```

9)系统信息变量（facts）
---
```
- hosts: webservers 
    gather_facts: no
    tasks:
      - name: Get date 
        command: date +"%F_%T"
        register: date_output
      - name: Echo date_output
        command: touch /tmp/{{date_output.stdout}}

```

10)invertory参数变量  
---
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

11)playbook变量  
---
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

12)template文件
---
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

13)when判断
---
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

14)with_items迭代   
---
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

```
- name: with_list
  debug:
    msg: "{{ item }}"
  with_list:
    - one
    - two

- name: with_list -> loop
  debug:
    msg: "{{ item }}"
  loop:
    - 1
    - 2

- name: with_items
  user: name={{itme.name}} groups={{item.groups}} state=present
  with_items:
    - {name: 'zhangsan', groups: nginx}
    - {name: 'lisi', groups: nginx}

#通过变量传递的方式
- name: with_items -> loop
  debug:
    msg: "{{ item }}"
  loop: "{{ items|flatten(levels=1) }}"

```

15)Playbook模板（jinja2）
---
条件和循环
```
# cat test.yml 
---
- hosts: webservers
  vars:
   hello: Ansible
 
  tasks:
    - template: src=f.j2 dest=/tmp/f.j2


# cat f.j2 
{% set list=['one', 'two', 'three'] %}
 
{% for i in list %}
   {% if i == 'two' %}
       -> two
   {% elif loop.index == 3 %}
       -> 3
   {% else %}
       {{i}}
   {% endif %}
{% endfor %} 
 
{{ hello }}
{% set dict={'zhangsan': '26', 'lisi': '25'} %}
{% for key, value in dict.iteritems() %}
    {{key}} -> {{value}}
{% endfor %}
```

管理Nginx配置文件
```
# cat main.yml 
---
- hosts: webservers
  gather_facts: no
  vars:
    http_port: 80
    server_name: www.ctnrs.com
 
  tasks:
    - name: Copy nginx configuration file 
      template: src=site.conf.j2 dest=/etc/nginx/conf.d/www.ctnrs.com.conf
      notify: reload nginx
 
  handlers:
    - name: reload nginx
      service: name=nginx state=reloaded
 
# cat site.conf.j2 
{% set list=[10, 12, 13, 25, 31] %}
upstream {{server_name}} {
    {% for i in list %}
       server 192.168.1.{{i}}:80;
    {% endfor %}
}
server {
    listen       {{ http_port }};
    server_name  {{ server_name }};
 
    location / {
        proxy_pass http://{{server_name}};
    } 
}
```

16)roles
---
Roles目录结构
```
site.yml 
webservers.yml   
fooservers.yml   
roles/ 
   common/ 
     tasks/ 
     handlers/ 
     files/ 
     templates/ 
     vars/ 
     defaults/ 
     meta/ 
   webservers/ 
     tasks/ 
     defaults/ 
     meta/
```
-	tasks - 包含角色要执行的主要任务列表
-	handlers - 包含角色使用的处理程序
-	defaults - 角色默认的变量
-	vars - 角色其他的变量
-	files - 角色部署时用到的文件
-	templates - 角色部署时用到的模板
-	meta - 角色定义的一些元数据

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

include & import 区别
---
include*（动态）：在运行时导入
-	--list-tags，--list-tasks不会显示到输出
-	不能使用notify触发来自include*内处理程序名称（handlers）

import*（静态）：在Playbook解析时预先导入
-	不能与循环一起使用
-	将变量用于目标文件或角色名称时，不能使用inventory（主机/主机组等）中的变量

1.import
```
# cat main.yml
---
- import_playbook: webservers.yml
- import_playbook: databases.yml

# cat webservers.yml
---
- hosts: webservers
  tasks:
    - debug: msg="test webserver"


# cat database.yml
---
- hosts: webservers
  tasks:
    - debug: msg="test database"
```

2.include
```
# cat main.yml
---
- hosts: webservers
  gather_facts: no
  tasks:
  - include_tasks: task1.yml
    vars:
      user: zhangsan
  - import_tasks: task2.yml
    vars:
      user: lisi

# cat task1.yml
---
- name: task1
  debug: msg="hello {{user}}"

# cat task2.yml
---
- name: task2
  debug: msg="hello {{user}}"
```

自动部署Nginx
```
- hosts: webservers
  vars:
    hello: Ansible
 
  tasks:
  - name: Add repo 
    yum_repository:
      name: nginx
      description: nginx repo
      baseurl: http://nginx.org/packages/centos/7/$basearch/
      gpgcheck: no
      enabled: 1
  - name: Install nginx
    yum:
      name: nginx
      state: latest
  - name: Copy nginx configuration file
    copy:
      src: ./site.conf
      dest: /etc/nginx/conf.d/site.conf
  - name: Start nginx
    service:
      name: nginx
      state: started
  - name: Create wwwroot directory
    file:
      dest: /var/www/html
      state: directory
  - name: Create test page index.html
    shell: echo "hello {{hello}}" > /var/www/html/index.html


# site.conf
server {
    listen 80;
    server_name www.ctnrs.com;
    location / {
        root   /var/www/html;
        index  index.html;
    }
}
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
      get_url: url=http://mirrors.hust.edu.cn/apache/tomcat/tomcat-8/v{{ tomcat_version }}/bin/apache-tomcat-{{ tomcat_version }}.tar.gz dest=/tmp
 
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
