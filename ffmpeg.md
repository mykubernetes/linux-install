
官网http://ffmpeg.org/

- ffmpeg ：可用于格式转换、解码或电视卡即时编码等
- ffsever个 ：一个 HTTP  多媒体即时广播串流服务器；
- ffplay ：是一个简单的播放器，使用 ffmpeg  库解析和解码，通过 SDL  显示


1、编辑脚本
```
#!/bin/bash

####################################
#    将视频文件转换为rtsp流        #
####################################

cur_path=`pwd`
conf_path=$cur_path/conf

if [ ! -d $conf_path ];then
    mkdir -p $conf_path
    echo "创建配置文件目录:$conf_path"
fi

conf_file=$conf_path/$2

if [ $1x == "start"x ]; then
    conf_param="RTSPPort $2\nRTSPBindAddress 0.0.0.0\n\n<Stream rtsp>\n    File "$3"\n    Format rtp\n</Stream>"
    echo -e $conf_param > $conf_file
    sleep 1
    nohup ./ffserver -f $conf_file > /dev/null  2>&1 &
    ipaddr=$(ip addr | grep -v docker |  awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')
    rtsp_addr=rtsp://$ipaddr:$2/rtsp
    echo RTSP URL: $rtsp_addr
    video_time=`./ffmpeg -i $3 2>&1 | grep 'Duration' | cut -d ' ' -f 4 | sed s/,//`
    echo Duration: $video_time
elif [ $1x == "stop"x ]; then
    if [ -f $conf_file ]; then
        rm -rf $conf_file
    fi
    #if [ -f $3 ]; then
        #rm -rf $3
    #fi
    pid=`ps axu | grep 'ffserver' | grep $2 | grep -v 'grep' | awk '{print $2}'`
    if [ ! -z "$pid" ]; then
        kill -9 $pid
        echo "Stoped transform video to rtsp: $3"
    fi
else
    echo "usage: ./rtsp_cmd.sh start port videoPath "
    echo "usage: ./rtsp_cmd.sh stop  port videoPath "
    echo "   eg: ./rtsp_cmd.sh start 19999 /admin/ffserver/video_src/20181127.mp4"
    echo "   eg: ./rtsp_cmd.sh stop  19999 /admin/ffserver/video_src/20181127.mp4"
fi
```
2、转换视频格式
```
./ffmpeg -i 201882513743.avi -c:v libx264 -bf 0 201882513743.mp4
```

3、本地启动播放器
```
./rtsp_cmd.sh start 19999 /admin/ffserver/video_src/20181127.mp4
```



FFmpeg  本地文件
```
ffmpeg -re -i ande10.mp4 -vcodec libx264 -acodec aac -f flv rtmp://192.168.0.104:1935/hls1/test1
```

FFmpeg  摄像头推流
```
ffmpeg -f dshow -i video="Integrated Camera" -vcodec libx264 -preset:v ultrafast -tune:vzerolatency -f flv rtmp://192.168.0.104/hls1/test
```


ffmpeg格式转换
```
1、H264视频转ts视频流
ffmpeg -i video.h264 -vcodec copy -f mpegts video.ts

2、H264视频转mp4
ffmpeg -i video.h264 -vcodec copy -f mp4 video.mp4

3、ts视频转mp4
ffmpeg -i video.ts -acodec copy -vcodec copy -f mp4 video.mp4

4、mp4视频转flv
ffmpeg -i video.mp4 -acodec copy -vcodec copy -f flv video.flv 

5、转换文件为3GP格式 
ffmpeg -y -i video.mpeg -bitexact -vcodec h263 -b 128 -r 15 -s 176x144 -acodec aac -ac 2 -ar 22500 -ab 24 -f 3gp video.3gp

6、转换文件为3GP格式 v2
ffmpeg -y -i videot.wmv -ac 1 -acodec libamr_nb -ar 8000 -ab 12200 -s 176x144 -b 128 -r 15 video.3gp
```
