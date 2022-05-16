# Jenkins插件下载慢的解决办法(使用nginx反向代理)

即使更换清华源的update-center.json，依然很卡，那是因为清华源也是指向了官方地址。

最好的办法就是使用nginx代理updates.jenkins-ci.org

步骤分为两步:
- 将updates.jenkins-ci.org映射到本地环回地址127.0.0.1
- 使用nginx代理updates.jenkins-ci.org的镜像网站到清华源

第一步：将updates.jenkins.org映射到本地环回地址
```
vim  /etc/hosts
127.0.0.1 updates.jenkins-ci.org
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
     server_name  updates.jenkins-ci.org ;
 
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
