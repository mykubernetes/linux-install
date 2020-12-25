字符函数
---
```
#1、length 获取参数值的字节个数
select legth('john');

#2、concat 拼接字符串
select concat(last_name,',',first_name) from employees;

#3、upper、lower,
select upper('john');    #转换为大写
select lower('joHn');    #转换为小写

select CONCAT(UPPER(last_name),LOWER(first_name)) as 姓名 FROM employess;

#4、substr、substring截取字符串，索引从1开始
#截取从指定索引处后面的所有字符
select SUBSTR('李莫愁爱上了陆展元',7) as out_put;
#截取从指定索引处指定字符长度的字符
select SUBSTR('李莫愁爱上了陆展元',1,3) as out_put;

select CONCAT(UPPER(SUBSTR(last_name,1,1)),'_',LOWER(SUBSTR(last_name,2))) as out_put FROM employees;

#5、instr返回字串第一次出现的索引，如果找不到返回0
select INSTR('杨不悔爱上了殷六侠','殷六侠') as out_put ;

#6、trim 去掉前后空格长度，可以指定去掉的字符
select TRIM('       张翠山      ') AS out_put;
select LENGTH(TRIM('       张翠山      ')) AS out_put;
select TRIM('a' FROM 'aaaaaa张翠山aaaaaaaaaaa') AS out_put;

#7、lpad 用指定的字符实现左填充指定长度
select LPAD('殷素素',10,'*') as out_put;

#8、rpad用指定的字符实现右填充指定长度
select RPAD('殷素素',10,'ab') as out_put;

#9、replace 替换
select REPLACE('张无忌爱上了周芷若','周芷若','赵敏') as out_put;
```

数学函数
---
```
#1、round 四舍五入,小数点后保留个数
select ROUND(1.65);
select ROUND(1.657,2);

#2、ceil 向上取整,返回>=该参数的最小整数
select CEIL(1.52);

#3、floor向下取整,返回<=该参数的最大整数
select FLOOR(-9.99);

#4、truncate 截断,保留小数点后的位置
select TRUNCATE(1.699,1)

#5、mod取余
select MOD(10,3);
```

日期函数
---
```
#1、now 返回当前系统日期+时间
select NOW();

#2、curdate返回当前系统日期，不包含时间
select CURDATE();

#3、curtime返回当前时间，不包含日期
select CURTIME();

#4、可以获取指定的部分，年、月、日、小时、分钟、秒
select YEAR(NOW()) as 年;
select YEAR('2020-10-10') as 年;
select YEAR(hiredate) as 年 FROM employees;
select MONTH(NOW()) as 月;
select MONTHNAME(NOW()) as 月;

#5、str_to_date 将字符通过指定的格式转换成日期
select str_to_date('1998-3-2','%Y-%c-%d') as out_put
select * FROM employees WHERE hiredate = STR_TO_DATE('4-3 1998','%c-%d %Y');

#6、date_format 将日期转换为字符
select DATE_FORMAT(NOW(),'%年%m月%d日') as out_put;
select last_name,DATE_FORMAT(hiredate,'%m月/%d日 %y年') 入职日期 FROM employees where commisson_pct IS NOT NULL;
```

其他函数
---
```
select VERSION();
select DATABEAS();
select USER90;
```
