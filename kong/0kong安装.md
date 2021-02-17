一、什么是Kong

- Kong是一个在Nginx中运行的Lua应用程序，并且通过lua-nginx模块实现。Kong不是用这个模块编译Nginx，而是与OpenResty一起发布，OpenResty已经包含了lua-nginx-module
- OpenResty 也不是 Nginx的分支，而是一组扩展其功能的模块。
- Kong是一个可扩展的开源API网关，运作在RESTfull API之前，提供统一的入口，并且通过插件的形式进行扩展，插件提供了平台核心功能意外的功能和服务，例如鉴权、流控等等。
- Kong是有Mashape公司开发，最早用于内部，管理着超过15000个API和微服务，每月产生数十亿个请求。
- Kong是一个可扩展的服务，只需要添加多台服务器就可以配置成一个集群，kong的插件可以轻松扩张kong的功能和能力。

二、安装Kong
---
- Kong支持PostgreSQL 9.5+ 和Cassandra 3.xx 作为其数据存储。所以在暗转Kong之前我们需要先安装配置好数据库，并且给Kong创建好数据库和用户名等等

1、通过包管理器来安装

```
# yum install https://bintray.com/kong/kong-community-edition-rpm/download_file?file_path=centos/7/kong-community-edition-0.14.1.el7.noarch.rpm
```

2、检查一下都安装到哪个目录了。
```
# whereis kong
kong: /etc/kong /usr/local/bin/kong /usr/local/kong
```
- /ect/kong目录为配置文件目录
- /usr/local/kong为Kong的运行目录，Kong启动后会生成nginx的配置文件放在此目录，当然缓存文件也会存放在这个目录中。
- Kong的配置文件中，如果没有启用某一项目配置，那么Kong会使用其默认的配置文件.
- Kong基于openresty，所以通过包管理器来安装也会安装openresty，安装目录为/usr/local/openresty/

三、启动Kong
---
```
# kong --help
No such command: --help

Usage: kong COMMAND [OPTIONS]

The available commands are:
 check
 health
 migrations
 prepare
 quit
 reload
 restart
 roar
 start
 stop
 version

Options:
 --v              verbose
 --vv             debug
```

| 参数 | 功能 |
|------|------|
| check | 检查配置文件 |
| health | 检查节点的健康状态 |
| migrations | 迁移数据库，再第一次配置Kong时候必须要运行此命令，用来初始化数据库..数据库的信息保存再配置文件中，所以使用此命令需要通过-c指定配置文件 |
| prepare | 在配置的前缀目录中准备Kong前缀。这个命令可以用于从nginx二进制文件启动Kong而不使用'kong start' |
| quit | 优雅的停止Kong，在退出之前会先处理完已经接受到的请求 |
| reload | 重载配置文件 |
| restart | 重启Kong |
| roar | 这个参数我也不知道干什么的，可能只是打印出吉祥物？ |
| start | 启动Kong，通过-c来指定配置文件 |
| stop | 停止运行Kong |
| version | 查看版本 |
| --v | 以上任意参数都可以加张-v选项，此选修会打印出信息。 |
| --vv | 以上任意参数都可以加张-v选项，此选修会打印出更为丰富的debug信息。 |

1、启动Kong，因为是第一次启动，所以需要先运行迁移命令，以初始化数据库。
```
# kong migrations list -c /etc/kong/kong.conf -v
2018/09/23 14:19:44 [verbose] Kong: 0.14.1
2018/09/23 14:19:44 [verbose] reading config file at /etc/kong/kong.conf
2018/09/23 14:19:44 [verbose] prefix in use: /usr/local/kong
2018/09/23 14:19:44 [info] No migrations have been run yet for database 'kong'
[root@Kong ~]$ kong migrations up -c /etc/kong/kong.conf -v
2018/09/23 14:20:22 [verbose] Kong: 0.14.1
2018/09/23 14:20:22 [verbose] reading config file at /etc/kong/kong.conf
2018/09/23 14:20:22 [verbose] prefix in use: /usr/local/kong
2018/09/23 14:20:22 [verbose] running datastore migrations
2018/09/23 14:20:22 [info] migrating core for database kong
2018/09/23 14:20:22 [info] core migrated up to: 2015-01-12-175310_skeleton
2018/09/23 14:20:22 [info] core migrated up to: 2015-01-12-175310_init_schema
2018/09/23 14:20:22 [info] core migrated up to: 2015-11-23-817313_nodes
2018/09/23 14:20:22 [info] core migrated up to: 2016-02-29-142793_ttls
2018/09/23 14:20:22 [info] core migrated up to: 2016-09-05-212515_retries
2018/09/23 14:20:22 [info] core migrated up to: 2016-09-16-141423_upstreams
2018/09/23 14:20:22 [info] core migrated up to: 2016-12-14-172100_move_ssl_certs_to_core
2018/09/23 14:20:22 [info] core migrated up to: 2016-11-11-151900_new_apis_router_1
2018/09/23 14:20:22 [info] core migrated up to: 2016-11-11-151900_new_apis_router_2
2018/09/23 14:20:22 [info] core migrated up to: 2016-11-11-151900_new_apis_router_3
2018/09/23 14:20:22 [info] core migrated up to: 2016-01-25-103600_unique_custom_id
2018/09/23 14:20:22 [info] core migrated up to: 2017-01-24-132600_upstream_timeouts
2018/09/23 14:20:22 [info] core migrated up to: 2017-01-24-132600_upstream_timeouts_2
2018/09/23 14:20:23 [info] core migrated up to: 2017-03-27-132300_anonymous
2018/09/23 14:20:23 [info] core migrated up to: 2017-04-18-153000_unique_plugins_id
2018/09/23 14:20:23 [info] core migrated up to: 2017-04-18-153000_unique_plugins_id_2
2018/09/23 14:20:23 [info] core migrated up to: 2017-05-19-180200_cluster_events
2018/09/23 14:20:23 [info] core migrated up to: 2017-05-19-173100_remove_nodes_table
2018/09/23 14:20:23 [info] core migrated up to: 2017-06-16-283123_ttl_indexes
2018/09/23 14:20:23 [info] core migrated up to: 2017-07-28-225000_balancer_orderlist_remove
2018/09/23 14:20:23 [info] core migrated up to: 2017-10-02-173400_apis_created_at_ms_precision
2018/09/23 14:20:23 [info] core migrated up to: 2017-11-07-192000_upstream_healthchecks
2018/09/23 14:20:23 [info] core migrated up to: 2017-10-27-134100_consistent_hashing_1
2018/09/23 14:20:23 [info] core migrated up to: 2017-11-07-192100_upstream_healthchecks_2
2018/09/23 14:20:23 [info] core migrated up to: 2017-10-27-134100_consistent_hashing_2
2018/09/23 14:20:23 [info] core migrated up to: 2017-09-14-121200_routes_and_services
2018/09/23 14:20:23 [info] core migrated up to: 2017-10-25-180700_plugins_routes_and_services
2018/09/23 14:20:23 [info] core migrated up to: 2018-03-27-123400_prepare_certs_and_snis
2018/09/23 14:20:23 [info] core migrated up to: 2018-03-27-125400_fill_in_snis_ids
2018/09/23 14:20:23 [info] core migrated up to: 2018-03-27-130400_make_ids_primary_keys_in_snis
2018/09/23 14:20:23 [info] core migrated up to: 2018-05-17-173100_hash_on_cookie
2018/09/23 14:20:23 [info] migrating response-transformer for database kong
2018/09/23 14:20:23 [info] response-transformer migrated up to: 2016-05-04-160000_resp_trans_schema_changes
2018/09/23 14:20:23 [info] migrating ip-restriction for database kong
2018/09/23 14:20:23 [info] ip-restriction migrated up to: 2016-05-24-remove-cache
2018/09/23 14:20:23 [info] migrating statsd for database kong
2018/09/23 14:20:23 [info] statsd migrated up to: 2017-06-09-160000_statsd_schema_changes
2018/09/23 14:20:23 [info] migrating jwt for database kong
2018/09/23 14:20:23 [info] jwt migrated up to: 2015-06-09-jwt-auth
2018/09/23 14:20:23 [info] jwt migrated up to: 2016-03-07-jwt-alg
2018/09/23 14:20:23 [info] jwt migrated up to: 2017-05-22-jwt_secret_not_unique
2018/09/23 14:20:23 [info] jwt migrated up to: 2017-07-31-120200_jwt-auth_preflight_default
2018/09/23 14:20:23 [info] jwt migrated up to: 2017-10-25-211200_jwt_cookie_names_default
2018/09/23 14:20:23 [info] jwt migrated up to: 2018-03-15-150000_jwt_maximum_expiration
2018/09/23 14:20:23 [info] migrating cors for database kong
2018/09/23 14:20:23 [info] cors migrated up to: 2017-03-14_multiple_orgins
2018/09/23 14:20:23 [info] migrating basic-auth for database kong
2018/09/23 14:20:23 [info] basic-auth migrated up to: 2015-08-03-132400_init_basicauth
2018/09/23 14:20:23 [info] basic-auth migrated up to: 2017-01-25-180400_unique_username
2018/09/23 14:20:23 [info] migrating key-auth for database kong
2018/09/23 14:20:23 [info] key-auth migrated up to: 2015-07-31-172400_init_keyauth
2018/09/23 14:20:23 [info] key-auth migrated up to: 2017-07-31-120200_key-auth_preflight_default
2018/09/23 14:20:23 [info] migrating ldap-auth for database kong
2018/09/23 14:20:23 [info] ldap-auth migrated up to: 2017-10-23-150900_header_type_default
2018/09/23 14:20:23 [info] migrating hmac-auth for database kong
2018/09/23 14:20:23 [info] hmac-auth migrated up to: 2015-09-16-132400_init_hmacauth
2018/09/23 14:20:23 [info] hmac-auth migrated up to: 2017-06-21-132400_init_hmacauth
2018/09/23 14:20:23 [info] migrating datadog for database kong
2018/09/23 14:20:23 [info] datadog migrated up to: 2017-06-09-160000_datadog_schema_changes
2018/09/23 14:20:23 [info] migrating tcp-log for database kong
2018/09/23 14:20:23 [info] tcp-log migrated up to: 2017-12-13-120000_tcp-log_tls
2018/09/23 14:20:23 [info] migrating acl for database kong
2018/09/23 14:20:23 [info] acl migrated up to: 2015-08-25-841841_init_acl
2018/09/23 14:20:23 [info] migrating response-ratelimiting for database kong
2018/09/23 14:20:23 [info] response-ratelimiting migrated up to: 2015-08-03-132400_init_response_ratelimiting
2018/09/23 14:20:23 [info] response-ratelimiting migrated up to: 2016-08-04-321512_response-rate-limiting_policies
2018/09/23 14:20:23 [info] response-ratelimiting migrated up to: 2017-12-19-120000_add_route_and_service_id_to_response_ratelimiting
2018/09/23 14:20:23 [info] migrating request-transformer for database kong
2018/09/23 14:20:23 [info] request-transformer migrated up to: 2016-05-04-160000_req_trans_schema_changes
2018/09/23 14:20:23 [info] migrating rate-limiting for database kong
2018/09/23 14:20:23 [info] rate-limiting migrated up to: 2015-08-03-132400_init_ratelimiting
2018/09/23 14:20:23 [info] rate-limiting migrated up to: 2016-07-25-471385_ratelimiting_policies
2018/09/23 14:20:23 [info] rate-limiting migrated up to: 2017-11-30-120000_add_route_and_service_id
2018/09/23 14:20:23 [info] migrating oauth2 for database kong
2018/09/23 14:20:23 [info] oauth2 migrated up to: 2015-08-03-132400_init_oauth2
2018/09/23 14:20:23 [info] oauth2 migrated up to: 2016-07-15-oauth2_code_credential_id
2018/09/23 14:20:23 [info] oauth2 migrated up to: 2016-12-22-283949_serialize_redirect_uri
2018/09/23 14:20:23 [info] oauth2 migrated up to: 2016-09-19-oauth2_api_id
2018/09/23 14:20:23 [info] oauth2 migrated up to: 2016-12-15-set_global_credentials
2018/09/23 14:20:23 [info] oauth2 migrated up to: 2017-04-24-oauth2_client_secret_not_unique
2018/09/23 14:20:23 [info] oauth2 migrated up to: 2017-10-19-set_auth_header_name_default
2018/09/23 14:20:23 [info] oauth2 migrated up to: 2017-10-11-oauth2_new_refresh_token_ttl_config_value
2018/09/23 14:20:23 [info] oauth2 migrated up to: 2018-01-09-oauth2_pg_add_service_id
2018/09/23 14:20:23 [info] 67 migrations ran
2018/09/23 14:20:23 [verbose] migrations up to date
```
- 在migrations参数中，还可以跟上list、up、reset的参数，其中list是显示当前迁移的信息，up参数查询缺少的部分，并且修复、reset的重置所有的迁移

2、迁移成功之后可以使用kong start来启动Kong
```
# kong start -c /etc/kong/kong.conf --vv
2018/09/23 14:25:49 [verbose] Kong: 0.14.1
2018/09/23 14:25:49 [debug] ngx_lua: 10013
2018/09/23 14:25:49 [debug] nginx: 1013006
2018/09/23 14:25:49 [debug] Lua: LuaJIT 2.1.0-beta3
2018/09/23 14:25:49 [verbose] reading config file at /etc/kong/kong.conf
2018/09/23 14:25:49 [debug] reading environment variables
2018/09/23 14:25:49 [debug] admin_access_log = "logs/admin_access.log"
2018/09/23 14:25:49 [debug] admin_error_log = "logs/error.log"
2018/09/23 14:25:49 [debug] admin_listen = {"127.0.0.1:8001","127.0.0.1:8444 ssl"}
2018/09/23 14:25:49 [debug] anonymous_reports = true
2018/09/23 14:25:49 [debug] cassandra_consistency = "ONE"
2018/09/23 14:25:49 [debug] cassandra_contact_points = {"127.0.0.1"}
2018/09/23 14:25:49 [debug] cassandra_data_centers = {"dc1:2","dc2:3"}
2018/09/23 14:25:49 [debug] cassandra_keyspace = "kong"
2018/09/23 14:25:49 [debug] cassandra_lb_policy = "RoundRobin"
2018/09/23 14:25:49 [debug] cassandra_port = 9042
2018/09/23 14:25:49 [debug] cassandra_repl_factor = 1
2018/09/23 14:25:49 [debug] cassandra_repl_strategy = "SimpleStrategy"
2018/09/23 14:25:49 [debug] cassandra_schema_consensus_timeout = 10000
2018/09/23 14:25:49 [debug] cassandra_ssl = false
2018/09/23 14:25:49 [debug] cassandra_ssl_verify = false
2018/09/23 14:25:49 [debug] cassandra_timeout = 5000
2018/09/23 14:25:49 [debug] cassandra_username = "kong"
2018/09/23 14:25:49 [debug] client_body_buffer_size = "8k"
2018/09/23 14:25:49 [debug] client_max_body_size = "0"
2018/09/23 14:25:49 [debug] client_ssl = false
2018/09/23 14:25:49 [debug] custom_plugins = {}
2018/09/23 14:25:49 [debug] database = "postgres"
2018/09/23 14:25:49 [debug] db_cache_ttl = 0
2018/09/23 14:25:49 [debug] db_resurrect_ttl = 30
2018/09/23 14:25:49 [debug] db_update_frequency = 5
2018/09/23 14:25:49 [debug] db_update_propagation = 0
2018/09/23 14:25:49 [debug] dns_error_ttl = 1
2018/09/23 14:25:49 [debug] dns_hostsfile = "/etc/hosts"
2018/09/23 14:25:49 [debug] dns_no_sync = false
2018/09/23 14:25:49 [debug] dns_not_found_ttl = 30
2018/09/23 14:25:49 [debug] dns_order = {"LAST","SRV","A","CNAME"}
2018/09/23 14:25:49 [debug] dns_resolver = {}
2018/09/23 14:25:49 [debug] dns_stale_ttl = 4
2018/09/23 14:25:49 [debug] error_default_type = "text/plain"
2018/09/23 14:25:49 [debug] headers = {"server_tokens","latency_tokens"}
2018/09/23 14:25:49 [debug] log_level = "notice"
2018/09/23 14:25:49 [debug] lua_package_cpath = ""
2018/09/23 14:25:49 [debug] lua_package_path = "./?.lua;./?/init.lua;"
2018/09/23 14:25:49 [debug] lua_socket_pool_size = 30
2018/09/23 14:25:49 [debug] lua_ssl_verify_depth = 1
2018/09/23 14:25:49 [debug] mem_cache_size = "128m"
2018/09/23 14:25:49 [debug] nginx_admin_directives = {}
2018/09/23 14:25:49 [debug] nginx_daemon = "on"
2018/09/23 14:25:49 [debug] nginx_http_directives = {}
2018/09/23 14:25:49 [debug] nginx_optimizations = true
2018/09/23 14:25:49 [debug] nginx_proxy_directives = {}
2018/09/23 14:25:49 [debug] nginx_user = "nobody nobody"
2018/09/23 14:25:49 [debug] nginx_worker_processes = "auto"
2018/09/23 14:25:49 [debug] pg_database = "kong"
2018/09/23 14:25:49 [debug] pg_host = "192.168.0.219"
2018/09/23 14:25:49 [debug] pg_password = "******"
2018/09/23 14:25:49 [debug] pg_port = 5432
2018/09/23 14:25:49 [debug] pg_ssl = false
2018/09/23 14:25:49 [debug] pg_ssl_verify = false
2018/09/23 14:25:49 [debug] pg_user = "kong"
2018/09/23 14:25:49 [debug] plugins = {"bundled"}
2018/09/23 14:25:49 [debug] prefix = "/usr/local/kong/"
2018/09/23 14:25:49 [debug] proxy_access_log = "logs/access.log"
2018/09/23 14:25:49 [debug] proxy_error_log = "logs/error.log"
2018/09/23 14:25:49 [debug] proxy_listen = {"0.0.0.0:8000","0.0.0.0:8443 ssl"}
2018/09/23 14:25:49 [debug] real_ip_header = "X-Real-IP"
2018/09/23 14:25:49 [debug] real_ip_recursive = "off"
2018/09/23 14:25:49 [debug] ssl_cipher_suite = "modern"
2018/09/23 14:25:49 [debug] ssl_ciphers = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256"
2018/09/23 14:25:49 [debug] trusted_ips = {}
2018/09/23 14:25:49 [debug] upstream_keepalive = 60
2018/09/23 14:25:49 [verbose] prefix in use: /usr/local/kong
2018/09/23 14:25:49 [verbose] preparing nginx prefix directory at /usr/local/kong
2018/09/23 14:25:49 [verbose] SSL enabled, no custom certificate set: using default certificate
2018/09/23 14:25:49 [verbose] generating default SSL certificate and key
2018/09/23 14:25:49 [verbose] Admin SSL enabled, no custom certificate set: using default certificate
2018/09/23 14:25:49 [verbose] generating admin SSL certificate and key
2018/09/23 14:25:49 [warn] ulimit is currently set to "1024". For better performance set it to at least "4096" using "ulimit -n"
2018/09/23 14:25:50 [debug] searching for OpenResty 'nginx' executable
2018/09/23 14:25:50 [debug] /usr/local/openresty/nginx/sbin/nginx -v: 'nginx version: openresty/1.13.6.2'
2018/09/23 14:25:50 [debug] found OpenResty 'nginx' executable at /usr/local/openresty/nginx/sbin/nginx
2018/09/23 14:25:50 [debug] testing nginx configuration: KONG_NGINX_CONF_CHECK=true /usr/local/openresty/nginx/sbin/nginx -t -p /usr/local/kong -c nginx.conf
2018/09/23 14:25:50 [debug] searching for OpenResty 'nginx' executable
2018/09/23 14:25:50 [debug] /usr/local/openresty/nginx/sbin/nginx -v: 'nginx version: openresty/1.13.6.2'
2018/09/23 14:25:50 [debug] found OpenResty 'nginx' executable at /usr/local/openresty/nginx/sbin/nginx
2018/09/23 14:25:50 [debug] sending signal to pid at: /usr/local/kong/pids/nginx.pid
2018/09/23 14:25:50 [debug] kill -0 `cat /usr/local/kong/pids/nginx.pid` >/dev/null 2>&1
2018/09/23 14:25:50 [debug] starting nginx: /usr/local/openresty/nginx/sbin/nginx -p /usr/local/kong -c nginx.conf
2018/09/23 14:25:50 [debug] nginx started
2018/09/23 14:25:50 [info] Kong started
```
- 指定了--vv之后会打印出启动的debug信息，启动成功之后会自动再后台以daemon的方式运行。

3、查看Kong默认监听端口
```
# netstat -ntlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      775/sshd            
tcp        0      0 0.0.0.0:5432            0.0.0.0:*               LISTEN      2084/postmaster     
tcp        0      0 127.0.0.1:25            0.0.0.0:*               LISTEN      730/master          
tcp        0      0 0.0.0.0:8443            0.0.0.0:*               LISTEN      2369/nginx: master  
tcp        0      0 127.0.0.1:8444          0.0.0.0:*               LISTEN      2369/nginx: master  
tcp        0      0 0.0.0.0:8000            0.0.0.0:*               LISTEN      2369/nginx: master  
tcp        0      0 127.0.0.1:8001          0.0.0.0:*               LISTEN      2369/nginx: master  
tcp        0      0 127.0.0.1:32001         0.0.0.0:*               LISTEN      1067/java           
tcp6       0      0 :::22                   :::*                    LISTEN      775/sshd            
tcp6       0      0 ::1:25                  :::*                    LISTEN      730/master          
```
- 8000：API网关http代理端口
- 8443：API网关https代理端口
- 8001：Kong管理API的http端口
- 8444：Kong管理API的https端口
- 启动的进程名称均为nginx

4、Kong的默认运行目录在/usr/local/kong，我们看一下这个目录有什么东西：
```
# ls -l
总用量 100
drwx------ 2 nobody root  4096 9月  23 14:25 client_body_temp
-rw-r--r-- 1 root   root 55501 8月  22 06:52 COPYRIGHT
drwx------ 2 nobody root  4096 9月  23 14:25 fastcgi_temp
drwxr-xr-x 2 root   root  4096 9月  23 14:25 logs
-rw-r--r-- 1 root   root   219 9月  23 14:25 nginx.conf
-rw-r--r-- 1 root   root  5249 9月  23 14:25 nginx-kong.conf
drwxr-xr-x 2 root   root  4096 9月  23 14:25 pids
drwx------ 2 nobody root  4096 9月  23 14:25 proxy_temp
drwx------ 2 nobody root  4096 9月  23 14:25 scgi_temp
drwxr-xr-x 2 root   root  4096 9月  23 14:25 ssl
drwx------ 2 nobody root  4096 9月  23 14:25 uwsgi_temp
```
