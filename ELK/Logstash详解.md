# logstash可以接收不同类型的元数据（input）

1.文件类型（file)
```
input{
    file{
        #path属性接受的参数是一个数组，其含义是标明需要读取的文件位置
        path => [‘pathA’，‘pathB’]
        #表示多就去path路径下查看是够有新的文件产生。默认是15秒检查一次。
        discover_interval => 15
        #排除那些文件，也就是不去读取那些文件
        exclude => [‘fileName1’,‘fileNmae2’]
        #被监听的文件多久没更新后断开连接不在监听，默认是一个小时。
        close_older => 3600
        #在每次检查文件列 表的时候， 如果一个文件的最后 修改时间 超过这个值， 就忽略这个文件。 默认一天。
        ignore_older => 86400
        #logstash 每隔多 久检查一次被监听文件状态（ 是否有更新） ， 默认是 1 秒。
        stat_interval => 1
        #sincedb记录数据上一次的读取位置的一个index
        sincedb_path => ’$HOME/. sincedb‘
        #logstash 从什么 位置开始读取文件数据， 默认是结束位置 也可以设置为：beginning 从头开始
        start_position => ‘beginning’
        #注意：这里需要提醒大家的是，如果你需要每次都从同开始读取文件的话，关设置start_position => beginning是没有用的，你可以选择sincedb_path 定义为 /dev/null
    }           
}
```

2.数据库类型
```
input{
    jdbc{
    #jdbc sql server 驱动,各个数据库都有对应的驱动，需自己下载
    jdbc_driver_library => "/etc/logstash/driver.d/sqljdbc_2.0/enu/sqljdbc4.jar"
    #jdbc class 不同数据库有不同的 class 配置
    jdbc_driver_class => "com.microsoft.sqlserver.jdbc.SQLServerDriver"
    #配置数据库连接 ip 和端口，以及数据库   
    jdbc_connection_string => "jdbc:sqlserver://200.200.0.18:1433;databaseName=test_db"
    #配置数据库用户名
    jdbc_user =>   
    #配置数据库密码
    jdbc_password =>
    #上面这些都不重要，要是这些都看不懂的话，你的老板估计要考虑换人了。重要的是接下来的内容。
    # 定时器 多久执行一次SQL，默认是一分钟
    # schedule => 分 时 天 月 年  
    # schedule => * 22  *  *  * 表示每天22点执行一次
    schedule => "* * * * *"
    #是否清除 last_run_metadata_path 的记录,如果为真那么每次都相当于从头开始查询所有的数据库记录
    clean_run => false
    #是否需要记录某个column 的值,如果 record_last_run 为真,可以自定义我们需要表的字段名称，
    #此时该参数就要为 true. 否则默认 track 的是 timestamp 的值.
    use_column_value => true
    #如果 use_column_value 为真,需配置此参数. 这个参数就是数据库给出的一个字段名称。当然该字段必须是递增的，可以是 数据库的数据时间这类的
    tracking_column => create_time
    #是否记录上次执行结果, 如果为真,将会把上次执行到的 tracking_column 字段的值记录下来,保存到 last_run_metadata_path 指定的文件中
    record_last_run => true
    #们只需要在 SQL 语句中 WHERE MY_ID > :last_sql_value 即可. 其中 :last_sql_value 取得就是该文件中的值
    last_run_metadata_path => "/etc/logstash/run_metadata.d/my_info"
    #是否将字段名称转小写。
    #这里有个小的提示，如果你这前就处理过一次数据，并且在Kibana中有对应的搜索需求的话，还是改为true，
    #因为默认是true，并且Kibana是大小写区分的。准确的说应该是ES大小写区分
    lowercase_column_names => false
    #你的SQL的位置，当然，你的SQL也可以直接写在这里。
    #statement => SELECT * FROM tabeName t WHERE  t.creat_time > :last_sql_value
    statement_filepath => "/etc/logstash/statement_file.d/my_info.sql"
    #数据类型，标明你属于那一方势力。单了ES哪里好给你安排不同的山头。
    type => "my_info"
    }
    #注意：外载的SQL文件就是一个文本文件就可以了，还有需要注意的是，一个jdbc{}插件就只能处理一个SQL语句，
    #如果你有多个SQL需要处理的话，只能在重新建立一个jdbc{}插件。
}
```

3.可以同时启用多个端口，用来接收各个来源的log(搭配filebeat使用)
```
input {
  beats {
    id => "51niux_resin_log"
    port => 6043
    
  }
  beats{
    port => 6044
  }
 
  beats {
    type => 51niux_nginx_log
    id => "v3"
    port => 6045
  }
}
```

# logstash 对数据的过滤（filter）

1、grok插件

grok插件有非常强大的功能，他能匹配一切数据，但是他的性能和对资源的损耗同样让人诟病。
```
filter{
    
    grok{
        #只说一个match属性，他的作用是从message 字段中吧时间给抠出来，并且赋值给另个一个字段logdate。
        #首先要说明的是，所有文本数据都是在Logstash的message字段中中的，我们要在过滤器里操作的数据就是message。
        #第二点需要明白的是grok插件是一个十分耗费资源的插件，这也是为什么我只打算讲解一个TIMESTAMP_ISO8601正则表达式的原因。
        #第三点需要明白的是，grok有超级多的预装正则表达式，这里是没办法完全搞定的，也许你可以从这个大神的文章中找到你需要的表达式
        #http://blog.csdn.net/liukuan73/article/details/52318243
        #但是，我还是不建议使用它，因为他完全可以用别的插件代替，当然，对于时间这个属性来说，grok是非常便利的。
        match => ['message','%{TIMESTAMP_ISO8601:logdate}']
    }
 
}
```
2、mutate插件

mutate插件是用来处理数据的格式的，你可以选择处理你的时间格式，或者你想把一个字符串变为数字类型（当然需要合法），同样的你也可以返回去做。可以设置的转换类型 包括： "integer"， "float" 和 "string"。
```
filter {
    mutate {
        #接收一个数组，其形式为value，type
        #需要注意的是，你的数据在转型的时候要合法，你总是不能把一个‘abc’的字符串转换为123的。
        convert => [
                    #把request_time的值装换为浮点型
                    "request_time", "float"，
                    #costTime的值转换为整型
                    "costTime", "integer"
                    ]
    }
}
```

3、ruby插件

官方对ruby插件的介绍是——无所不能。ruby插件可以使用任何的ruby语法，无论是逻辑判断，条件语句，循环语句，还是对字符串的操作，对EVENT对象的操作，都是极其得心应手的。
```
filter {
    ruby {
        #ruby插件有两个属性，一个init 还有一个code
        #init属性是用来初始化字段的，你可以在这里初始化一个字段，无论是什么类型的都可以，这个字段只是在ruby{}作用域里面生效。
        #这里我初始化了一个名为field的hash字段。可以在下面的coed属性里面使用。
        init => [field={}]
        #code属性使用两个冒号进行标识，你的所有ruby语法都可以在里面进行。
        #下面我对一段数据进行处理。
        #首先，我需要在把message字段里面的值拿到，并且对值进行分割按照“|”。这样分割出来的是一个数组（ruby的字符创处理）。
        #第二步，我需要循环数组判断其值是否是我需要的数据（ruby条件语法、循环结构）
        #第三步，我需要吧我需要的字段添加进入EVEVT对象。
        #第四步，选取一个值，进行MD5加密
        #什么是event对象？event就是Logstash对象，你可以在ruby插件的code属性里面操作他，可以添加属性字段，可以删除，可以修改，同样可以进行树脂运算。
        #进行MD5加密的时候，需要引入对应的包。
        #最后把冗余的message字段去除。
        code => "
            array=event。get('message').split('|')
            array.each do |value|
                if value.include? 'MD5_VALUE'
                    then 
                        require 'digest/md5'
                        md5=Digest::MD5.hexdigest(value)
                        event.set('md5',md5)
                end
                if value.include? 'DEFAULT_VALUE'
                    then
                        event.set('value',value)
                end
            end
             remove_field=>"message"
        "
    }
```

4、date插件

这里需要合前面的grok插件剥离出来的值logdate配合使用（当然也许你不是用grok去做）。
```
filter{
    date{
        #还记得grok插件剥离出来的字段logdate吗？就是在这里使用的。你可以格式化为你需要的样子，至于是什么样子。就得你自己取看啦。
        #为什什么要格式化？
        #对于老数据来说这非常重要，应为你需要修改@timestamp字段的值，如果你不修改，你保存进ES的时间就是系统但前时间（+0时区）
        #单你格式化以后，就可以通过target属性来指定到@timestamp，这样你的数据的时间就会是准确的，这对以你以后图表的建设来说万分重要。
        #最后，logdate这个字段，已经没有任何价值了，所以我们顺手可以吧这个字段从event对象中移除。
        match=>["logdate","dd/MMM/yyyy:HH:mm:ss Z"]
        target=>"@timestamp"
        remove_field => 'logdate'
        #还需要强调的是，@timestamp字段的值，你是不可以随便修改的，最好就按照你数据的某一个时间点来使用，
        #如果是日志，就使用grok把时间抠出来，如果是数据库，就指定一个字段的值来格式化，比如说："timeat", "%{TIMESTAMP_ISO8601:logdate}"
        #timeat就是我的数据库的一个关于时间的字段。
        #如果没有这个字段的话，千万不要试着去修改它。
 
    }
}
```

5、json插件

这个插件也是极其好用的一个插件，现在我们的日志信息，基本都是由固定的样式组成的，我们可以使用json插件对其进行解析，并且得到每个字段对应的值。
```
filter{
    #source指定你的哪个值是json数据。
    json {
         source => "value"
    }
    #注意：如果你的json数据是多层的，那么解析出来的数据在多层结里是一个数组，你可以使用ruby语法对他进行操作，最终把所有数据都装换为平级的。
}
```

对应的解决方案为：
```
ruby{
                code=>"
                  kv=event.get('content')[0]
                  kv.each do |k,v|
                  event.set(k,v)
                  end"
                  remove_field => ['content','value','receiptNo','channelId','status']
            }
```

Logstash filter组件的插件基本介绍到这里了，这里需要明白的是：
add_field、remove_field、add_tag、remove_tag 是所有 Logstash 插件都有。相关使用反法看字段名就可以知道。不如你也试试吧。。。。

# 输出（output）

Logstash的output模块,相比于input模块来说是一个输出模块,output模块集成了大量的输出插件,可以输出到指定文件,也可输出到指定的网络端口,当然也可以输出数据到ES.在这里我只介绍如何输出到ES,至于如何输出到端口和指定文件,有很多的文档资料可查找.
```
  elasticsearch{  
    hosts=>["172.132.12.3:9200"]  
    action=>"index"  
    index=>"indextemplate-logstash"  
    #document_type=>"%{@type}"  
    document_id=>"ignore"  
      
    template=>"/opt/logstash-conf/es-template.json"  
    template_name=>"es-template.json"  
    template_overwrite=>true       
    }
```
action=>”index” #es要执行的动作 index, delete, create, update
index:将logstash.时间索引到一个文档
delete:根据id删除一个document(这个动作需要一个id)
create:建立一个索引document，如果id存在 动作失败.
update:根据id更新一个document，有一种特殊情况可以upsert--如果document不是已经存在的情况更新document 。参见upsert选项。
A sprintf style string to change the action based on the content of the event. The value %{[foo]} would use the foo field for the action
document_id=>” ” 为索引提供document id ，对重写elasticsearch中相同id词目很有用
document_type=>” ”事件要被写入的document type，一般要将相似事件写入同一type，可用%{}引用事件type，默认type=log
index=>”logstash-%{+YYYY,MM.dd}” 事件要被写进的索引，可是动态的用%{foo}语句
hosts=>[“127.0.0.0”] ["127.0.0.1:9200","127.0.0.2:9200"] "https://127.0.0.1:9200"
manage_template=>true 一个默认的es mapping 模板将启用（除非设置为false 用自己的template）
template=>”” 有效的filepath 设置自己的template文件路径，不设置就用已有的
template_name=>”logstash” 在es内部模板的名字
这里需要十分注意的一个问题是,document_id尽量保证值得唯一,这样会解决你面即将面临的ES数据重复问题,切记切记!

参考：
- https://blog.csdn.net/qq_40673345/article/details/103712732
- https://blog.csdn.net/qq_40673345/article/details/105248226?spm=1001.2014.3001.5502
