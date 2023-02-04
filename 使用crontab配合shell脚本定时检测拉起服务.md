# 简介： 使用crontab配合shell脚本定时检测拉起服务

## 1、新建脚本check_nginx.sh
```
#!/bin/bash
APP_NAME="nginx: master"
BIN_PATH="/usr/local/nginx/sbin"
#检测方法
checkStatus(){
  pid=$(ps -ef |grep "$APP_NAME" |grep -v "grep" |awk '{print $2}');
  #datetime=`date +%Y-%m-%d,%H:%m:%s`
  datetime="`date`"
  if [ -z "${pid}" ]; then
     echo "$datetime ---- 开始启动服务$APP_NAME"
     cd $BIN_PATH
     ./nginx
  else
     echo "$datetime ---- 项目$APP_NAME已经启动,进程pid是${pid}！"
  fi
}
checkStatus
```

脚本授权：
```
chmod  a+x    /usr/local/check/check_nginx.sh
```

这里注意一点：`APP_NAME=“nginx: master”` `APP_NAME`定义的一定要准确一点，保证获取到唯一的pid，而不是获取到相关的日志监控进程或者子work进程的pid

这是由于grep匹配的问题，需要grep进行精准匹配，即"grep -w"
```
#!/bin/bash
NUM=$(ps -ef|grep -w main|grep -v grep|wc -l)
if [ $NUM -eq 0 ];then
   echo "Oh!My God! It's broken! main is stoped!"
else
   echo "Don't worry! main is running!"
fi
```

## 2、建立定时任务
```
crontab -e
#新建定时任务，每分钟检测一次Nginx的状态，如果Nginx没有启动，就执行启动命令
* * * * * /usr/local/check/check_nginx.sh   >> /tmp/check_nginx.log
```

## 3、查看定时任务
```
crontab -l
```

查看日志
```
tail -200f     /tmp/check_nginx.log
```
