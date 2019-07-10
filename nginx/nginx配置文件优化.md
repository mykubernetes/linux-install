1、Nginx gzip
---
```
http{
gzip on;
gzip_min_length  1k;
gzip_buffers     4 32k;
gzip_http_version 1.1;
gzip_comp_level 9;
gzip_types  text/css text/xml application/javascript; 
gzip_vary on;
}
```
- gzip on; #开启gzip压缩功能
- gzip_min_length 1k; #设置允许压缩的页面最小字节数，页面字节数从header头的Content-Length中获取，默认值是0，表示不管页面多大都进行压缩，建议设置成大于1K，如果小于1K可能会越压越大
- gzip_buffers 4 16k; #压缩缓冲区大小，表示申请4个单位为16K的内存作为压缩结果流缓存，默认是申请与原始是数据大小相同的内存空间来存储gzip压缩结果；
- gzip_http_version 1.1 #压缩版本（默认1.1 前端为squid2.5时使用1.0）用于设置识别HTTP协议版本，默认是1.1，目前大部分浏览器已经支持GZIP压缩，使用默认即可。
- gzip_comp_level 2; #压缩比率，用来指定GZIP压缩比，1压缩比最小，处理速度最快；9压缩比最大，传输速度快，但处理最慢，也消耗CPU资源
- gzip_types  text/css text/xml application/javascript;  #用来指定压缩的类型，“text/html”类型总是会被压缩，这个就是HTTP原理部分讲的媒体类型。
- gzip_vary on; #vary hear支持，该选项可以让前端的缓存服务器缓存经过GZIP压缩的页面，例如用缓存经过Nginx压缩的数据。


2、Nginx expires
---
Nginx expires的功能就是为用户访问的网站内容设定一个国企时间，当用户第一次访问到这些内容时，会把这样内容存储在用户浏览器本地，这样用户第二次及此后继续访问网站，浏览器会检查加载缓存在用户浏览器本地的内容，就不会去服务器下载了。直到缓存的内容过期或被清除为止。  

Nginx expires 功能优点  
1.Expires可以降低网站的带宽，节约成本。  
2.加快用户访问网站的速度，提升了用户访问体验。  
3.服务器访问量降低了，服务器压力就减轻了，服务器成本也会降低，甚至可以解决人力成本。  
对于几乎所有Web来说，这是非常重要的功能之一，Apache服务也由此功能。  

1）根据文件扩展名进行判断，添加expires功能范例。  
```
   location ~.*\.(gif|jpg|jpeg|png|bmp|swf)$
       {
          expires 3650d;
      }
```  

2）根据URI中的路径（目录）进行判断，添加expires功能范例。  
```
location ~^/(images|javascript|js|css|flash|media|static)/ {
  expires 360d;
}
```  


