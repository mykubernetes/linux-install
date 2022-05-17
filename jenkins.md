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
















参考：
- https://blog.csdn.net/qq_34556414/category_10494189.html
- https://blog.csdn.net/qq_22049773/category_9138183.html
- https://blog.csdn.net/weixin_43180786/category_11221971.html?spm=1001.2014.3001.5482
