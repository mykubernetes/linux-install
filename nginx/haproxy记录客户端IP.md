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
