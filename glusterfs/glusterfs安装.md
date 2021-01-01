glusterfs安装
===
https://buildlogs.centos.org/centos/6/storage/x86_64/gluster-7/

1、每个节点分别安装并设置自启动  
``` 
# wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
# yum -y install centos-release-gluster
# yum -y install glusterfs-server
# systemctl enable glusterd
# systemctl start glusterd

#  netstat -tunlp | grep glus
	tcp        0      0 0.0.0.0:49152      0.0.0.0:*        LISTEN      4633/gluterfsd     
	tcp        0      0 0.0.0.0:24007      0.0.0.0:*        LISTEN      3341/gluterd   
```  

2、配置hosts文件  
```
# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.101.69 node01
192.168.101.70 node02
192.168.101.71 node03
```  

3、在任一节点上适用glusterfs peer probe命令"发现"其他节点，组件集群  
```
# gluster peer probe node02
# gluster peer probe node03
```  

4、通过节点状态命令gluster peer status 确认各节点已经加入统一可信池中  
```
# gluster peer status
Number of Peers: 2

Hostname: node02
Uuid: c5e929e5-3b42-4d07-b1d1-510f10a62b03
State: Peer in Cluster (Connected)

Hostname: node03
Uuid: 948018c8-988b-4f77-9d12-629d0f630110
State: Peer in Cluster (Connected)


# gluster volume info
```  

5、使用方法  
1)每台机器上以/gluster/gv0目录各创建一个brick  
``` # mkdir -p /gluster/gv0 ```  

2)以其中3台机器的brick创建一个有3复本的逻辑卷gv0  
``` # gluster volume create gv0 replica 3 node01:/gluster/gv0 node02:/gluster/gv0 node03:/gluster force ```  

3)启用volume  
``` # gluster volume start gv0 ```  

4)client挂载gv0卷到/mnt/glusterfs目录并使用  
```
# mkdir /opt/glusterfs
# mount -t glusterfs node01:/gv0 /opt/glusterfs/
```  

5)从GlusterFS卷gv0移除某一brick  
```
# gluster volume remove-brick gv0 replica 2 node01:/gluster/gv0 force
删除GlusterFS卷gv0
    需要先stop卷：
    # gluster volume stop gv0
    再删：
    # gluster volume delete gv0
```  

相关命令  
```
#删除卷
gluster volume stop gfs01
gluster volume delete gfs01
#将机器移出集群
gluster peer detach 192.168.1.100
#只允许172.28.0.0的网络访问glusterfs
gluster volume set gfs01 auth.allow 172.28.26.*
gluster volume set gfs01 auth.allow 192.168.222.1,192.168.*.*
#加入新的机器并添加到卷里(由于副本数设置为2,至少要添加2（4、6、8..）台机器)
gluster peer probe 192.168.222.134
gluster peer probe 192.168.222.135
#新加卷
gluster volume add-brick gfs01 repl 2 192.168.222.134:/data/gluster 192.168.222.135:/data/gluster force
#删除卷
gluster volume remove-brick gfs01 repl 2 192.168.222.134:/opt/gfs 192.168.222.135:/opt/gfs start
gluster volume remove-brick gfs01 repl 2 192.168.222.134:/opt/gfs 192.168.222.135:/opt/gfs status
gluster volume remove-brick gfs01 repl 2 192.168.222.134:/opt/gfs 192.168.222.135:/opt/gfs commit
注意：扩展或收缩卷时，也要按照卷的类型，加入或减少的brick个数必须满足相应的要求。
#当对卷进行了扩展或收缩后，需要对卷的数据进行重新均衡。
gluster volume rebalance mamm-volume start|stop|status
###########################################################
迁移卷---主要完成数据在卷之间的在线迁移
#启动迁移过程
gluster volume replace-brick gfs01 192.168.222.134:/opt/gfs 192.168.222.134:/opt/test start force
#查看迁移状态
gluster volume replace-brick gfs01 192.168.222.134:/opt/gfs 192.168.222.134:/opt/test status
#迁移完成后提交完成
gluster volume replace-brick gfs01 192.168.222.134:/opt/gfs 192.168.222.134:/opt/test commit
#机器出现故障,执行强制提交
gluster volume replace-brick gfs01 192.168.222.134:/opt/gfs 192.168.222.134:/opt/test commit force
###########################################################
触发副本自愈
gluster volume heal mamm-volume #只修复有问题的文件
gluster volume heal mamm-volume full #修复所有文件
gluster volume heal mamm-volume info #查看自愈详情
#####################################################
data-self-heal, metadata-self-heal and entry-self-heal
启用或禁用文件内容、文件元数据和目录项的自我修复功能，默认情况下三个全部是“on”。
#将其中的一个设置为off的范例：
gluster volume set gfs01 entry-self-heal off
```  

通过Heketi提供的restapi使用(kubernetes storageClass需要配置)
===
1、安装  
``` # yum -y install heketi heketi-client ```  


2、配置Heketi使用户能够基于ssh秘钥的认证方式连接至GluserFS集群中的各节点，并拥有相应的管理权限  
```
# ssh-keygen -f /etc/heketi/heketi_key -t rsa -N ''
# chown heketi:heketi /etc/heketi/heketi_key*
# for host in node01 node02 node03 ; do \
  ssh-copy-id -i /etc/heketi/heketi_key.pub root@${host};done
```  

3、定义服务监听的端口、认证及连接cluster存储集群的方式  
```
# cat /etc/heketi/heketi.json
{
  "_port_comment": "Heketi Server Port Number",
  "port": "8080",                                                #配置端口号

  "_use_auth": "Enable JWT authorization. Please enable for deployment",
  "use_auth": false,

  "_jwt": "Private keys for access",
  "jwt": {
    "_admin": "Admin has access to all APIs",
    "admin": {
      "key": "123456"                                   #密码
    },
    "_user": "User only has access to /volumes endpoint",
    "user": {
      "key": "123456"                                   #密码
    }
  },

  "_glusterfs_comment": "GlusterFS Configuration",
  "glusterfs": {
    "_executor_comment": [
      "Execute plugin. Possible choices: mock, ssh",
      "mock: This setting is used for testing and development.",
      "      It will not send commands to any node.",
      "ssh:  This setting will notify Heketi to ssh to the nodes.",
      "      It will need the values in sshexec to be configured.",
      "kubernetes: Communicate with GlusterFS containers over",
      "            Kubernetes exec api."
    ],
    "executor": "ssh",                               #修改成ssh

    "_sshexec_comment": "SSH username and private key file information",
    "sshexec": {
      "keyfile": "/etc/heketi/heketi_key",           #key路径
      "user": "root",                                #用户
      "port": "22",                                  #端口
      "fstab": "/etc/fstab"                          #fstab路径
    },

    "_kubeexec_comment": "Kubernetes configuration",
    "kubeexec": {
      "host" :"https://kubernetes.host:8443",
      "cert" : "/path/to/crt.file",
      "insecure": false,
      "user": "kubernetes username",
      "password": "password for kubernetes user",
      "namespace": "OpenShift project or Kubernetes namespace",
      "fstab": "Optional: Specify fstab file on node.  Default is /etc/fstab"
    },

    "_db_comment": "Database file name",
    "db": "/var/lib/heketi/heketi.db",

    "_loglevel_comment": [
      "Set log level. Choices are:",
      "  none, critical, error, warning, info, debug",
      "Default is warning"
    ],
    "loglevel" : "debug"
  }
}
```  

4、启动服务  
```
# systemctl enable heketi
# systemctl restart heketi
```  

5、检查服务  
```
curl http://localhost:8080/hello
```  

6、使用方法  
1)创建集群  
``` # heketi-cli --server http://192.168.101.69:8080 --user admin --json=true ```  

2）查看集群  
``` #heketi-cli --server http://192.168.101.69:8080 --user admin --secret 123456 cluster list ```  

3）依次将3个节点作为node添加到cluster  
```
# heketi-cli --server http://192.168.101.69:8080 --user admin --secret 123456 --json=true node add --cluster="0e2d27e7c9bb91801d850474e89fe11b" --management-host-name=192.168.101.69 --stopage-host-name=192.168.101.69 --zone=1
```  
- 对接k8s的话，上边这个必须management-host-name要用ip地址，不可以用域名  

4)每台设备node上各添加一块裸硬盘/dev/sdc(没创建过任何分区)，创建device  
```
# heketi-cli --server http://10.142.21.23:30088 --user admin --secret 123456 --json=true device add --name="/dev/sdc" --node="0e2d27e7c9bb91801d850474e89fe11b"
```  

5)以上步骤可以通过json文件配置  
```
# vim /etc/heketi/topology.json
{
  "clusters": [
    {
      "nodes": [
        {
          "node": {
            "hostnames": {
              "manage": [
                "192.168.101.69"
              ],
              "storage": [
                "192.168.101.69"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/sdc"
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "192.168.101.70"
              ],
              "storage": [
                "192.168.101.70"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/sdc"
          ]
        },
        {
          "node": {
            "hostnames": {
              "manage": [
                "192.168.101.71"
              ],
              "storage": [
                "192.168.101.71"
              ]
            },
            "zone": 1
          },
          "devices": [
            "/dev/sdc"
          ]
        }
      ]
    }
  ]
}
```  

将该文件发送给heketi创建下面提供三种方式  
```
以systemd起heketi:
# heketi-cli --server http://192.168.101.69:8080 --user admin --secret 123456 topology load --json=/etc/heketi/topology.json


以容器起heketi&heketi-cli:
    docker cp topology.json 容器ID:/etc/heketi/
    docker exec 容器ID heketi-cli --server http://192.168.101.69:8080 --user admin --secret 123456 topology load --json=/etc/heketi/topology.json


以k8s方式起heketi&heketi-cli:
    kubectl cp topology.json heketi-67d99d8bb6-bzsvx:/etc/heketi/ -n kube-system
    kubectl exec -it heketi-67d99d8bb6-bzsvx -n kube-system heketi-cli topology load -- --json=/etc/heketi/topology.json --server http://192.168.101.69:8080 --user admin --secret 123456
```  

创建volume  
```
# heketi-cli --server http://192.168.101.69:8080 --user admin --secret 123456 volume create --size=100 --replica=3 --clusters=0e2d27e7c9bb91801d850474e89fe11b
```  

删除volume  
```
# heketi-cli --server http://192.168.101.69:8080 --user admin --secret 123456 volume delete --clusters=0e2d27e7c9bb91801d850474e89fe11b
```  

查看信息
```
# gluster volume info
# heketi-cli --server http://192.168.101.69:8080 --user admin --secret 123456 topology info
```  
