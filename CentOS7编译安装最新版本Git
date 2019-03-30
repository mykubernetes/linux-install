#!/bin/bash

#卸载旧版本git
yum remove -y git

#安装编译环境依赖包
yum install -y gcc gcc-c++

#安装Git编译过程需要的依赖关系库
yum install -y curl-devel expat-devel gettext-devel openssl-devel zlib-devel

#下载git源码包，以git-2.20.1为例
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.20.1.tar.gz

#编译安装git
tar -zxvf git-2.20.1.tar.gz
cd git-2.20.1 
./configure --prefix=/usr/local/git
make && make install

#配置环境变量
cat >> /etc/profile << EOF
export PATH=/usr/local/git/bin:$PATH
EOF
source /etc/profile

#配置git命令补全
wget -P /home https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
echo 'source "/home/git-completion.bash"' >> $HOME/.bashrc
source $HOME/.bashrc

#查看git版本
git --version
