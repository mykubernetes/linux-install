
```
SELECT TABLE_NAME, (DATA_LENGTH+INDEX_LENGTH)/1048576, TABLE_ROWS FROM information_schema.tables WHERE TABLE_SCHEMA='dbname' AND TABLE_NAME='tablename';
```
- 以兆为单位

https://blog.csdn.net/weixin_43889788/article/details/128366855

https://blog.csdn.net/weixin_42326851/article/details/124213228
