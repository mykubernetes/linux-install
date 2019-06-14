codis
===
官方托管代码  
https://github.com/CodisLabs/codis  

一、安装go语言支持  
```
#解压文件
tar -zxvf go1.7.1.linux-amd64.tar.gz -C /usr/local/
#配置环境变量
vim /etc/profile
export GOROOT=/usr/local/go
export PATH=\$PATH:\$GOROOT/bin
#重载配置
source /etc/profile
#检查是否安装成功
go version
```  

二、安装codis  
1、创建go语言工作路径  
``` mkdir -p /usr/data/gowork ```  

2、修改环境属性追加此配置的路径（程序下载的信息都要通过此路径完成）  
```
# vim /etc/profile
export GOPATH=/usr/data/gowork
export GOROOT=/usr/local/go
export PATH=\$PATH:\$GOROOT/bin:$GOPATH/bin:

#重载配置
# source /etc/profile
```  

3、安装go编译依赖库  
```
# go get github.com/tools/godep 
# cd /usr/data/gowork
# ls        #会出现3个目录
bin pkg src
# cd  src/github.com/tools/godep/      #下载的依赖库保存到此位置
# go install ./                        #安装到bin目录里
```  

4、下载godis  
```
go get -u -d github.com/CodisLabs/codis
```  

5、进入codis源代码下载目录并编译安装  
```
cd /usr/data/gowork/src/github.com/CodisLabs/codis
make && make install
```  

6、为方便使用，建立新的目录  
```
mkdir -p /usr/local/codis/{logs,conf,bin}
#拷贝所有课执行文件到新目录
cp -r /usr/data/gowork/src/github.com/CodisLabs/codis/bin/ /usr/local/codis/bin/
```  



