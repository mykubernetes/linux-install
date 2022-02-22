```
[20:57:03 root@jenkins jenkins]#cat web1.sh 
#!/bin/bash
DATE=`date +"%Y-%m-%d_%H-%M-%S"`
GROUP="$1"
BRANCH="$2"

IP_list(){
if [ ${GROUP} == "GROUP1" ];then
    HOST_IP='192.168.10.183'
    echo "${HOST_IP}"
elif [ ${GROUP} == "GROUP2" ];then
    HOST_IP='192.168.10.184'
    echo "${HOST_IP}"
elif [ ${GROUP} == "GROUP3" ];then
    HOST_IP='192.168.10.183 192.168.10.184'
    echo "${HOST_IP}"
fi
}

clone_code(){
echo "即将开始从clone ${BRANCH}分支代码"
cd /data/jenkins/git && rm -rf * &&  git clone -b ${BRANCH} git@192.168.10.185:root/web1.git && mv web1 web1-${DATE} && tar zcf web1-${DATE}.tar.gz web1-${DATE}
echo "${BRANCH}分支代码打包完成"
}

scanner_code(){
cd /data/jenkins/git/web1-${DATE} && /usr/local/src/sonar-scanner/bin/sonar-scanner
echo "代码扫描完成，请打开sonarqube查看扫描结果"
}

scp_tar(){
for IP in ${HOST_IP};do
    scp /data/jenkins/git/web1-${DATE}.tar.gz ${IP}:/data/tomcat/appstar
    ssh ${IP} "tar xf /data/tomcat/appstar/web1-${DATE}.tar.gz -C /data/tomcat/apps/"
done
echo "代码分发完成"
}

down_node(){
for IP in ${HOST_IP};do
    ssh 192.168.10.182 'echo "disable server web1/'${IP}'" | socat stdio /var/lib/haproxy/haproxy.sock'
    echo "$IP从负载均衡192.168.10.182下线成功"
done
}

stop_tomcat(){
for IP in ${HOST_IP};do                                                         
    ssh ${IP} "systemctl stop tomcat.service"
    echo "${IP}节点tomcat已经停止"
done
}

code_deployment(){
for IP in ${HOST_IP};do                                                         
    ssh ${IP} "rm -rf /usr/local/tomcat/webapps/*"
    ssh ${IP} "ln -sf /data/tomcat/apps/web1-${DATE} /usr/local/tomcat/webapps/web1"
    echo "${IP}节点代码部署完成"
done
}
start_tomcat(){
for IP in ${HOST_IP};do  
    ssh ${IP} "systemctl start tomcat.service"
    echo "${IP}节点tomcat已经启动"
done
}

web_test(){ 
echo "正在测试后端服务器是否可用..."
sleep 10
for IP in ${HOST_IP};do
    NUM=`curl -s  -I -m 10 -o /dev/null  -w %{http_code}  http://${IP}:8080/web1/index.html`
    if [[ ${NUM} -eq 200 ]];then
       echo "${node} web URL 测试通过,即将添加到负载"
       ssh 192.168.10.182 'echo "enable server web1/'${IP}'" | socat stdio /var/lib/haproxy/haproxy.sock'
    else
       echo "${node} 测试失败,请检查该服务器是否成功启动tomcat"
    fi
done
}


rollback_last_version(){
for IP in ${HOST_IP};do
    echo $IP
    NOW_VERSION=`ssh ${IP} ""/bin/ls -l  -rt /usr/local/tomcat/webapps/ | awk -F"->" '{print $2}'  | tail -n1""`
    NOW_VERSION=`basename ${NOW_VERSION}`
    echo $NOW_VERSION,"NOW_VERSION"
    NAME=`ssh  ${IP}  ""ls  -d -l  -rt  /data/tomcat/apps/* | grep -B 1 ${NOW_VERSION} | head -n1 | awk '{print $9}'""`
    echo $NAME,""NAME
    ssh ${IP} "rm -rf /usr/local/tomcat/webapps/*  && ln -sv  ${NAME} /usr/local/tomcat/webapps/web1"
    echo "${IP}节点代码回滚完成"
done 
}
delete_history_version(){
for IP in ${HOST_IP};do
    ssh ${IP} 'rm -rf /data/tomcat/appstar/*'
    NUM=`ssh ${IP} "ls -rt -d /data/tomcat/apps/* | wc -l"`
    if [ ${NUM} -gt 5 ];then
        NAME=`ssh ${IP} ""ls -l -rt -d /data/tomcat/apps/* | awk '{print $9}' | head -n1""`
        ssh ${IP} "rm -rf ${NAME}"
        echo "${IP}节点的旧版本代码已经删除"
    fi
done
}
main(){
  case $1 in
    deploy)
      IP_list
      clone_code
      scanner_code
      scp_tar
      down_node
      stop_tomcat
      code_deployment
      start_tomcat
      web_test
      delete_history_version
    ;;
    rollback_last_version)
      IP_list
      down_node
      stop_tomcat
      rollback_last_version
      start_tomcat
      web_test
    ;;
  esac
}
main $3
```

说明：代码分支选择与升级主机选择全部都由传递的位置变量决定，需要在jenkins中根据自己实际需求进行修改，$3位置变量控制代码的升级还是回滚。

本脚本只提供参考，请根据自己实际环境进行配置。
