```
proxy_set_header Host $hoxt;                          # 当后端web服务器也配置了多个虚拟主机时，需要用该header来区分反向代理哪个主机名
prox_set header X-Forwarded-For $remote_addr          # 如果后端web服务器上的程序需要获取用户ip，可以从该header头获取
proxy_set_header http_user_agent $http_user_agent;    # 判断访问端是苹果，安卓，win还是mac
proxy_body_buffer_size         # 用于指定客户端请求主体缓冲区大小，可以理解为先保存到本地在传给用户
proxy_connect_timeout          # 表示与后端服务器连接的超时时间，即发起握手等候响应的超时时间
proxy_send_timeout             # 表示后端服务器的数据回传时间，即在规定的时间内后端服务器必须传完所有的数据，否则，nginx将断开这个连接
proxy_read_timeout             # 设置nginx从代理的后端服务器获取信息的时间，表示连接建立成功之后，nginx等待后端服务器的响应时间，其实nginx已经进入后端的排队之中等候处理
proxy_buffer_size              # 设置缓冲区大小，默认，该个、缓冲区大小等于指令proxy_buffers设置的大小
proxy_buffers                  # 设置缓冲区的数量和大小。nginx从代理的后端服务器获取的响应信息，会保存到缓冲区
proxy_busy_buffers_size        # 用于设置系统忙碌时可以使用的proxy_buffers大小，官方推荐为proxy_buffers*2
proxy_tmep_file_write_size     # 指定proxy缓存临时文件的大小
proxy_next_upstream http_502 http_504 http_503 error timeout invalid_header;    # 请求出错后，转向下一个节点


#!nginx
# proxy.conf
proxy_redirect          off;

client_max_body_size    5m;
client_body_buffer_size 128k;
proxy_connect_timeout   60;
proxy_send_timeout      60;
proxy_read_timeout      60;
proxy_buffer_size       64k;
proxy_buffers           4 64k;
proxy_busy_buffers_size 128k;
proxy_temp_file_write_size 128k;
add_header X-Frame-Options SAMEORIGIN;
```
