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
- concat:连接
- substr:截取子串
- upper:变大写
- lower：变小写
- replace：替换
- length：获取字节长度
- trim:去前后空格
- lpad：左填充
- rpad：右填充
- instr:获取子串第一次出现的索引

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
- rand:获取随机数，返回0-1之间的小数
- ceil:向上取整
- round：四舍五入
- mod:取模
- floor：向下取整
- truncate:截断


日期函数
---

| 序号	| 格式 | 功能	|
| :------: | :--------: | :------: |
| 1 | %Y | 四位的年份 |
| 2 | %y | 2位的年份 |
| 3 | %m | 月份（01,02…11,12） |
| 4 | %c | 月份（1,2,…11,12） |
| 5 | %d | 日（01,02,…） |
| 6 | %H | 小时（24小时制） |
| 7 | %h | 小时（12小时制） |
| 8 | %i | 分钟（00,01…59） |
| 9 | %s | 秒（00,01,…59） |

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
- now：返回当前日期+时间
- year:返回年
- month：返回月
- day:返回日
- date_format:将日期转换成字符
- curdate:返回当前日期
- str_to_date:将字符转换成日期
- curtime：返回当前时间
- hour:小时
- minute:分钟
- second：秒
- datediff:返回两个日期相差的天数
- monthname:以英文形式返回月

其他函数
---
```
select VERSION();
select DATABEAS();
select USER90;
```
- version 当前数据库服务器的版本
- database 当前打开的数据库
- user当前用户
- password('字符')：返回该字符的密码形式
- md5('字符'):返回该字符的md5加密形式


流程控制函数
---

1、if(条件表达式，表达式1，表达式2)：如果条件表达式成立，返回表达式1，否则返回表达式2
```
select IF(10<5,'大','小');
select last_name,commission_pct,IF(commission_pct IS NULL,'没奖金','有奖金') as 备注 FROM employess;
```

2、case 变量或表达式或字段 when 常量1 then 值1 when 常量2 then 值2 else 值n end
```
SELECT salary as 原始工资,department_id,
CASE department_id
WHEN 30 THEN salary*1.1
WHEN 40 THEN salary*1.2
WHEN 50 THEN salary*1.3
ELSE salary
END AS 新工资
FROM employees;
```

3、case  when 条件1 then 值1 when 条件2 then 值2 else 值n end
```
SELECT salary,
CASE
WHEN salary>20000 THEN 'A'
WHEN salary>15000 THEN 'B'
WHEN salary>10000 THEN 'C'
ELSE 'D'
END AS 工资级别
FROM employees;
```
