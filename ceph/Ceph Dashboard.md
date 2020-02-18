# 配置Ceph Dashboard
```
1、在每个mgr节点安装
# yum install ceph-mgr-dashboard 
2、开启mgr功能
# ceph mgr module enable dashboard
3、生成并安装自签名的证书
# ceph dashboard create-self-signed-cert  
4、创建一个dashboard登录用户名密码
# ceph dashboard ac-user-create guest 1q2w3e4r administrator 
5、查看服务访问方式
# ceph mgr services
```
# 修改默认配置命令
```
指定集群dashboard的访问端口
# ceph config-key set mgr/dashboard/server_port 7000
指定集群 dashboard的访问IP
# ceph config-key set mgr/dashboard/server_addr $IP 
```
# 开启Object Gateway管理功能
```
1、创建rgw用户
# radosgw-admin user info --uid=user01
2、提供Dashboard证书
# ceph dashboard set-rgw-api-access-key $access_key
# ceph dashboard set-rgw-api-secret-key $secret_key
3、配置rgw主机名和端口
# ceph dashboard set-rgw-api-host 10.151.30.125
4、刷新web页面
```
