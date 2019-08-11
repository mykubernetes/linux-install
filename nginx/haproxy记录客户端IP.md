Haproxy作为代理记录客户端IP配置  
```
default加入：

option httpclose
option forwardfor
```  

Tomcat记录真实客户IP配置  
```
server.xml中添加
prefix="localhost_access_log." suffix=".txt"
pattern="%{X-FORWARDED-FOR}i %l %u %t %r %s %b %D %q %{User-Agent}i %T" resolveHosts="false"/>完整配置为：
<Valve className="org.apache.catalina.valves.AccessLogValve"
                directory="logs" 
                prefix="localhost_access_log."
                suffix=".txt"
                pattern="%{X-FORWARDED-FOR}i %l %u %t %r %s %b %D %q %{User-Agent}i %T"
                resolveHosts="false"/>
```  

- ％a - 远程IP地址
- ％A - 本地IP地址
- ％b - 发送的字节数，不包括HTTP头，或“ - ”如果没有发送字节
- ％B - 发送的字节数，不包括HTTP头
- ％h - 远程主机名
- ％H - 请求协议
- ％l (小写的L)- 远程逻辑从identd的用户名（总是返回' - '）
- ％m - 请求方法
- ％p - 本地端口
- ％q - 查询字符串（在前面加上一个“？”如果它存在，否则是一个空字符串
- ％r - 第一行的要求
- ％s - 响应的HTTP状态代码
- ％S - 用户会话ID
- ％t - 日期和时间，在通用日志格式
- ％u - 远程用户身份验证
- ％U - 请求的URL路径
- ％v - 本地服务器名
- ％D - 处理请求的时间（以毫秒为单位）
- ％T - 处理请求的时间（以秒为单位）
- ％I - 当前请求的线程名称

Apche记录真实客户端IP配置  
```
<IfModule log_config_module>
    LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>

    CustomLog "logs/access_log" common
</IfModule>
```  
- %% 百分号(Apache2.0.44或更高的版本)
- %a 远端IP地址
- %A 本机IP地址
- %B 除HTTP头以外传送的字节数
- %b 以CLF格式显示的除HTTP头以外传送的字节数，也就是当没有字节传送时显示’-‘而不是0。
- %{Foobar}C 在请求中传送给服务端的cookieFoobar的内容。
- %D 服务器处理本请求所用时间，以微为单位。
- %{FOOBAR}e 环境变量FOOBAR的值
- %f 文件名
- %h 远端主机
- %H 请求使用的协议
- %{Foobar}i 发送到服务器的请求头Foobar:的内容。
- %l 远端登录名(由identd而来，如果支持的话)，除非IdentityCheck设为”On“，否则将得到一个”-”。
- %m 请求的方法
- %{Foobar}n 来自另一个模块的注解Foobar的内容。
- %{Foobar}o 应答头Foobar:的内容。
- %p 服务器服务于该请求的标准端口。
- %P 为本请求提供服务的子进程的PID。
- %{format}P 服务于该请求的PID或TID(线程ID)，format的取值范围为：pid和tid(2.0.46及以后版本)以及hextid(需要APR1.2.0及以上版本)
- %q 查询字符串(若存在则由一个”?“引导，否则返回空串)
- %r 请求的第一行
- %s 状态。对于内部重定向的请求，这个状态指的是原始请求的状态，—%>s则指的是最后请求的状态。
- %t 时间，用普通日志时间格式(标准英语格式)
- %{format}t 时间，用strftime(3)指定的格式表示的时间。(默认情况下按本地化格式)
- %T 处理完请求所花时间，以秒为单位。
- %u 远程用户名(根据验证信息而来；如果返回status(%s)为401，可能是假的)
- %U 请求的URL路径，不包含查询字符串。
- %v 对该请求提供服务的标准ServerName。
- %V 根据UseCanonicalName指令设定的服务器名称。
- %X 请求完成时的连接状态：
- X= 连接在应答完成前中断。
- += 应答传送完后继续保持连接。
- -= 应答传送完后关闭连接。
- %I 接收的字节数，包括请求头的数据，并且不能为零。要使用这个指令你必须启用mod_logio模块。
- %O 发送的字节数，包括请求头的数据，并且不能为零。要使用这个指令你必须启用mod_logio模块。
