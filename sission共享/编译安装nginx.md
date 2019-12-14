| 参数 | 描述 |
| :------: | :--------: | 
| --prefix=PATH	| 安装目录
| --sbin-path=PATH | nginx可执行文件目录
| --modules-path=PATH	| 模块路径
| --conf-path=PATH | 配置文件路径
| --error-log-path=PATH	| 错误日志路径
| --http-log-path=PATH | 访问日志路径
| --pid-path=PATH	| pid路径
| --lock-path=PATH | lock文件路径
| --user=USER |  运行用户
| --group=GROUP | 运行组
| --with-threads | 启用多线程全局先定义池子： thread_pool one threads=32 max_queue=65535; 在里面引用： aio threads=one;
| --with-http_ssl_module | 提供HTTPS支持
| --with-http_v2_module	| HTTP2.0协议
| --with-http_realip_module	| 获取真实客户端IP
| --with-http_image_filter_module	| 图片过滤模块，比如缩略图、旋转等
| --with-http_geoip_module | 基于客户端IP获取地理位置
| --with-http_sub_module | 在应答数据中可替换静态页面源码内容
| --with-http_dav_module | 为文件和目录指定权限，限制用户对页面有不同的访问权限
| --with-http_flv_module | 支持flv流媒体播放
| --with-http_mp4_module | 支持mp4流媒体播放
| --with-http_gzip_static_module | 针对静态文件，允许发送.gz文件扩展名的预压缩文件给客户端，使用是gzip_static on
| --with-http_gunzip_static_module | Content-Encoding：gzip 用于对不支持gzip压缩的客户端使用，先解压缩后再响应。
| --with-http_secure_link_module | 检查链接，比如实现防盗链
| --with-http_stub_status_module | 获取nginx工作状态模块
| --with-mail_ssl_module |	启用邮件SSL模块
| --with-stream	| 启用TCP/UDP代理模块
| --add-module=PATH	| 启用扩展模块
| --with-stream_realip_module	| 流形式，获取真实客户端IP
| --with-stream_geoip_module | 流形式，获取客户端IP地理位置
| --with-pcre	| 启用PCRE库，rewrite需要的正则库
| --with-pcre=DIR	| 指定PCRE库路径
| --with-zlib=DIR	| 指定zlib库路径，gzip模块依赖
| --with-openssl=DIR | 指定openssl库路径，ssl模块依赖
