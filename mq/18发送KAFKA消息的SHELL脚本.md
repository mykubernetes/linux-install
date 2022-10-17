# 脚本内容

下面是脚本sendmessage.sh的内容，带有详细注释：
```shell
#!/bin/sh

#响应Ctrl+C中断
trap 'onCtrlC' INT
function onCtrlC () {
    echo 'Ctrl+C is captured'
    exit 1
}

#kafka所在目录
kafkaPath=/Users/zhaoqin/temp/202003/07/kafka_2.11-2.0.1
#broker
brokerlist=192.168.50.135:31090,192.168.50.135:31091,192.168.50.135:31092
#kafka的topic
topic=test001
#消息总数
totalNum=10000
#一次批量发送的消息数
batchNum=100
#该标志为true，表示文件中的第一条记录
firstLineFlag='true'

for ((i=1; i<=${totalNum}; i ++))  
do  
	#消息内容，请按照实际需要自行调整
    messageContent=batchmessage-${i}-`date "+%Y-%m-%d %H:%M:%S"`

    #如果是每个批次的第一条，就要将之前的内容全部覆盖，如果不是第一条就追加到尾部
    if [ 'true' == ${firstLineFlag} ] ; then
      echo ${messageContent} > batchMessage.txt

      #将标志设置为false，这样下次写入的时候就不会清理已有内容了
      firstLineFlag='false'
    else
      echo ${messageContent} >> batchMessage.txt
    fi

    #取余数
    modVal=$(( ${i} % ${batchNum} ))

    #如果达到一个批次，就发送一次消息
    if [ ${modVal} = 0 ] ; then
      #在控制台显示进度
      echo “${i} of ${totalNum} sent”

      #批量发送消息，并且将控制台返回的提示符重定向到/dev/null
      cat batchMessage.txt | ${kafkaPath}/bin/kafka-console-producer.sh --broker-list ${brokerlist} --sync --topic ${topic} | > /dev/null

      #将标志设置为true，这样下次写入batchMessage.txt时，会将文件中的内容先清除掉
      firstLineFlag='true'
    fi
done
```
- kafkaPath是客户端电脑上kafka安装的路径，请按实际情况修改；
- brokerlist是远程kafka信息，请按实际情况修改；
- topic是要发送的消息Topic，必须是已存在的Topic；
- totalNum是要发送的消息总数；
- batchNum是一个批次的消息条数，如果是100，表示每攒齐100条消息就调用一次kafka的shell，然后逐条发送；
- messageContent是要发送的消息的内容，请按实际需求修改；

# 运行脚本

- 1、给脚本可执行权限：chmod a+x sendmessage.sh
- 2、执行：./sendmessage.sh
- 3、每到一百条会有一次进度提醒：
```
(base) zhaoqindeMBP:07 zhaoqin$ ./sendmessage5.sh
“100 of 10000 sent”
“200 of 10000 sent”
“300 of 10000 sent”
“400 of 10000 sent”
“500 of 10000 sent”
“600 of 10000 sent”
“700 of 10000 sent”
“800 of 10000 sent”
...
```

# 用shell命令消息此消息：
```
./kafka-console-consumer.sh \
--bootstrap-server 192.168.50.135:31090 \
--topic test001 \
--from-beginning
```
