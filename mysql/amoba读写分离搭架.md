
一、安装java环境  
```
# tar -zxf /opt/softwares/jdk-8u121-linux-x64.gz -C /opt/modules/
# vi /etc/profile
#JAVA_HOME
export JAVA_HOME=/opt/modules/jdk1.8.0_121
export PATH=$PATH:$JAVA_HOME/bin
```  

二、安装amoba
```
wget http://nchc.dl.sourceforge.net/project/amoeba/Amoeba%20for%20mysql/2.x/amoeba-mysql-binary-2.1.0-RC5.tar.gz
# mkdir amoeba
# tar xvf amoeba-mysql-binary-2.1.0-RC5.tar.gz -C amoeba
```  

三、配置  
```
# vim dbServers.xml
 <!-- 数据库连接配置的公共部分 -->
        <dbServer name="abstractServer" abstractive="true">
                <factoryConfig class="com.meidusa.amoeba.mysql.net.MysqlServerConnectionFactory">
                        <property name="manager">${defaultManager}</property>
                        <property name="sendBufferSize">64</property>
                        <property name="receiveBufferSize">128</property>

                        <!-- mysql port 端口号 -->
                        <property name="port">3306</property>

                        <!-- mysql schema amoeba 访问主从数据库真实库-->
                        <property name="schema">test</property>

                        <!-- mysql user 主从数据库分配给Amoeba访问数据的用户名 -->
                        <property name="user">proxyuser</property>

                        <!--  mysql password 主从数据库分配给Amoeba访问数据的密码-->
                        <property name="password">123456</property>

                </factoryConfig>

                <poolConfig class="com.meidusa.amoeba.net.poolable.PoolableObjectPool">
                        <property name="maxActive">500</property>
                        <property name="maxIdle">500</property>
                        <property name="minIdle">10</property>
                        <property name="minEvictableIdleTimeMillis">600000</property>
                        <property name="timeBetweenEvictionRunsMillis">600000</property>
                        <property name="testOnBorrow">true</property>
                        <property name="testWhileIdle">true</property>
                </poolConfig>
        </dbServer>


        <!-- Master 的独立部分，也就只有 IP 了这里 写了主机名 -->
        <dbServer name="master"  parent="abstractServer">
                <factoryConfig>
                        <!-- mysql ip -->
                        <property name="ipAddress">192.168.101.69</property>
                </factoryConfig>
        </dbServer>
        <!-- Slave 的独立部分，也就只有 IP 了这里 写了主机名 ,如果有多个Slave服务器，可以配置多个dbServer -->
        <dbServer name="slave"  parent="abstractServer">
                <factoryConfig>
                        <!-- mysql ip -->
                        <property name="ipAddress">192.168.101.70</property>
                </factoryConfig>
        </dbServer>

        <!-- 数据库池，虚拟服务器，实现读取的负载均衡，如果有多个Slave，则<property name="poolNames">slave1,slave2</property>用逗号隔开 -->
        <dbServer name="slaves" virtual="true">
                <poolConfig class="com.meidusa.amoeba.server.MultipleServerPool">
                        <!-- Load balancing strategy: 1=ROUNDROBIN , 2=WEIGHTBASED , 3=HA-->
                        <property name="loadbalance">1</property>

                        <!-- Separated by commas,such as: server1,server2,server1 -->
                        <property name="poolNames">slave</property>
                </poolConfig>
        </dbServer>
```  
