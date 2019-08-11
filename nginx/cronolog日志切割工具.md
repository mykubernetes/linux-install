
1、apache结合cronolog日志切割  
```
# vim /usr/local/apache2/conf/httpd.conf
将默认日志： CustomLog "logs/access_log" combined
修改为：CustomLog "|/usr/sbin/cronolog logs/access_%Y-%m-%d.log"combined 即可。其中%Y%m%d为日志文件分割方式，即为"年月日"。
ErrorLog "|/usr/sbin/cronolog logs/error_%Y-%m-%d.log"  错误日志
```


2、tengine结合cronolog日志切割  
```
# vim /etc/nginx/nginx.conf
error_log "pipe:/usr/sbin/cronolog /var/log/nginx/%Y-%m-%d-error.log" error;
access_log "pipe:/usr/sbin/cronolog /var/log/nginx/%Y-%m-%d-%H-access.log" main;
```  


3、tomcat结合cronolog日志切割  
修改Tomcat下bin/catalina.sh文件  
```
修改为：
  shift
  # touch "$CATALINA_OUT"      #注释此项
  if [ "$1" = "-security" ] ; then
    if [ $have_tty -eq 1 ]; then
      echo "Using Security Manager"
    fi
    shift
    eval $_NOHUP "\"$_RUNJAVA\"" "\"$LOGGING_CONFIG\"" $LOGGING_MANAGER $JAVA_OPTS $CATALINA_OPTS \
      -classpath "\"$CLASSPATH\"" \
      -Djava.security.manager \
      -Djava.security.policy=="\"$CATALINA_BASE/conf/catalina.policy\"" \
      -Dcatalina.base="\"$CATALINA_BASE\"" \
      -Dcatalina.home="\"$CATALINA_HOME\"" \
      -Djava.io.tmpdir="\"$CATALINA_TMPDIR\"" \
      org.apache.catalina.startup.Bootstrap "$@" start 2>&1\           #修改下边两行
      | /usr/sbin/cronolog "$CATALINA_BASE"/logs/catalina.%Y-%m-%d.out >> /dev/null &
 
  else
    eval $_NOHUP "\"$_RUNJAVA\"" "\"$LOGGING_CONFIG\"" $LOGGING_MANAGER $JAVA_OPTS $CATALINA_OPTS \
      -classpath "\"$CLASSPATH\"" \
      -Dcatalina.base="\"$CATALINA_BASE\"" \
      -Dcatalina.home="\"$CATALINA_HOME\"" \
      -Djava.io.tmpdir="\"$CATALINA_TMPDIR\"" \
      org.apache.catalina.startup.Bootstrap "$@" start 2>&1\           #修改下边两行
      | /usr/sbin/cronolog "$CATALINA_BASE"/logs/catalina.%Y-%m-%d.out >> /dev/null &
 
  fi
 ```  
 
 
4、删除30天以上的日志  
```
# vim del-30-days-ago-logs.sh
find /opt/soft/log/ -mtime +30 -name "*.log" -exec rm -rf {} \;

# chmod +x del-15-days-ago-logs.sh
# crontab -e
10 0 * * * /opt/soft/log/del-15-days-ago-logs.sh >/dev/null 2>&1
```  
