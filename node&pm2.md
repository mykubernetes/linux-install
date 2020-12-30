
一、下载node安装包
```
1、wget https://npm.taobao.org/mirrors/node/latest-v12.x/node-v12.4.0-linux-x64.tar.gz
```

二、解压
```
1、tar -xvf node-v12.4.0-linux-x64.tar.gz
```

三、添加链接
```
1、ln -s /data/node-v12.4.0-linux-x64/bin/node /usr/bin/node

2、ln -s /data/node-v12.4.0-linux-x64/bin/npm /usr/bin/npm
```

3、安装pm2（如果不知道pm2干啥的自行百度）
```
npm install -g pm2 这里安装之后需要指定软连接

ln -s /data/node-v12.4.0-linux-x64/bin/pm2 /usr/bin/pm2
```

四、总结

以上三步操作完后就可以正常使用node和pm2了。

可以通过node -v、pm2 -v 和 npm -v 验证。
