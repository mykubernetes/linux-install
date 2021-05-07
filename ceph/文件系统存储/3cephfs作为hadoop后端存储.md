1、安装cephfs的java接口  
``` # yum install cephfs-java libcephfs1-devel python-cephfs libcephfs_jni1-devel ```  

2、下载hadoop  
``` # wget -c http://mirrors.aliyun.com/apache/hadoop/common/hadoop-2.6.5/hadoop-2.6.5.tar.gz ```  

3、解压hadoop  
``` # tar xf hadoop-2.6.3.tar.gz && cd hadoop-2.6.3 ```  

4、配置libcephfs_jni动态链接库  
```
# cd lib/native
# ln -s /usr/lib64/libcephfs_jni.so .
# cd ../../
```  

5、下载hadoop-cephfs.jar  
``` # wget -c http://download.ceph.com/tarballs/hadoop-cephfs.jar ```  

6、放置到系统java库路径  
``` # cp hadoop-cephfs.jar /usr/share/java/ ```  

7、修改hadoop的运行环境文件  
```
# vim etc/hadoop/hadoop-env.sh

export HADOOP_CLASSPATH=/usr/share/java/libcephfs.jar:/usr/share/java/hadoop-cephfs.jar:$HADOOP_CLASSPATH
```  

8、修改hadoop核心配置文件  
```
vim etc/hadoop/core-site.xml
<configuration>
<property>
<name>hadoop.tmp.dir</name>
<value>/tmp/hadoop/</value>
</property>
<property>
<name>fs.default.name</name>
<value>ceph://10.89.13.71/</value>
</property>
<property>
<name>ceph.conf.file</name>              <!--载入ceph配置文件-->
<value>/etc/ceph/ceph.conf</value>
</property>
<property>
<name>ceph.auth.id</name>                <!--设定ceph集群访问认证用户-->
<value>admin</value>
</property>
<property>
<name>ceph.auth.keyring</name>                         <!--设定ceph集群admin用户的认证秘钥-->
<value>/etc/ceph/ceph.client.admin.keyring</value>
</property>
<property>
<name>ceph.data.pools</name>                  <!--设定ceph集群默认存储池，hadoop1-->
<value>hadoop1</value>
</property>
<property>
<name>fs.ceph.impl</name>                     <!--设定ceph集群访问文件接口-->
<value>org.apache.hadoop.fs.ceph.CephFileSystem</value>
</property>
</configuration>
```  

9、创建cephfs 存储池，供hadoop使用  
```
# ceph osd pool create hadoop1 128
pool 'hadoop1' created
# ceph osd pool set hadoop1 size 3
set pool 26 size to 3
# ceph osd pool set hadoop1 min_size 2
set pool 26 min_size to 2
# ceph mds add_data_pool hadoop1
added data pool 26 to mdsmap
```  

上述配置完成后，即可启动hadoop集群。通过haddop的dfs命令，访问cephfs集群文件。通过hadoop集群命令，可检验访问cephfs存储能力  


10、通过hadoop命令列出当前cephfs存储文件的目录内容  
```
# bin/hadoop dfs -ls /
DEPRECATED: Use of this script to execute hdfs command is deprecated.
Instead use the hdfs command for it.
Found 0 items
```  

11、通过hadoop命令将文件导入cephfs存储的文件目录  
```
# ./bin/hadoop dfs -put ~/ceph/ceph-0.94.5.tar.bz2 /ceph-0.94.5.tar.bz2
DEPRECATED: Use of this script to execute hdfs command is deprecated.
Instead use the hdfs command for it.
```  
再次查看cephfs 存储的文件目录，发现文件已经导入  
```
# ./bin/hadoop dfs -ls /
DEPRECATED: Use of this script to execute hdfs command is deprecated.
Instead use the hdfs command for it.
Found 1 items
-rw-r--r-- 3 root 7084809 2018-01-01 16:34 /ceph-0.94.5.tar.bz2
```  










