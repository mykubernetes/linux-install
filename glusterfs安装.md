glusterfs安装
===
1、每个节点分别安装并设置自启动  
``` 
# wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
# yum -y install centos-release-gluster
# yum -y install glusterfs-server
# systemctl enable glusterd
# systemctl start glusterd
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

通过Heketi提供的restapi使用
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

将该文件发送给heketi创建  
```
# heketi-cli --server http://192.168.101.69:8080 --user admin --secret 123456 topology load --json=/etc/heketi/topology.json
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
