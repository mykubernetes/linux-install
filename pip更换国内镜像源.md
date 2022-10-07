由于Python pip 默认源为国外，因此pip install 的时候蜗牛速度。可以将其更改为国内镜像源。

常见的国内优质镜像源
```
阿里云 http://mirrors.aliyun.com/pypi/simple/

中国科技大学 https://pypi.mirrors.ustc.edu.cn/simple/

豆瓣(douban) http://pypi.douban.com/simple/

清华大学 https://pypi.tuna.tsinghua.edu.cn/simple/

中国科学技术大学 http://pypi.mirrors.ustc.edu.cn/simple/

华中理工大学：http://pypi.hustunique.com/

山东理工大学：http://pypi.sdutlinux.org/
```

# 1. 临时使用

例如临时使用阿里源
```
pip install 你要安装的包 -i https://pypi.tuna.tsinghua.edu.cn/simple/
```

但是可能出现异常问题，解决办法就是在最后加一段
```
pip install jupyter -i http://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn
```

# 2. 永久更新指令

升级 pip 到最新的版本后进行配置：
```
pip install pip -U
pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/
```

