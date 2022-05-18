# 一、Jenkins插件下载慢的解决办法(使用nginx反向代理)

即使更换清华源的update-center.json，依然很卡，那是因为清华源也是指向了官方地址。

最好的办法就是使用nginx代理updates.jenkins-ci.org

步骤分为两步:
- 将updates.jenkins.io映射到本地环回地址127.0.0.1
- 使用nginx代理updates.jenkins.io的镜像网站到清华源

第一步：将updates.jenkins.io映射到本地环回地址

查看域名路径 https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json 查看url的域名填写到host文件
```
vim  /etc/hosts
127.0.0.1 updates.jenkins.io
```
- 这样所有的请求就映射到了本地的环回地址127.0.0.1


第二步：将请求映射到镜像网站
```
vim /etc/nginx/conf.d/default.conf                //添加以下代码
location /download/plugins
{
    proxy_next_upstream http_502 http_504 error timeout invalid_header;
    proxy_set_header Host mirrors.tuna.tsinghua.edu.cn;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    rewrite /download/plugins(.*) /jenkins/plugins/$1 break;
    proxy_pass https://mirrors.tuna.tsinghua.edu.cn;
}
```


完整nginx配置
```
  server {
     listen       80;
     server_name  updates.jenkins.io ;
 
        location /download/plugins
        {
                proxy_next_upstream http_502 http_504 error timeout invalid_header;
                proxy_set_header Host mirrors.tuna.tsinghua.edu.cn;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                rewrite /download/plugins(.*) /jenkins/plugins/$1 break;
                proxy_pass https://mirrors.tuna.tsinghua.edu.cn;
        }
 }
```

# 如果现实jenkins已离线，将一下文件中的更新检查地址改成国内清华大学地址，然后重启jenkins即可：
- https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json

```
# cat /var/lib/jenkins/hudson.model.UpdateCenter.xml
<?xml version='1.1' encoding='UTF-8'?>
<sites>
    <site>
        <id>default</id>
        <url> https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json </url>
    </site>
</sites>
```

# pipline

## 语法
- Stage:阶段，一个pipline可以划分为若干个stage,每个stage都是一个操作步骤，比如clone代码、代码编译、代码测试和代码部署，阶段是一个逻辑分组，可以跨多个node执行。
- Node:节点，每个node都是一个jenkins节点，可以是jenkins master也可以是 jenkins agent，node是执行step具体服务器。
- Step:步骤，step是jenkins pipline最基本的操作单元，从在服务器创建目录到构建容器镜像，由各类jenkins插件提供实现，一个stage中可以又多个step，例如：sh "make"

1、通过shell构建工程（tomcat容器运行），代码在gitlab上托管
```
#!/bin/bash
#进入到项目的克隆路径下，将上一次的工程删掉（devops工程路径）
cd /data/git/magedu && rm -rf devops
#从gitlab上克隆项目，并且进入到devops工程中，并且达成tar包
git clone git@172.31.3.101:magedu/devops.git && cd devops && tar czvf devops.tar.gz ./
 
#停止web服务
ssh magedu@172.31.3.105 "/etc/init.d/tomcat stop"
ssh magedu@172.31.3.106 "/etc/init.d/tomcat stop"
 
#分发代码
scp devops.tar.gz magedu@172.31.3.105:/data/tomcat/tomcat_webapps/
scp devops.tar.gz magedu@172.31.3.106:/data/tomcat/tomcat_webapps/
 
#代码替换
ssh magedu@172.31.3.105 "cd /data/tomcat/tomcat_webapps/ && rm -rf devops/* && tar xvf devops.tar.gz  -C devops/ && rm -rf devops.tar.gz"
ssh magedu@172.31.3.106 "cd /data/tomcat/tomcat_webapps/ && rm -rf devops/* && tar xvf devops.tar.gz  -C devops/ && rm -rf devops.tar.gz"
 
#启动web服务
ssh magedu@172.31.3.105 "/etc/init.d/tomcat start"
ssh magedu@172.31.3.106 "/etc/init.d/tomcat start"
```

2、通过pipline构建工程--脚本式
```
node("jenkins-slave1") {             //运行的slave节点，不知道则运行在master节点
    stage("clone 代码"){
      sh "cd /var/lib/jenkins/workspace/pipline-linux40-app1-develop && rm -rf ./*"
      git branch: 'develop', credentialsId: '0792719f-b4fe-412a-a511-e8ecf60dd760', url: 'git@172.31.0.101:magedu/app1.git'
      echo "代码 clone完成"
    }
    stage("代码构建"){
      sh "cd /var/lib/jenkins/workspace/pipline-linux40-app1-develop && tar czvf linux40.tar.gz ./*"
    }
   stage("停止服务"){
      sh 'ssh www@172.31.0.106 "/etc/init.d/tomcat stop && rm -rf /data/tomcat/tomcat_webapps/linux40/*"'
      sh 'ssh www@172.31.0.107 "/etc/init.d/tomcat stop && rm -rf /data/tomcat/tomcat_webapps/linux40/*"'
   }
   
    stage("代码copy"){
      sh "cd /var/lib/jenkins/workspace/pipline-linux40-app1-develop && scp linux40.tar.gz  www@172.31.0.106:/data/tomcat/tomcat_appdir/"
      sh "cd /var/lib/jenkins/workspace/pipline-linux40-app1-develop && scp linux40.tar.gz  www@172.31.0.107:/data/tomcat/tomcat_appdir/"
    }
	
	
   stage("代码部署"){
     sh 'ssh www@172.31.0.106 "cd  /data/tomcat/tomcat_appdir/ && tar xvf linux40.tar.gz -C /data/tomcat/tomcat_webapps/linux40/"'
     sh 'ssh www@172.31.0.107 "cd  /data/tomcat/tomcat_appdir/ && tar xvf linux40.tar.gz -C /data/tomcat/tomcat_webapps/linux40/"'
   }
    stage("启动服务"){
     sh 'ssh www@172.31.0.106 "/etc/init.d/tomcat start"'
     sh 'ssh www@172.31.0.107 "/etc/init.d/tomcat start"'
   }
   
}
```

3、通过pipline构建工程--声明式（推荐使用）
```
pipeline{
    //agent any  //全局必须带有agent,表明此pipeline执行节点
    agent { label 'jenkins-node1' }
    stages{
        stage("代码clone"){
            //#agent { label 'master' }  //具体执行的步骤节点，非必须
            steps{
                sh "cd /var/lib/jenkins/workspace/pipline-test && rm -rf ./*"
                git branch: 'develop', credentialsId: '0792719f-b4fe-412a-a511-e8ecf60dd760', url: 'git@172.31.0.101:magedu/app1.git'
                echo "代码 clone完成"
            }
        }
        
        stage("代码构建"){
			steps{
				sh "cd /var/lib/jenkins/workspace/pipline-linux40-app1-develop && tar czvf linux40.tar.gz ./*"
			}
		}
		
	   stage("停止服务"){
			steps{
				sh 'ssh www@172.31.0.106 "/etc/init.d/tomcat stop && rm -rf /data/tomcat/tomcat_webapps/linux40/*"'
				sh 'ssh www@172.31.0.107 "/etc/init.d/tomcat stop && rm -rf /data/tomcat/tomcat_webapps/linux40/*"'
			}
		}
        
		stage("代码copy"){
			steps{
				sh "cd /var/lib/jenkins/workspace/pipline-linux40-app1-develop && scp linux40.tar.gz  www@172.31.0.106:/data/tomcat/tomcat_appdir/"
				sh "cd /var/lib/jenkins/workspace/pipline-linux40-app1-develop && scp linux40.tar.gz  www@172.31.0.107:/data/tomcat/tomcat_appdir/"
			}
		}
		
		stage("代码部署"){
			steps{
				sh 'ssh www@172.31.0.106 "cd  /data/tomcat/tomcat_appdir/ && tar xvf linux40.tar.gz -C /data/tomcat/tomcat_webapps/linux40/"'
				sh 'ssh www@172.31.0.107 "cd  /data/tomcat/tomcat_appdir/ && tar xvf linux40.tar.gz -C /data/tomcat/tomcat_webapps/linux40/"'
			}
		}
		
		
		stage("启动服务"){
			steps{
				sh 'ssh www@172.31.0.106 "/etc/init.d/tomcat start"'
				sh 'ssh www@172.31.0.107 "/etc/init.d/tomcat start"'
			}
		}
    }
}
```

4、生产案例
```
#!/bin/bash
DATE=`date +%Y-%m-%d_%H-%M-%S`
METHOD=$1
BRANCH=$2
GROUP_LIST=$3

function IP_list(){
  if [[ ${GROUP_LIST} == "GROUP1" ]];then
     Server_IP="172.31.5.105"
     echo ${Server_IP}
     ssh root@172.31.5.108 ""echo disable  server web_port/172.31.5.105" | socat stdio /var/lib/haproxy/haproxy.sock"
     ssh root@172.31.5.109 ""echo disable  server web_port/172.31.5.105" | socat stdio /var/lib/haproxy/haproxy.sock"
  elif [[ ${GROUP_LIST} == "GROUP2" ]];then
     Server_IP="172.31.5.106 172.31.5.107"
     echo ${Server_IP}
     ssh root@172.31.5.108 ""echo enable  server web_port/172.31.5.105" | socat stdio /var/lib/haproxy/haproxy.sock"
     ssh root@172.31.5.109 ""echo enable  server web_port/172.31.5.105" | socat stdio /var/lib/haproxy/haproxy.sock"
  elif [[ ${GROUP_LIST} == "GROUP3" ]];then
     Server_IP="172.31.5.105 172.31.5.106 172.31.5.107"
     echo ${Server_IP}
  fi
}

function clone_code(){
  echo "即将开始从clone ${BRANCH}分支的代码"
  cd /data/git/magedu && rm -rf web1 && git clone -b  ${BRANCH} git@172.31.5.101:magedu/web1.git
  echo "${BRANCH}分支代码cllone完成，即开始编译"
  #tar czvf myapp.tar.gz ./index.html
  #echo "代码编译完成，即将开始分发部署包"
}

function scanner_code(){
  cd /data/git/magedu/web1 && /apps/sonarscanner/bin/sonar-scanner
  echo "代码扫描完成,请打开sonarqube查看扫描结果"
}

function code_maven(){
  echo  "cd /data/git/magedu/web1 && mvn clean package -Dmaven.test.skip=true"
  echo "代码编译完成"
}


function make_zip(){
  cd /data/git/magedu/web1 && zip -r code.zip ./index.html
  echo "代码打包完成"
}



down_node(){
  for node in ${Server_IP};do
    ssh root@172.31.5.108 "echo "disable server  web_port/${node}" | socat stdio /var/lib/haproxy/haproxy.sock"
    echo "${node} 从负载均衡172.31.5.108下线成功"
    ssh root@172.31.5.109 "echo "disable server  web_port/${node}" | socat stdio /var/lib/haproxy/haproxy.sock"
    echo "${node} 从负载均衡172.31.5.109下线成功"
  done
}

function scp_zipfile(){
  for node in ${Server_IP};do
    scp /data/git/magedu/web1/code.zip  magedu@${node}:/data/tomcat/tomcat_appdir/code-${DATE}.zip
    ssh magedu@${node} "unzip /data/tomcat/tomcat_appdir/code-${DATE}.zip  -d /data/tomcat/tomcat_webdir/code-${DATE} && rm -rf  /data/tomcat/tomcat_webapps/myapp && ln -sv  /data/tomcat/tomcat_webdir/code-${DATE} /data/tomcat/tomcat_webapps/myapp"
  done
}

function stop_tomcat(){
  for node in ${Server_IP};do
    ssh magedu@${node}   "/etc/init.d/tomcat stop"
  done
}

function start_tomcat(){
  for node in ${Server_IP};do
    ssh magedu@${node}   "/etc/init.d/tomcat start"
    #sleep 5
  done
}

function web_test(){
  sleep 10
  for node in ${Server_IP};do
    NUM=`curl -s  -I -m 10 -o /dev/null  -w %{http_code}  http://${node}:8080/myapp/index.html`
    if [[ ${NUM} -eq 200 ]];then
       echo "${node} myapp URL 测试通过,即将添加到负载"
       add_node ${node}
    else
       echo "${node} 测试失败,请检查该服务器是否成功启动tomcat"
    fi
  done
}

function add_node(){
   node=$1
    echo ${node},"----->"
    if [[ ${GROUP_LIST} == "GROUP3" ]];then
      ssh root@172.31.5.108 ""echo enable  server web_port/172.31.5.105" | socat stdio /var/lib/haproxy/haproxy.sock"
      ssh root@172.31.5.109 ""echo enable  server web_port/172.31.5.105" | socat stdio /var/lib/haproxy/haproxy.sock"	 
    fi
    ##########################################
    if [ ${node} == "172.31.5.105" ];then
       echo "灰度部署环境服务器-->172.31.5.105 部署完毕,请进行代码测试!"
    else
      ssh root@172.31.5.108 ""echo enable  server web_port/${node}" | socat stdio /var/lib/haproxy/haproxy.sock"
      ssh root@172.31.5.109 ""echo enable  server web_port/${node}" | socat stdio /var/lib/haproxy/haproxy.sock"
    fi
}

function rollback_last_version(){
  for node in ${Server_IP};do
   echo $node
   NOW_VERSION=`ssh magedu@${node} ""/bin/ls -l  -rt /data/tomcat/tomcat_webapps/ | awk -F"->" '{print $2}'  | tail -n1""`
   NOW_VERSION=`basename ${NOW_VERSION}`
   echo $NOW_VERSION,"NOW_VERSION"
    NAME=`ssh  magedu@${node}  ""ls  -l  -rt  /data/tomcat/tomcat_webdir/ | grep -B 1 ${NOW_VERSION} | head -n1 | awk '{print $9}'""`
   echo $NAME,""NAME
   ssh magedu@${node} "rm -rf /data/tomcat/tomcat_webapps/myapp && ln -sv  /data/tomcat/tomcat_webdir/${NAME} /data/tomcat/tomcat_webapps/myapp"
  done 
}

function delete_history_version(){
  for node in ${Server_IP};do
    ssh magedu@${node} "rm -rf /data/tomcat/tomcat_appdir/*"
    NUM=`ssh magedu@${node}  ""/bin/ls -l -d   -rt /data/tomcat/tomcat_webdir/code-* | wc -l""`
    echo "${node} --> ${NUM}"
      if [ ${NUM} -gt 5 ];then
         NAME=`ssh magedu@${node} ""/bin/ls -l -d   -rt /data/tomcat/tomcat_webdir/code-* | head -n1 | awk '{print $9}'""`
         ssh magedu@${node} "rm -rf ${NAME}"
        echo "${node} 删除历史版本${NAME}成功!"
      fi
  done 
}

main(){
   case $1  in
      deploy)
        IP_list;        
        clone_code;
        scanner_code;
        make_zip;
        down_node;
        stop_tomcat;
        scp_zipfile;
        start_tomcat;
        web_test;
        delete_history_version;
         ;;
      rollback_last_version)
        IP_list;
        #echo ${Server_IP}
        down_node;
        stop_tomcat;
        rollback_last_version;
        start_tomcat;
        web_test;
         ;;
    esac
}

main $1 $2 $3
```













参考：
- https://blog.csdn.net/qq_34556414/category_10494189.html
- https://blog.csdn.net/qq_22049773/category_9138183.html
- https://blog.csdn.net/weixin_43180786/category_11221971.html?spm=1001.2014.3001.5482
