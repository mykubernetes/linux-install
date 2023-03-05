# 一、子查询

## 1.子查询的定义

定义: 出现在其他语句中的select语句,称为子查询或者内查询.
外部的语句可以是insert,update,delete,select,如果外面为select语句,则称为外查询或者主查询.

## 2.子查询的分类
```
1.按子查询出现的位置分:
select后面
        仅支持标量子查询
from后面
        支持表子查询
'where或having后面' 
        '标量子查询' (用的最多)
        '列子查询'   (用的较多)
        '行子查询'
exists后面(相关子查询)
        表子查询


2.按结果集的行列数不同分:
标量子查询 (结果集只有一行一列)
列子查询 (结果集只有一列多行)
行子查询 (结果集有一行多列)
表子查询 (结果集有多行多列)
```

## 3. 标量子查询
```
特点:
1.子查询放在小括号内.
2.子查询一般放在条件的右侧.
3.标量子查询,一般搭配单行操作符使用.
> < >= <= = <>
4.列子查询,一般搭配着多行操作符使用.
in any/some all
5.子查询的执行优先于主查询执行,主查询的条件用到了子查询的结果.

# 1.标量子查询
案例1:查询员工表中谁的工资比Tom高?
a)查询Tom的工资
select 工资
from 工资表
where name='Tom'

b)查询员工信息,满足工资> "a)查询"的结果
select * 
from 工资表
where 工资>(
      select 工资
      from 工资表
      where name='Tom'
);
```

## 4. 列子查询 (多行子查询)

其中any|some很少用,大多情况下可以用 min()或max()替代
其中all也很少用,大多情况下可以用 max()或max()替代

```
返回区域id是1400或1700的部门中所有员工的姓名
1.先查询区域id是1400或1700的所有部门编号
select distinct 部门id
from 部门表
where 区域id in(1400,1700);
2.查询员工姓名,其部门号在上面的结果列表1中
select name
from 员工表
where 部门id in(
    select distinct 部门id
    from 部门表
    where 区域id in(1400,1700);
);

#上例中 in 也可以用 =any 来替代
select name
from 员工表
where 部门id =any(
    select distinct 部门id
    from 部门表
    where 区域id in(1400,1700);
);

# 同理 not in 也可以用 <>all 替代
```

## 5.行子查询 (结果集为一行多列)

这种方式很少使用.
```
例子: 查询员工id最小并且工资也是最高的员工信息
1.查询最小员工id
select min(员工id)
from 员工表;

2.查询最大员工工资
select max(工资)
from 员工表;

3.查询符合1和2的员工信息
select *
from 员工表
where 员工id=(
        select min(员工id)
        from 员工表
)
and 工资=(
        select max(工资)
        from 员工表;
);

#使用行子查询方式完成上例
select * 
from 员工表
where (员工id,工资)=(
        select min(员工id),max(工资)
        from 员工表
);
```

# 二、在不同位置后的使用方法

## 1.放在select后面
```
# 仅支持标量子查询(子查询结果为一行一列)

1. 查询每个部门的员工个数
select b.*,(
        select count(*)
        from 员工表 a
        where a.部门id=b.部门id
) 员工个数
from 部门表 b;
```

## 2.放在from后面
```
#将子查询的结果充当一张表,要求必须起别名.

例子: 查询每个部门的平均工资的工资等级
1.查询每个部门的平均工资
select avg(工资),部门id
from 员工表
group by 部门id

2.连接1的结果集和工资等级表,筛选条件为平均工资在最第工资和最高工资之间对应的工资等级.
select ag_1.*,g.工资等级
from (
        select avg(工资) ag,部门id
        from 员工表
        group by 部门id
)ag_1
inner join 工资等级表 g
on ag_1.ag between 最高工资 and 最低工资;
```

## 3.放在exists后面 (相关子查询)
```
#使用exists查询结果是否存在,存在为1.不存在为0
select exists(select 员工id from 员工表);
结果为1

例如: 查询所有有员工的部门名
select 部门名
from 部门表 d
where exists(
        select *
        from 员工表 a
        where d.部门id=a.部门id
);

===========================================
!!!!#!!exists方式和前几种子查询顺序不同,它是: 先做查询select 部门名 from 部门表 d得到结果,然后再去select * from 员工表 a where d.部门id=a.部门id进行过滤得到最终结果.
```

# 三、分页查询

## 1.分页查询语法及使用
```
应用场景:当要显示的数据一页显示不全的时候,需要分页提交sql请求.

语法:
select 查询列表
from 表
[join_type join 表2
on 连接条件
where 筛选条件
group by 分组字段
having 分组后筛选
order by 排序的字段]
limit offset,size;

# offset要显示条目的起始索引(从0开始)
size要显示的条目个数.

#分页查询公式:
select 查询列表
from 表
limit (page-1)*size,size;

例如: 查询工资表前5条.(两种方式,0可省略)
select * from 工资表 limit 0,5;
select * from 工资表 limit 5;

例如: 查询工资表第11到25条.
select * from 工资表 limit 10,15;
```

## 2.分表查询效率
```
当分表查询的limit起始位置增大的时候.扫描的数据量也会越多,速度就会越慢.例如:
mysql> select * from emp limit 0,5;
...
5 rows in set (0.00 sec)

mysql> select * from emp limit 900000,5;
...
5 rows in set (0.43 sec)

# 解决方案1: 记录当前页的最大或最小id
select * from emp where id>=900000 limit 5;
...
5 rows in set (0.01 sec)
select * from emp where id<900000 order by id desc limit 5;

# 解决方案2: (但是必须是连续的id,否则可能数据量不能和页面要求匹配)
mysql> select * from emp where id between 910000 and 910005;
6 rows in set (0.00 sec)
```

# 四、联合查询
```
将多条查询语句的结果合并成一个结果.可以支持多个union
select * from 工资表 where email like '%a%' or 部门id>90;
相当于下条命令
select * from 工资表 where email like '%a%'
union
select * from 工资表 where 部门id>90;

应用场景
要查询的结果来自于多个表,且多个表没有连接关系,但查询的信息一致或非常接近.

#1.所以多条查询语句的查询列数是一致的.
#2.多条查询语句的列数类型.顺序和意义是一致的.
#3.使用union会自动去重.如果不去重要使用union all

=============================
1. select * from t表 where id=1 or id=10000；

2. select * from t表 where id=1
   union
   select * from t表 where id=10000；

#　有索引大数据量的情况下，2的执行效率比1要高很多。
```
