# 通过inventory配置文件生成houst

## 1、配置inventory文件
```
node01 ansible_host=192.168.101.69
node02 ansible_host=192.168.101.70 ip=127.0.0.1
node03 ansible_host=192.168.101.71 ip=127.0.0.1 access_ip=8.8.8.8

[node]
node01

[dbserver]
node02

[webserver]
node03
```

## 2、编写剧本
```
- hosts: node
  tasks:

  - name: "hosts | Populate localhost ipv4 into hosts file"
    lineinfile:
      dest: /etc/hosts
      line: "127.0.0.1 localhost localhost.localdomain"
      regexp: '^127.0.0.1.*$'
      state: present
      backup: yes
    tags: hosts

  - name: "hosts | Populate inventory into hosts file"
    blockinfile:
      dest: /etc/hosts
      block: |-
        {% for node in (groups['node'] + groups['webserver'] + groups['dbserver'] |default([]))|unique -%} {{ hostvars[node]['access_ip'] | default(hostvars[node]['ip'] | default(hostvars[node]['ansible_host']))  }} {{ node  }} {{ node  }}.localdomain
        {% endfor %}
      state: present
      create: yes
      backup: yes
      marker: "# Ansible inventory hosts {mark}"
    delegate_to: "{{ item }}"
    with_items: "{{ groups['node'] }}"
    tags: hosts

  - name: "hosts | Populate extra hosts entry"
    lineinfile:
      dest: /etc/hosts
      line: "{{ item.ip }} {{ item.name }}"
      regexp: '^.*\s{{ item.name }}.*$'
      state: present
      backup: yes
    with_items: "{{ extra_hosts|default([]) }}"
    tags: hosts
```

## 3、查看生成后的文件
```
127.0.0.1 localhost localhost.localdomain
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
# Ansible inventory hosts BEGIN
192.168.101.69 node01 node01.localdomain
8.8.8.8 node03 node03.localdomain
127.0.0.1 node02 node02.localdomain
# Ansible inventory hosts END
```
