```
input {
  jdbc {
    jdbc_driver_class => "com.mysql.cj.jdbc.Driver"
    jdbc_connection_string => "jdbc:mysql://localhost:3306/es? useSSL=false&serverTimezone=UTC"
    jdbc_user => root
    jdbc_password => "123456"
    # 启动追踪，如果为true,则需要指定tracking_column
    use_column_value => true
    # 指定追踪的字段
    tracking_column => id
    # 追踪字段的类型，目前只有数字（numeric）和时间类型（timestamp）,默认是数字类型
    tracking_column_type => "numeric" 
    # 记录最后一次运行的结果
    record_last_run => true
    # 上面运行结果的保存位置
    last_run_metadata_path => "mysql-position.txt"
    statement => "SELECT * FROM news where id > :sql_last_value"
    schedule => "* * * * * *"
  }
}
 
filter {
  mutate {
    split => { "tags" => ","}
  }
}

output {
  elasticsearch {
    document_id => "%{id}"
    document_type => "_doc"
    index => "news"
    hosts => ["http://localhost:9200"]
  }
  stdout{
    codec => rubydebug
  }
}
```
