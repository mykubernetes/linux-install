
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

配置代理服务器  
```
# vim amoeba.xml
 <proxy>

                <!-- service class must implements com.meidusa.amoeba.service.Service -->
                <service name="Amoeba for Mysql" class="com.meidusa.amoeba.net.ServerableConnectionManager">
                        <!-- Amoeba 端口号 ，客户端client 链接amoeba端口号，不能和主从数据库 冲突-->
                        <property name="port">8066</property>

                        <!-- bind ipAddress -->
                        <!--
                        <property name="ipAddress">127.0.0.1</property>
                         -->

                        <property name="manager">${clientConnectioneManager}</property>

                        <property name="connectionFactory">
                                <bean class="com.meidusa.amoeba.mysql.net.MysqlClientConnectionFactory">
                                        <property name="sendBufferSize">128</property>
                                        <property name="receiveBufferSize">64</property>
                                </bean>
                        </property>

                        <property name="authenticator">
                                <bean class="com.meidusa.amoeba.mysql.server.MysqlClientAuthenticator">
                                        <!-- Amoeba 账号 ，客户端client 链接amoeba端 账号-->
                                        <property name="user">root</property>
 <!-- Amoeba 账号 ，客户端client 链接amoeba端 密码-->
                                        <property name="password">root</property>

                                        <property name="filter">
                                                <bean class="com.meidusa.amoeba.server.IPAccessController">
                                                        <property name="ipFile">${amoeba.home}/conf/access_list.conf</property>
                                                </bean>
                                        </property>
                                </bean>
                        </property>

                </service>

                <!-- server class must implements com.meidusa.amoeba.service.Service -->
                <service name="Amoeba Monitor Server" class="com.meidusa.amoeba.monitor.MonitorServer">
                        <!-- port -->
                        <!--  default value: random number
                        <property name="port">9066</property>
                        -->
                        <!-- bind ipAddress -->
                        <property name="ipAddress">127.0.0.1</property>
                        <property name="daemon">true</property>
                        <property name="manager">${clientConnectioneManager}</property>
                        <property name="connectionFactory">
                                <bean class="com.meidusa.amoeba.monitor.net.MonitorClientConnectionFactory"></bean>
                        </property>

                </service>

                <runtime class="com.meidusa.amoeba.mysql.context.MysqlRuntimeContext">
                        <!-- proxy server net IO Read thread size -->
                        <property name="readThreadPoolSize">20</property>

                        <!-- proxy server client process thread size -->
                        <property name="clientSideThreadPoolSize">30</property>

                        <!-- mysql server data packet process thread size -->
                        <property name="serverSideThreadPoolSize">30</property>

                        <!-- per connection cache prepared statement size  -->
                        <property name="statementCacheSize">500</property>

                        <!-- query timeout( default: 60 second , TimeUnit:second) -->
                        <property name="queryTimeout">60</property>
                </runtime>

        </proxy>

        <!--
                Each ConnectionManager will start as thread
                manager responsible for the Connection IO read , Death Detection
        -->
        <connectionManagerList>
                <connectionManager name="clientConnectioneManager" class="com.meidusa.amoeba.net.MultiConnectionManagerWrapper">
                        <property name="subManagerClassName">com.meidusa.amoeba.net.ConnectionManager</property>
                        <!--
                          default value is avaliable Processors
                        <property name="processors">5</property>
                         -->
                </connectionManager>
                <connectionManager name="defaultManager" class="com.meidusa.amoeba.net.MultiConnectionManagerWrapper">
                        <property name="subManagerClassName">com.meidusa.amoeba.net.AuthingableConnectionManager</property>

                        <!--
                          default value is avaliable Processors
                        <property name="processors">5</property>
                         -->
                </connectionManager>
        </connectionManagerList>

                <!-- default using file loader -->
        <dbServerLoader class="com.meidusa.amoeba.context.DBServerConfigFileLoader">
                <property name="configFile">${amoeba.home}/conf/dbServers.xml</property>
        </dbServerLoader>

        <queryRouter class="com.meidusa.amoeba.mysql.parser.MysqlQueryRouter">
                <property name="ruleLoader">
                        <bean class="com.meidusa.amoeba.route.TableRuleFileLoader">
                                <property name="ruleFile">${amoeba.home}/conf/rule.xml</property>
                                <property name="functionFile">${amoeba.home}/conf/ruleFunctionMap.xml</property>
                        </bean>
                </property>
                <property name="sqlFunctionFile">${amoeba.home}/conf/functionMap.xml</property>
                <property name="LRUMapSize">1500</property>

                <!-- 默认数据库，主数据库 -->
                <property name="defaultPool">master</property>

                <!-- 写数据库 -->
                <property name="writePool">master</property>
                <!-- 读数据库，dbServer.xml 中配置的 虚拟数据库，数据库池 -->
                <property name="readPool">slaves</property>

                <property name="needParse">true</property>
        </queryRouter>
```  
