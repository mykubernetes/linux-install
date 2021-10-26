# DCL（Data Control Language）语句：即数据控制语句

- DCL(Data Control Language)语句：数据控制语句，用于控制不同数据段直接的许可和访问级别的语句。这些语句定义了数据库、表、字段、用户的访问权限和安全级别。

# 关键字
- GRANT
- REVOKE

# 查看用户权限

- 当成功创建用户账户后，还不能执行任何操作，需要为该用户分配适当的访问权限。可以使用SHOW GRANTS FOR语句来查询用户的权限。

例如：
```
mysql> SHOW GRANTS FOR test;
+-------------------------------------------+
| Grants for test@%                         |
+-------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO 'test'@'%' |
+-------------------------------------------+
1 row in set (0.00 sec)
```

# GRANT语句
- 对于新建的MySQL用户，必须给它授权，可以用GRANT语句来实现对新建用户的授权。

## 格式语法
```
GRANT
    priv_type [(column_list)]
      [, priv_type [(column_list)]] ...
    ON [object_type] priv_level
    TO user [auth_option] [, user [auth_option]] ...
    [REQUIRE {NONE | tls_option [[AND] tls_option] ...}]
    [WITH {GRANT OPTION | resource_option} ...]

GRANT PROXY ON user
    TO user [, user] ...
    [WITH GRANT OPTION]

object_type: {
    TABLE
  | FUNCTION
  | PROCEDURE
}

priv_level: {
    *
  | *.*
  | db_name.*
  | db_name.tbl_name
  | tbl_name
  | db_name.routine_name
}

user:
    (see Section 6.2.4, “Specifying Account Names”)

auth_option: {
    IDENTIFIED BY 'auth_string'
  | IDENTIFIED WITH auth_plugin
  | IDENTIFIED WITH auth_plugin BY 'auth_string'
  | IDENTIFIED WITH auth_plugin AS 'auth_string'
  | IDENTIFIED BY PASSWORD 'auth_string'
}

tls_option: {
    SSL
  | X509
  | CIPHER 'cipher'
  | ISSUER 'issuer'
  | SUBJECT 'subject'
}

resource_option: {
  | MAX_QUERIES_PER_HOUR count
  | MAX_UPDATES_PER_HOUR count
  | MAX_CONNECTIONS_PER_HOUR count
  | MAX_USER_CONNECTIONS count
}
```

## 权限类型(priv_type)

- 授权的权限类型一般可以分为数据库、表、列、用户。

### 授予数据库权限类型

授予数据库权限时，priv_type可以指定为以下值：

- SELECT：表示授予用户可以使用 SELECT 语句访问特定数据库中所有表和视图的权限。
- INSERT：表示授予用户可以使用 INSERT 语句向特定数据库中所有表添加数据行的权限。
- DELETE：表示授予用户可以使用 DELETE 语句删除特定数据库中所有表的数据行的权限。
- UPDATE：表示授予用户可以使用 UPDATE 语句更新特定数据库中所有数据表的值的权限。
- REFERENCES：表示授予用户可以创建指向特定的数据库中的表外键的权限。
- CREATE：表示授权用户可以使用 CREATE TABLE 语句在特定数据库中创建新表的权限。
- ALTER：表示授予用户可以使用 ALTER TABLE 语句修改特定数据库中所有数据表的权限。
- SHOW VIEW：表示授予用户可以查看特定数据库中已有视图的视图定义的权限。
- CREATE ROUTINE：表示授予用户可以为特定的数据库创建存储过程和存储函数的权限。
- ALTER ROUTINE：表示授予用户可以更新和删除数据库中已有的存储过程和存储函数的权限。
- INDEX：表示授予用户可以在特定数据库中的所有数据表上定义和删除索引的权限。
- DROP：表示授予用户可以删除特定数据库中所有表和视图的权限。
- CREATE TEMPORARY TABLES：表示授予用户可以在特定数据库中创建临时表的权限。
- CREATE VIEW：表示授予用户可以在特定数据库中创建新的视图的权限。
- EXECUTE ROUTINE：表示授予用户可以调用特定数据库的存储过程和存储函数的权限。
- LOCK TABLES：表示授予用户可以锁定特定数据库的已有数据表的权限。
- SHOW DATABASES：表示授权可以使用SHOW DATABASES语句查看所有已有的数据库的定义的权限。
- ALL或ALL PRIVILEGES：表示以上所有权限。

### 授予表权限类型

授予表权限时，priv_type可以指定为以下值：

- SELECT：授予用户可以使用 SELECT 语句进行访问特定表的权限。
- INSERT：授予用户可以使用 INSERT 语句向一个特定表中添加数据行的权限。
- DELETE：授予用户可以使用 DELETE 语句从一个特定表中删除数据行的权限。
- DROP：授予用户可以删除数据表的权限。
- UPDATE：授予用户可以使用 UPDATE 语句更新特定数据表的权限。
- ALTER：授予用户可以使用 ALTER TABLE 语句修改数据表的权限。
- REFERENCES：授予用户可以创建一个外键来参照特定数据表的权限。
- CREATE：授予用户可以使用特定的名字创建一个数据表的权限。
- INDEX：授予用户可以在表上定义索引的权限。
- ALL或ALL PRIVILEGES：所有的权限名。

### 授予列(字段)权限类型

- 授予列(字段)权限时，priv_type的值只能指定为SELECT、INSERT和UPDATE，同时权限的后面需要加上列名列表(column-list)。

### 授予创建和删除用户的权限

- 授予列(字段)权限时，priv_type的值指定为CREATE USER权限，具备创建用户、删除用户、重命名用户和撤消所有特权，而且是全局的。

### ON

- 有ON，是授予权限，无ON，是授予角色。如：
```
-- 授予数据库db1的所有权限给指定账户
GRANT ALL ON db1.* TO 'user1'@'localhost';
-- 授予角色给指定的账户
GRANT 'role1', 'role2' TO 'user1'@'localhost', 'user2'@'localhost';
```

### 对象类型(object_type)

- 在ON关键字后给出要授予权限的object_type，通常object_type可以是数据库名、表名等。

### 权限级别(priv_level)

指定权限级别的值有以下几类格式：

- *：表示当前数据库中的所有表。
- .：表示所有数据库中的所有表。
- db_name.*：表示某个数据库中的所有表，db_name指定数据库名。
- db_name.tbl_name：表示某个数据库中的某个表或视图，db_name指定数据库名，tbl_name指定表名或视图名。
- tbl_name：表示某个表或视图，tbl_name指定表名或视图名。
- db_name.routine_name：表示某个数据库中的某个存储过程或函数，routine_name指定存储过程名或函数名。

### 被授权的用户(user)
```
'user_name'@'host_name'
```
- Tips：'host_name’用于适应从任意主机访问数据库而设置的，可以指定某个地址或地址段访问。
- 可以同时授权多个用户。

user表中host列的默认值

| host | 说明 |
|------|------|
| %	| 匹配所有主机 |
| localhost	| localhost不会被解析成IP地址，直接通过UNIXsocket连接 |
| 127.0.0.1	| 会通过TCP/IP协议连接，并且只能在本机访问 |
| ::1	| ::1就是兼容支持ipv6的，表示同ipv4的127.0.0.1 |

host_name格式有以下几种：

- 使用%模糊匹配，符合匹配条件的主机可以访问该数据库实例，例如192.168.2.%或%.test.com；
- 使用localhost、127.0.0.1、::1及服务器名等，只能在本机访问；
- 使用ip地址或地址段形式，仅允许该ip或ip地址段的主机访问该数据库实例，例如192.168.2.1或192.168.2.0/24或192.168.2.0/255.255.255.0；
- 省略即默认为%。

### 身份验证方式(auth_option)

- auth_option为可选字段，可以指定密码以及认证插件(mysql_native_password、sha256_password、caching_sha2_password)。

### 加密连接(tls_option)

- tls_option为可选的，一般是用来加密连接。

### 用户资源限制(resource_option)

- resource_option为可选的，一般是用来指定最大连接数等。

|参数 | 说明 |
|-----|-----|
| MAX_QUERIES_PER_HOUR count	| 每小时最大查询数 |
| MAX_UPDATES_PER_HOUR count	| 每小时最大更新数 |
| MAX_CONNECTIONS_PER_HOUR count	| 每小时连接次数 |
| MAX_USER_CONNECTIONS count	| 用户最大连接数 |

### 权限生效

- 若要权限生效，需要执行以下语句：
```
FLUSH PRIVILEGES;
```

### REVOKE语句

- REVOKE语句主要用于撤销权限。

### 语法格式

- REVOKE语法和GRANT语句的语法格式相似，但具有相反的效果
```
REVOKE
    priv_type [(column_list)]
      [, priv_type [(column_list)]] ...
    ON [object_type] priv_level
    FROM user [, user] ...

REVOKE ALL [PRIVILEGES], GRANT OPTION
    FROM user [, user] ...

REVOKE PROXY ON user
    FROM user [, user] ...
```

- 若要使用REVOKE语句，必须拥有MySQL数据库的全局CREATE USER权限或UPDATE权限;
- 第一种语法格式用于回收指定用户的某些特定的权限，第二种回收指定用户的所有权限；

# 练习

1、查看数据库中所有用户
```
mysql> SELECT DISTINCT CONCAT('User: ''',user,'''@''',host,''';') AS query FROM mysql.user;
+------------------------------------+
| query                              |
+------------------------------------+
| User: 'mysql.session'@'localhost'; |
| User: 'mysql.sys'@'localhost';     |
| User: 'root'@'localhost';          |
+------------------------------------+
4 rows in set (0.00 sec)
```

2、创建一个测试账号test，授予全局层级的权限。
```
mysql> grant select,insert on *.* to test@'%' identified by '123456';
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)
```

3、可以用下面两种方式查询授予test的权限。
```
mysql> show grants for test;
+----------------------------------------------------------------+
| Grants for test@%                                              |
+----------------------------------------------------------------+
| GRANT SELECT, INSERT, UPDATE, DELETE ON `MyDB`.* TO 'test'@'%' |
+----------------------------------------------------------------+
2 rows in set (0.00 sec)



mysql>  select * from mysql.user where user='test'\G;
*************************** 1. row ***************************
                  Host: %
                  User: test
           Select_priv: Y                    #可以看到test用户只有select和insert权限，Y代表有权限，N代表没有权限
           Insert_priv: Y
           Update_priv: N
           Delete_priv: N
           Create_priv: N
             Drop_priv: N
           Reload_priv: N
         Shutdown_priv: N
          Process_priv: N
             File_priv: N
            Grant_priv: N
       References_priv: N
            Index_priv: N
            Alter_priv: N
          Show_db_priv: N
            Super_priv: N
 Create_tmp_table_priv: N
      Lock_tables_priv: N
          Execute_priv: N
       Repl_slave_priv: N
      Repl_client_priv: N
      Create_view_priv: N
        Show_view_priv: N
   Create_routine_priv: N
    Alter_routine_priv: N
      Create_user_priv: N
            Event_priv: N
          Trigger_priv: N
Create_tablespace_priv: N
              ssl_type: 
            ssl_cipher: 
           x509_issuer: 
          x509_subject: 
         max_questions: 0
           max_updates: 0
       max_connections: 0
  max_user_connections: 0
                plugin: mysql_native_password
 authentication_string: *6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9
      password_expired: N
 password_last_changed: 2021-10-26 10:38:07
     password_lifetime: NULL
        account_locked: N
1 row in set (0.00 sec)

ERROR: 
No query specified
```

4、创建一个测试账号test，授予数据库层级的权限。
```
mysql> drop user test;
Query OK, 0 rows affected (0.00 sec)
 
mysql> grant select,insert,update,delete on MyDB.* to test@'%' identified by 'test';
Query OK, 0 rows affected (0.01 sec)

mysql> select * from mysql.user where user='test'\G;                  --可以看到无任何授权。
*************************** 1. row ***************************
                  Host: %
                  User: test
           Select_priv: N
           Insert_priv: N
           Update_priv: N
           Delete_priv: N
           Create_priv: N
             Drop_priv: N
           Reload_priv: N
         Shutdown_priv: N
          Process_priv: N
             File_priv: N
            Grant_priv: N
       References_priv: N
            Index_priv: N
            Alter_priv: N
          Show_db_priv: N
            Super_priv: N
 Create_tmp_table_priv: N
      Lock_tables_priv: N
          Execute_priv: N
       Repl_slave_priv: N
      Repl_client_priv: N
      Create_view_priv: N
        Show_view_priv: N
   Create_routine_priv: N
    Alter_routine_priv: N
      Create_user_priv: N
            Event_priv: N
          Trigger_priv: N
Create_tablespace_priv: N
              ssl_type: 
            ssl_cipher: 
           x509_issuer: 
          x509_subject: 
         max_questions: 0
           max_updates: 0
       max_connections: 0
  max_user_connections: 0
                plugin: mysql_native_password
 authentication_string: *6BB4837EB74329105EE4568DDA7DC67ED2CA2AD9
      password_expired: N
 password_last_changed: 2021-10-26 10:43:37
     password_lifetime: NULL
        account_locked: N
1 row in set (0.00 sec)

ERROR: 
No query specified



mysql> select * from mysql.db where user='test'\G;
*************************** 1. row ***************************
                 Host: %
                   Db: MyDB
                 User: test
          Select_priv: Y
          Insert_priv: Y
          Update_priv: Y
          Delete_priv: Y
          Create_priv: N
            Drop_priv: N
           Grant_priv: N
      References_priv: N
           Index_priv: N
           Alter_priv: N
Create_tmp_table_priv: N
     Lock_tables_priv: N
     Create_view_priv: N
       Show_view_priv: N
  Create_routine_priv: N
   Alter_routine_priv: N
         Execute_priv: N
           Event_priv: N
         Trigger_priv: N
1 row in set (0.00 sec)

ERROR: 
No query specified


mysql> show grants for test;
+----------------------------------------------------------------+
| Grants for test@%                                              |
+----------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'test'@'%'                               |
| GRANT SELECT, INSERT, UPDATE, DELETE ON `MyDB`.* TO 'test'@'%' |
+----------------------------------------------------------------+
2 rows in set (0.00 sec)
```

5、创建一个测试账号test，授予表层级的权限。
```
mysql> drop user test;
Query OK, 0 rows affected (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)

mysql> grant all on MyDB.kkk to test@'%' identified by '123456';
Query OK, 0 rows affected, 1 warning (0.00 sec)



mysql> show grants for test;
+----------------------------------------------------+
| Grants for test@%                                  |
+----------------------------------------------------+
| GRANT USAGE ON *.* TO 'test'@'%'                   |
| GRANT ALL PRIVILEGES ON `MyDB`.`kkk` TO 'test'@'%' |
+----------------------------------------------------+
2 rows in set (0.00 sec)




mysql> select * from mysql.tables_priv\G;
*************************** 1. row ***************************
       Host: localhost
         Db: mysql
       User: mysql.session
 Table_name: user
    Grantor: boot@connecting host
  Timestamp: 0000-00-00 00:00:00
 Table_priv: Select
Column_priv: 
*************************** 2. row ***************************
       Host: localhost
         Db: sys
       User: mysql.sys
 Table_name: sys_config
    Grantor: root@localhost
  Timestamp: 2021-10-25 11:13:35
 Table_priv: Select
Column_priv: 
*************************** 3. row ***************************
       Host: %
         Db: MyDB
       User: test
 Table_name: kkk
    Grantor: root@localhost
  Timestamp: 0000-00-00 00:00:00
 Table_priv: Select,Insert,Update,Delete,Create,Drop,References,Index,Alter,Create View,Show view,Trigger
Column_priv: 
3 rows in set (0.00 sec)

ERROR: 
No query specified
```

6、创建一个测试账号test，授予列层级的权限。
```
mysql> drop user test;
Query OK, 0 rows affected (0.00 sec)
 
mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)
 
mysql> grant select (id, col1) on MyDB.TEST1 to test@'%' identified by '123456';
Query OK, 0 rows affected (0.01 sec)
 
mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)


 
 
mysql> select * from mysql.columns_priv;
+------+------+------+------------+-------------+---------------------+-------------+
| Host | Db   | User | Table_name | Column_name | Timestamp           | Column_priv |
+------+------+------+------------+-------------+---------------------+-------------+
| %    | MyDB | test | TEST1      | id          | 0000-00-00 00:00:00 | Select      |
| %    | MyDB | test | TEST1      | col1        | 0000-00-00 00:00:00 | Select      |
+------+------+------+------------+-------------+---------------------+-------------+
2 rows in set (0.00 sec)
 
 
mysql> show grants for test;
+-----------------------------------------------------------------------------------------------------+
| Grants for test@%                                                                                   |
+-----------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'test'@'%' IDENTIFIED BY PASSWORD '*94BDCEBE19083CE2A1F959FD02F964C7AF4CFC29' |
| GRANT SELECT (id, col1) ON `MyDB`.`TEST1` TO 'test'@'%'                                             |
+-----------------------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)
 
mysql> 
```

7、创建一个测试账号test，授子程序层级的权限。
```
mysql> DROP PROCEDURE IF EXISTS PRC_TEST;
Query OK, 0 rows affected (0.00 sec)
 
mysql> DELIMITER //
mysql> CREATE PROCEDURE PRC_TEST()
    -> BEGIN
    ->    SELECT * FROM kkk;
    -> END //
Query OK, 0 rows affected (0.00 sec)
 
mysql> DELIMITER ;
 
mysql> grant execute on procedure MyDB.PRC_TEST to test@'%' identified by 'test';
Query OK, 0 rows affected (0.01 sec)
 
mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)
 
mysql> 
 
 
mysql> show grants for test;
+-----------------------------------------------------------------------------------------------------+
| Grants for test@%                                                                                   |
+-----------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO 'test'@'%' IDENTIFIED BY PASSWORD '*94BDCEBE19083CE2A1F959FD02F964C7AF4CFC29' |
| GRANT EXECUTE ON PROCEDURE `MyDB`.`prc_test` TO 'test'@'%'                                          |
+-----------------------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)
 
mysql> select * from mysql.procs_priv where User='test';
+------+------+------+--------------+--------------+----------------+-----------+---------------------+
| Host | Db   | User | Routine_name | Routine_type | Grantor        | Proc_priv | Timestamp           |
+------+------+------+--------------+--------------+----------------+-----------+---------------------+
| %    | MyDB | test | PRC_TEST     | PROCEDURE    | root@localhost | Execute   | 0000-00-00 00:00:00 |
+------+------+------+--------------+--------------+----------------+-----------+---------------------+
1 row in set (0.00 sec)
 
mysql> 
```









