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

4、安装pm2
```
npm install -g pm2 这里安装之后需要指定软连接

未位置环境变量，配置软连接
ln -s /droot/node-v12.4.0-linux-x64/bin/pm2 /usr/bin/pm2
```

5、验证
```
node -v
pm2 -v
npm -v
```

6、运行node命令
```
node hellnode.js        #node.js语言编写脚本
console.log("hello node");
```

npm使用,包管理器
---
```
node --version                               # 查看node版本
npm -v                                       # 查看npm 版本,检查npm 是否正确安装

————————————————————————————————————————————————————————————————————————
# 初始化npm，初始化会创建package.json文件，安装模块会到node_modules目录
# npm init 
Package name: (hello)                        # 模块名字，npm init会自动取当前目录名作为默认名字，这里不需要改，直接确认即可  
Description: A example for write a module    # 模块说明  
Package version: (0.0.0) 0.0.1               # 模块版本号，这个大家按自己习惯来定就可以  
Project homepage: (none)                     # 模块的主页，如果有的话可以填在这里，也可以不填  
Project git repository: (none)               # 模块的git仓库，选填。npm的用户一般都使用github做为自己的git仓库  
Author name: Elmer Zhang                     # 模块作者名字  
Author email: (none) freeboy6716@gmail.com   # 模块作者邮箱  
Author url: (none) http://www.elmerzhang.com # 模块作者URL  
Main module/entry point: (none) hello.js     # 模块的入口文件，我们这里是hello.js </span><span style="color:#ff6666;">(这个必填)</span><span style="color:#333333;">  
Test command: (none)                         # 测试脚本，选填  
What versions of node does it run on? (~v0.5.7) *   # 依赖的node版本号，我们这个脚本可以运行在任何版本的node上，因此填 *  
About to write to /home/elmer/hello/package.json  

#  以下是生成的package.json文件内容预览  
{  
  "author": "Elmer Zhang <freeboy6716@gmail.com> (http://www.elmerzhang.com)",  
  "name": "hello",  
  "description": "A example for write a module",  
  "version": "0.0.1",  
  "repository": {  
    "url": ""  
  },  
  "main": "hello.js",  
  "engines": {  
    "node": "*"  
  },  
  "dependencies": {},  
  "devDependencies": {}  
}  
  
Is this ok? (yes)                           # 对以上内容确认无误后，就可以直接回车确认了
————————————————————————————————————————————————————————————————————————


npm version                                 # 查看所有模块的版本
npm install cnpm -g --registry=https://registry.npm.taobao.org    # 安装cnpm (国内淘宝镜像源),主要用于某些包或命令程序下载不下来的情况
npm search express                          # 搜索需要安装的包
npm install express                         # 安装express模块
npm install -g express                      # 全局安装express模块
npm install express --save                  # 安装包并添加到依赖中*****
npm install                                 # 下载当前的项目所依赖的包，依赖上一条命令*****
npm list                                    # 列出已安装模块
npm show express                            # 显示模块详情
npm update                                  # 升级当前目录下的项目的所有模块
npm update express                          # 升级当前目录下的项目的指定模块
npm update -g express                       # 升级全局安装的express模块
npm uninstall express                       # 删除指定的模块
npm remove express                          # 删除指定模块
```

cnpm安装
--
- 使用淘宝模块使用cnpm,淘宝模块每隔10分钟同步意思官方模块,使用官方模块使用npm
```
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

pm2常用命令记录
---
```
# pm2 start app.js # 启动app.js应用程序

# pm2 start app.js -i 4           # cluster mode 模式启动4个app.js的应用实例, 4个应用程序会自动进行负载均衡

# pm2 start app.js --name="api"   # 启动应用程序并命名为 "api"

# pm2 start app.js --watch        # 当文件变化时自动重启应用

# pm2 start script.sh             # 启动 bash 脚本

# pm2 list                        # 列表 PM2 启动的所有的应用程序

# pm2 monit                       # 显示每个应用程序的CPU和内存占用情况

# pm2 show [app-name]             # 显示应用程序的所有信息

# pm2 logs                        # 显示所有应用程序的日志

# pm2 logs [app-name]             # 显示指定应用程序的日志

# pm2 flush                       # 清空所有日志文件

# pm2 stop all                    # 停止所有的应用程序

# pm2 stop 0                      # 停止 id为 0的指定应用程序

# pm2 restart all                 # 重启所有应用

# pm2 reload all                  # 重启 cluster mode下的所有应用

# pm2 gracefulReload all          # Graceful reload all apps in cluster mode

# pm2 delete all                  # 关闭并删除所有应用

# pm2 delete 0                    # 删除指定应用 id 0

# pm2 scale api 10                # 把名字叫api的应用扩展到10个实例

# pm2 reset [app-name]            # 重置重启数量

# pm2 startup                     # 创建开机自启动命令

# pm2 save                        # 保存当前应用列表

# pm2 resurrect                   # 重新加载保存的应用列表

# pm2 update                      # Save processes, kill PM2 and restore processes

# pm2 generate                    # Generate a sample json configuration file
```
- pm2文档地址：http://pm2.keymetrics.io/docs/usage/quick-start/
