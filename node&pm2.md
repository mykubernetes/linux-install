安装node和pm2
---
1、下载node安装包
```
wget https://npm.taobao.org/mirrors/node/latest-v12.x/node-v12.4.0-linux-x64.tar.gz
```

2、解压
```
tar -xvf node-v12.4.0-linux-x64.tar.gz
```

3、配置环境变量
```

vim /etc/profile
export NODE_HOME=/opt/node-v12.4.0-linux-x64
export PATH=$NODE_HOME/bin:$PATH
source /etc/profile

或者
ln -s /opt/node-v12.4.0-linux-x64/bin/node /usr/bin/node
ln -s /opt/node-v12.4.0-linux-x64/bin/npm /usr/bin/npm
```

3、安装pm2
```
npm install -g pm2 这里安装之后需要指定软连接

未位置环境变量，配置软连接
ln -s /droot/node-v12.4.0-linux-x64/bin/pm2 /usr/bin/pm2
```

四、验证
```
node -v
pm2 -v
npm -v
```

pm2常用命令记录
---
```
# pm2 start app.js # 启动app.js应用程序

# pm2 start app.js -i 4        # cluster mode 模式启动4个app.js的应用实例

# 4个应用程序会自动进行负载均衡

# pm2 start app.js --name="api" # 启动应用程序并命名为 "api"

# pm2 start app.js --watch      # 当文件变化时自动重启应用

# pm2 start script.sh          # 启动 bash 脚本

# pm2 list                      # 列表 PM2 启动的所有的应用程序

# pm2 monit                    # 显示每个应用程序的CPU和内存占用情况

# pm2 show [app-name]          # 显示应用程序的所有信息

# pm2 logs                      # 显示所有应用程序的日志

# pm2 logs [app-name]          # 显示指定应用程序的日志

# pm2 flush                       # 清空所有日志文件

# pm2 stop all                  # 停止所有的应用程序

# pm2 stop 0                    # 停止 id为 0的指定应用程序

# pm2 restart all              # 重启所有应用

# pm2 reload all                # 重启 cluster mode下的所有应用

# pm2 gracefulReload all        # Graceful reload all apps in cluster mode

# pm2 delete all                # 关闭并删除所有应用

# pm2 delete 0                  # 删除指定应用 id 0

# pm2 scale api 10              # 把名字叫api的应用扩展到10个实例

# pm2 reset [app-name]          # 重置重启数量

# pm2 startup                  # 创建开机自启动命令

# pm2 save                      # 保存当前应用列表

# pm2 resurrect                # 重新加载保存的应用列表

# pm2 update                    # Save processes, kill PM2 and restore processes

# pm2 generate                  # Generate a sample json configuration file
pm2文档地址：http://pm2.keymetrics.io/docs/usage/quick-start/
```
