https://www.jianshu.com/p/dd8183937106


RPM包制作实例
===

安装制作rpm工具
```
yum install rpm-build -y
```

1.建立一个普通用户，有普通用户来制作rpm，用root的可能会因为代码问题导致毁灭的后果
```
useradd ibuler 
su - ibuler 
```
2.确定我们在哪个目录下制作RPM，通常这个目录我们topdir,这个需要在宏配置文件中指定，这个配置文件称为macrofiles，它们通常为 /usr/lib/rpm/macros:/usr/lib/rpm/macros.*:~/.rpmmacros,这个在rhel 5.8中可以通过rpmbuild --showrc | grep macrofiles  查看，6.3的我使用这个找不到，但使用是一样的。你可以通过rpmbuild --showrc | grep topdir 查看你系统默认的工作车间 
```
rpmbuild --showrc | grep topdir 
     
-14: _builddir  %{_topdir}/BUILD 
-14: _buildrootdir  %{_topdir}/BUILDROOT 
-14: _rpmdir    %{_topdir}/RPMS 
-14: _sourcedir %{_topdir}/SOURCES 
-14: _specdir   %{_topdir}/SPECS 
-14: _srcrpmdir %{_topdir}/SRPMS 
-14: _topdir    %{getenv:HOME}/rpmbuild 
```
我们还是自定义工作目录(或车间)吧
```
vi ~/.rpmmacros 
%_topdir        /home/ibuler/rpmbuild    ##目录可以自定义 
     
mkdir ~/rpmbuild  
```

3.在topdir下建立需要的目录
```
cd ~/rpmbuild  
mkdir -pv {BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} 
```
- BUILD   源代码解压后的存放目录
- RPMS    制作完成后的RPM包存放目录，里面有与平台相关的子目录
- SOURCES 收集的源材料，补丁的存放位置
- SPECS   SPEC文件存放目录
- SRMPS   存放SRMPS生成的目录

4.把收集的源码放到SOURCES下
```
cp /tmp/tengine-1.4.2.tar.gz SOURCES   ##事先放好的
```

5.在SPECS下建立重要的spec文件
```
cd SPECS 
vi tengine.spec          ##内容见后讲解，rhel6.3会自动生成模板 
```

6.用rpmbuild命令制作rpm包，rpmbuild命令会根据spec文件来生成rpm包 
```
rpmbuild  
-ba 既生成src.rpm又生成二进制rpm 
-bs 只生成src的rpm 
-bb 只生二进制的rpm 
-bp 执行到pre 
-bc 执行到 build段 
-bi 执行install段 
-bl 检测有文件没包含 
```
我们可以一步步试，先rpmbuild -bp ,再-bc 再-bi 如果没问题，rpmbuild -ba 生成src包与二进制包吧

7.安装测试有没有问题，能否正常安装运行，能否正常升级，卸载有没有问题

root用户测试安装:
```
cd /tmp
cp /home/ibuler/rpmbuild/RPMS/x86_64/tengine-1.4.2-1.el6.x86_64.rpm /tmp  
rpm -ivh tengine-1.4.2-1.el6.x86_64.rpm  ##测试安装 
rpm -e tengine                           ##测试卸载，如果版本号比原来的高，升级测试 
```

8.查看一个制作好的rpm包信息
```
# rpm -qi rrdtool
Name        : rrdtool
Version     : 1.4.8
Release     : 9.el7
Architecture: x86_64
Install Date: Sat 18 Apr 2020 10:56:29 PM EDT
Group       : Applications/Databases
Size        : 2966501
License     : GPLv2+ with exceptions
Signature   : RSA/SHA256, Wed 25 Nov 2015 10:37:07 AM EST, Key ID 24c6a8a7f4a80eb5
Source RPM  : rrdtool-1.4.8-9.el7.src.rpm
Build Date  : Fri 20 Nov 2015 02:24:01 PM EST
Build Host  : worker1.bsys.centos.org
Relocations : (not relocatable)
Packager    : CentOS BuildSystem <http://bugs.centos.org>
Vendor      : CentOS
URL         : http://oss.oetiker.ch/rrdtool/
Summary     : Round Robin Database Tool to store and display time-series data
Description :
RRD is the Acronym for Round Robin Database. RRD is a system to store and
display time-series data (i.e. network bandwidth, machine-room temperature,
server load average). It stores the data in a very compact way that will not
expand over time, and it presents useful graphs by processing the data to
enforce a certain data density. It can be used either via simple wrapper
scripts (from shell or Perl) or via frontends that poll network devices and
put a friendly user interface on it.
```

9.如果没问题为rpm包签名吧，防止有人恶意更改    ##这个先不写了，有点晚了，以后补上

到此整个流程完毕。下面来说说其中最最重要的spec的格式，先说最简单的,最容易实现的
```
vi tengine.spec 
     
### 0.define section               #自定义宏段，这个不是必须的 
### %define nginx_user nginx       #这是我们自定义了一个宏，名字为nginx_user值为nginx，%{nginx_user}引用 
     
### 1.The introduction section                     #介绍区域段 
     
Name:           tengine                            #名字为tar包的名字 
Version:        1.4.2                              #版本号，一定要与tar包的一致哦 
Release:        1%{?dist}                          #释出号，也就是第几次制作rpm 
Summary:        tengine from TaoBao                #软件包简介，最好不要超过50字符 
     
Group:          System Environment/Daemons         #组名，可以通过less /usr/share/doc/rpm-4.8.0/GROUPS 选择合适组 
License:        GPLv2                              #许可，GPL还是BSD等  
URL:            http://laoguang.blog.51cto.com     #可以写一个网址 
Packager:       Laoguang <ibuler@qq.com>           #制作者<邮箱>
Vendor:         TaoBao.com                         #提供商
Source0:        %{name}-%{version}.tar.gz
#Source1:        nginx.ini                         #在install步引入此文件
#定义用到的source，也就是你收集的，可以用宏来表示，也可以直接写名字，上面定义的内容都可以像上面那样引用 
#patch0:            a.patch                        #如果需要补丁，依次写 
BuildRoot:      %_topdir/BUILDROOT         
#这个是软件make install 的测试安装目录，也就是测试中的根，我们不用默认的，我们自定义，
#我们可以来观察生成了哪此文件，方便写file区域 
BuildRequires:  gcc,make                           #制作过程中用到的软件包
# BuildRequires: libfastcommon-devel >= 1.0.43     #示例
Requires:       pcre,pcre-devel,openssl,chkconfig  #软件运行需要的软件包，也可以指定最低版本如 bash >= 1.1.1
#Requires(pre):     shadow-utils                   #执行%pre脚本段的时候依赖的软件包
#Requires(post):    chkconfig                      #执行%post脚本段的时候依赖的软件包
#Requires(preun):   chkconfig,initscripts          #执行preun脚本段的时候依赖的软件包
#Requires(postun):  initscripts                    #执行postun脚本段的时候依赖的软件包
#Provides:          webserver                      #提供的功能，可省略，内容自定义

%description                                       #软件包描述，尽情的写吧 
It is a Nginx from Taobao.                         #描述内容 
     
###  2.The Prep section 准备阶段,主要目的解压source并cd进去 
     
%prep                                              #这个宏开始 
%setup -q                                          #这个宏的作用静默模式解压并cd 
#%patch0 -p1                                       #如果需要在这打补丁，依次写 
     
###  3.The Build Section 编译制作阶段，主要目的就是编译 
%build 
./configure \                                      #./configure 也可以用%configure来替换 
  --prefix=/usr \                                  #下面的我想大家都很熟悉 
  --sbin-path=/usr/sbin/nginx \ 
  --conf-path=/etc/nginx/nginx.conf \ 
  --error-log-path=/var/log/nginx/error.log \ 
  --http-log-path=/var/log/nginx/access.log \ 
  --pid-path=/var/run/nginx/nginx.pid  \ 
  --lock-path=/var/lock/nginx.lock \ 
  --user=nginx \ 
  --group=nginx \ 
  --with-http_ssl_module \ 
  --with-http_flv_module \ 
  --with-http_stub_status_module \ 
  --with-http_gzip_static_module \ 
  --http-client-body-temp-path=/var/tmp/nginx/client/ \ 
  --http-proxy-temp-path=/var/tmp/nginx/proxy/ \ 
  --http-fastcgi-temp-path=/var/tmp/nginx/fcgi/ \ 
  --http-uwsgi-temp-path=/var/tmp/nginx/uwsgi \ 
  --http-scgi-temp-path=/var/tmp/nginx/scgi \ 
  --with-pcre 
make %{?_smp_mflags}                               #make后面的意思是：如果就多处理器的话make时并行编译 
     
###  4.Install section  安装阶段 
%install                                
rm -rf %{buildroot}                                #先删除原来的安装的，如果你不是第一次安装的话 
make install DESTDIR=%{buildroot} 
#DESTDIR指定安装的目录，而不是真实的安装目录，%{buildroot}你应该知道是指的什么了 
# %{__install} -p -d -m 0755 %{buildroot}/var/log/nginx                         #创建空目录
# %{__install} -p -D -m 0755 %{SOURCE1} %{buildroot}/etc/rc.d/init.d/nginx      #将文件拷贝到路径下

###  4.1 scripts section #没必要可以不写 
%pre                                                 #rpm安装前制行的脚本 
if [ $1 == 1 ];then                                  #$1==1 代表的是第一次安装，2代表是升级，0代表是卸载 
        /usr/sbin/useradd -r nginx 2> /dev/null      ##其实这个脚本写的不完整
fi 

%post                                                #安装后执行的脚本 
if [ $1 == 1]; then
        /sbin/chkconfig --add %{name}
fi

%preun                                               #卸载前执行的脚本 
if [ $1 == 0 ];then 
        /usr/sbin/userdel -r nginx 2> /dev/null 
fi 

if [ $1 == 0 ]; then
        /sbin/service %{name} stop > /dev/null 2>&1
        /sbin/chkconfig --del %{name}
fi

%postun                                              #卸载后执行的脚本 


###  5.clean section 清理段,删除buildroot 

%clean 
rm -rf %{buildroot} 
         
###  6.file section 要包含的文件 
%files  
%defattr (-,root,root,0755)                           #设定默认权限，如果下面没有指定权限，则继承默认 
/etc/                                                 #下面的内容要根据你在%{rootbuild}下生成的来写     
/usr/ 
/var/
# %dir /var/run/nginx                                 #生成空目录
# %dir /var/log/nginx                                 #生成空目录
# %dir /etc/nginx                                     #生成空目录
# %doc API CHANGES COPYING CREDITS README axelrc.examlpe 文档文件会被安装到 /usr/share/doc/生成当前软件包名+版本号名
# %config(noreplace) %{_sysconfdir}/axelrc 配置文件，noreplace不替换原来的
# /usr/local/bin/axel 包含的所有文件，可以直接写目录
# %attr (0755,root,root) /etc/rc.d/init.d/nginx 定义自定义资源的属性，不指定则继承%defattr #包含SOURCE1步骤在install步骤中拷贝的文件

###  7.chagelog section  改变日志段 
%changelog 
*  Fri Dec 29 2012 laoguang <ibuler@qq.com> - 1.0.14-1 
- Initial version 
```

https://github.com/happyfish100/libfastcommon/blob/master/libfastcommon.spec

https://github.com/happyfish100/fastdfs/blob/master/fastdfs.spec

三.RPM包制作拓展

下面我们来拓展一下，比如：我们想为tengine增加控制脚本，可以通过start|stop控制，我们还想更换一下默认的首页index.html，默认的fastcgi_params是不能直接连接php的，所以我们替换为新的配置文件，我们也可以用设置好的nginx.conf替换原来的nginx.conf。基于上述步骤下面继续

1.把修改后的首页文件index.html,控制脚本init.nginx,fastCGI配置文件fastcgi_params，Nginx配置文件nginx.conf 放到SOURCES中 。 
```
[ibuler@ng1 rpmbuild]$ ls SOURCES/ 
fastcgi_params  index.html  init.nginx  nginx.conf  tengine-1.4.2.tar.gz 
```
2 编辑tengine.spec，修改

2.1 介绍区域的SOURCE0下增加如下
```
Source0:        %{name}-%{version}.tar.gz 
Source1:        index.html 
Source2:        init.nginx 
Source3:        fastcgi_params 
Source4:        nginx.conf 
```
2.2 安装区域增加如下
```
make install DESTDIR=%{buildroot} 
%{__install} -p -D %{SOURCE1} %{buildroot}/usr/html/index.html  #%{__install}这个宏代表install命令
%{__install} -p -D -m 0755 %{SOURCE2} %{buildroot}/etc/rc.d/init.d/nginx 
%{__install} -p -D %{SOURCE3} %{buildroot}/etc/nginx/fastcgi_params 
%{__install} -p -D %{SOURCE4} %{buildroot}/etc/nginx/nginx.conf 
```
2.3 脚本区域增加如下
```
%post 
if [ $1 == 1 ];then 
        /sbin/chkconfig --add nginx 
fi 
```
2.4 %file区域增加如下
```
%files 
%defattr (-,root,root,0755) 
/etc/ 
/usr/ 
/var/ 
%config(noreplace) /etc/nginx/nginx.conf     #%config表明这是个配置文件noplace表明不能替换
%config(noreplace) /etc/nginx/fastcgi_params 
%doc /usr/html/index.html                    #%doc表明这个是文档
%attr(0755,root,root) /etc/rc.d/init.d/nginx #%attr后面的是权限，属主，属组
```
3. 生成rpm文件测试
```
rpmbuild -ba tengine.spec 
```
4. 安装测试 

到此RPM包制作完毕，你可以根据你的需求制作RPM包吧。

四.RPM包签名

1.生成GPG签名密钥，我用的是root用户
```
gpg --gen-key 
     
Your selection?1<Enter>                       ##默认即可
What keysize do you want? (2048) 1024<Enter>  ##密钥长度
Key is valid for? (0) 1y<Enter>  ##有效期
Is this correct? (y/N) y<Enter>  ##确认
Real name: LaoGuang<Enter>       ##密钥名称
Email address: ibuler@qq.com<Enter>  ##邮件
Comment: GPG-RPM-KEY<Enter>      ##备注
Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O<ENTER> 
Enter passphrase  OK <Enter>     ##使用空密码，也可以输入                              
<Take this one anyway> <Enter> 
<Take this one anyway> <Enter> 
```
有时可能因为随机数不够导致卡在那里，这时候你就yum 安装几个包组，马上就够了。

2.查看成生的密钥
```
[root@ng1 dev]# gpg --list-keys 
/root/.gnupg/pubring.gpg 
------------------------ 
pub   1024R/49C99488 2012-11-28 [expires: 2013-11-28] 
uid                  LaoGuang (GPG-RPM-KEY) <ibuler@qq.com> 
sub   1024R/69BA199D 2012-11-28 [expires: 2013-11-28] 
```
3.导出公钥以供大家使用验证
```
gpg --export -a "LaoGuang" > RPM-GPG-KEY-LaoGuang 
```
4.编缉 .rpmmacros说明我们用哪一个密钥加密,我们用root加密的那就在/root下编辑
```
vi ~/.rpmmacros 
%_gpg_name LaoGuang 
```
5.为rpm包加签名
```
 rpm --addsign tengine-1.4.2-1.el6.x86_64.rpm  
Enter pass phrase:       ##输入密钥
Pass phrase is good. 
tengine-1.4.2-1.el6.x86_64.rpm: 
```
到此签名添加成功，下面来验证

6.讲刚才导出的公钥导入rpm中
```
rpm --import RPM-GPG-KEY-LaoGuang 
```
7.验证
```
rpm --checksig tengine-1.4.2-1.el6.x86_64.rpm  
     
tengine-1.4.2-1.el6.x86_64.rpm: rsa sha1 (md5) pgp md5 OK 
```


CentOS 7 定制 OpenSSL RPM 包
===

一、环境准备
---
1.1 安装RPM打包、测试必备开发工具
```
$ yum install -y rpm-build rpmlint rpmdevtools
```

1.2 安装打包、编译所需的依赖软件
```
$ yum install -y gcc gcc-c++ make perl perl-WWW-Curl
```
 
二、制作 OpenSSL 的 RPM 包
---
注意：

切记！不要使用 root 用户来执行打包操作。因为这十分危险，所有二进制文件都会在打包前安装至系统中，因此您应该以普通用户身份打包，以防止系统被破坏。

2.1 配置 rpmbuild 工作目录
```
$ mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

$ echo "%_topdir %{getenv:HOME}/rpmbuild" > ~/.rpmmacros
```

2.2 下载源码包到 ~/rpmbuild/SOURCES 目录
```
$ wget -O ~/rpmbuild/SOURCES/openssl-1.1.1k.tar.gz https://www.openssl.org/source/openssl-1.1.1k.tar.gz
```

2.3 编写 openssl 1.1.1k 软件库包的spec文件
```
$ vim ~/rpmbuild/SPECS/openssl.spec

Name:       openssl     
Version:    1.1.1k
Release:    1%{?dist}
Summary:    Utilities from the general purpose cryptography library with TLS implementation
Group:      System Environment/Libraries
License:    GPLv2+
URL:        https://www.openssl.org/
Source0:    https://www.openssl.org/source/%{name}-%{version}.tar.gz
BuildRequires:  make gcc perl perl-WWW-Curl 
Requires:   %{name} = %{version}-%{release}
BuildRoot:  %_topdir/BUILDROOT

%global openssldir /usr/openssl

%description
The OpenSSL toolkit provides support for secure communications between
machines. OpenSSL includes a certificate management tool and shared
libraries which provide various cryptographic algorithms and
protocols.

%prep
%setup -q

%build
./config --prefix=%{openssldir} --openssldir=%{openssldir}
make %{?_smp_mflags}

%install
[ "%{buildroot}" != "/" ] && %{__rm} -rf %{buildroot}
%make_install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_libdir}
ln -sf %{openssldir}/lib/libssl.so.1.1 %{buildroot}%{_libdir}
ln -sf %{openssldir}/lib/libcrypto.so.1.1 %{buildroot}%{_libdir}
ln -sf %{openssldir}/bin/openssl %{buildroot}%{_bindir}

%clean
[ "%{buildroot}" != "/" ] && %{__rm} -rf %{buildroot}

%files
%{openssldir}
%defattr(-,root,root)
%{_bindir}/openssl
%{_libdir}/libcrypto.so.1.1
%{_libdir}/libssl.so.1.1

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%changelog
* Sat May 08 2021 Hebin Wan <wanhebin@outlook.com> - 1.1.1k
- Rebuilt for https://www.openssl.org/source/openssl-1.1.1k.tar.gz 
```

2.4 使用 rpmlint 测试

为避免常见错误，请先使用 rpmlint 查找 SPEC 文件的错误：
```
$ rpmlint ~/rpmbuild/SPECS/openssl.spec
0 packages and 1 specfiles checked; 0 errors, 0 warnings.
```
如果返回错误/警告，使用 "-i" 选项查看更详细的信息。

2.5 从 SPEC 构建 RPM 包
```
$ rpmbuild -D "version 1.1.1k" -ba ~/rpmbuild/SPECS/openssl.spec
```
- -ba 构建源代码rpm包和二进制rpm包
- -bb 只构建二进制rpm包
- -bs 只构建源代码rpm包
- -bp 执行至％prep阶段（解压源并应用补丁）
- -bc 执行至％build阶段（％prep，然后编译）
- -bi 执行至％install阶段（％prep，％build，然后安装）
- -bl 验证％files部分，查看文件是否存在

- 构建完成后，有类似下面的返回内容时，说明 RPM 包构建成功了
```
Checking for unpackaged file(s): /usr/lib/rpm/check-files /root/rpmbuild/BUILDROOT/openssl-1.1.1k-1.el7.centos.x86_64
Wrote: /root/rpmbuild/SRPMS/openssl-1.1.1k-1.el7.centos.src.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/openssl-1.1.1k-1.el7.centos.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/openssl-debuginfo-1.1.1k-1.el7.centos.x86_64.rpm
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.vMwlta
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd openssl-1.1.1k
+ '[' /root/rpmbuild/BUILDROOT/openssl-1.1.1k-1.el7.centos.x86_64 '!=' / ']'
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/openssl-1.1.1k-1.el7.centos.x86_64
+ exit 0
```

- 查看构建成功的 RPM 包
```
$ tree ~/rpmbuild/*RPMS
/root/rpmbuild/RPMS
└── x86_64
    ├── openssl-1.1.1k-1.el7.centos.x86_64.rpm
    └── openssl-debuginfo-1.1.1k-1.el7.centos.x86_64.rpm
/root/rpmbuild/SRPMS
└── openssl-1.1.1k-1.el7.centos.src.rpm

1 directory, 3 files
```

在RPMS文件夹下生成了 RPM 包，在 x86_64 下，表示所应用的架构，由于没有指定arch为 noarch ，所以默认用本机架构。在SRPMS文件夹下生成了源码 RPM 包。

2.6 使用 rpmlint 测试已构建的 RPM 包

rpmlint 用于检查 SPEC/RPM/SRPM 是否存在错误。你需要在发布软件包之前，解决这些警告。此页面 提供一些常见问题的解释。
```
$ rpmlint ~/rpmbuild/SPECS/openssl.spec \
          ~/rpmbuild/RPMS/x86_64/openssl-1.1.1k-1.el7.x86_64.rpm \
          ~/rpmbuild/SRPMS/openssl-1.1.1k-1.el7.src.rpm
```
一般情况下，检测到的都是一些WARN信息，不影响软件使用，可以忽略。如果有ERROR信息，或许也不影响使用，但建议按照提示进行调整、修复。

 
三、安装升级 OpenSSL
---
一般情况下，系统都已经有openssl了，所以我们直接升级即可。

注意：

切记！在做openssl升级时，请先从测试机中操作，升级后，确定没有任何问题时，在根据线上环境陆续升级。

3.1 检查系统当前OpenSSL版本

查看当前系统中openssl的版本
```
$ openssl version
OpenSSL 1.0.2k-fips  26 Jan 2017
```

卸载openssl
```
$ rpm -e openssl --nodeps
```

3.2 升级OpenSSL版本

安装我们刚刚打包好的openssl 1.1.1k版本
```
$ rpm -ivh ~/rpmbuild/RPMS/x86_64/openssl-1.1.1k-2.el7.x86_64.rpm --nodeps
Preparing...                          ################################# [100%]
Updating / installing...
   1:openssl-1.1.1k-2.el7             ################################# [100%]
```

再次查看系统中openssl版本
```
$ openssl version
OpenSSL 1.1.1k  25 Mar 2021
```
很幸运，成功升级！
