# 一、子查询

## 1.子查询的定义

定义: 出现在其他语句中的select语句,称为子查询或者内查询.外部的语句可以是insert,update,delete,select,如果外面为select语句,则称为外查询或者主查询.

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

## 3. 单行子查询

### 1、单行比较操作符

| 操作符 | 含义|
|--------|-----|
| = | 等于 |
| > | 大于 |
| >= | 大于等于 |
| < | 小于 |
| <= | 小于等于 |
| <> | 不等于 |

```sql
# 查询工资大于149号员工工资的员工的信息
SELECT employee_id,last_name,salary
FROM employees
WHERE salary>(
              SELECT salary
              FROM employees
              WHERE employee_id=149);

# 返回job_id与141号员工相同，salary比143号员工多的员工姓名,job_id和工资
SELECT last_name,job_id,salary
FROM employees
WHERE job_id=(
              SELECT job_id
              FROM employees
              WHERE employee_id=141)
AND salary>(
            SELECT salary
            FROM employees
            WHERE employee_id=143);    

# 返回公司工资最少的员工的last_name,job_id和salary
SELECT last_name,job_id,salary
FROM employees
WHERE salary=(
              SELECT MIN(salary)
              FROM employees);

# 查询与141号员工的manager_id和department_id相同的其他员工
# 法一：(正常思路)
SELECT employee_id,manager_id,department_id
FROM employees
WHERE manager_id=(
                  SELECT manager_id
                  FROM employees
                  WHERE employee_id=141)
AND department_id=(
                  SELECT department_id
                  FROM employees
                  WHERE employee_id=141)
AND employee_id<>141;# 注意去除141号员工本身

# 法二：
SELECT employee_id,manager_id,department_id
FROM employees
WHERE (manager_id,department_id)=(
                  SELECT manager_id,department_id
                  FROM employees
                  WHERE employee_id=141)
AND employee_id<>141;# 注意去除141号员工本身
```

### 2、HAVING 中的子查询

```sql
#首先执行子查询，再向主查询中的HAVING 子句返回结果。
# 查询最低工资大于50号部门最低工资的部门id和其最低工资

SELECT department_id,MIN(salary)
FROM employees
GROUP BY department_id  # 只能想到使用group by...having,因为where中不能使用聚合函数
HAVING MIN(salary)>(
                    SELECT MIN(salary)
                    FROM employees         
                    WHERE department_id=50);
```

### 3、CASE中的子查询

```sql
# 在CASE表达式中使用单列子查询

# 显示员工的employee_id,last_name和location。
# 其中，若员工department_id与location_id为1800 的department_id相同，则location为’Canada’，其余则为’USA’。
SELECT employee_id,last_name,
CASE department_id WHEN (SELECT department_id FROM departments WHERE location_id = 1800) THEN 'Canada'
ELSE 'USA' END "location" # CASE...WHEN...THEN...用在第一行

FROM employees;
```

### 4、子查询中的空值问题

```sql
SELECT last_name, job_id
FROM   employees
WHERE  job_id =(
                 SELECT job_id
                 FROM   employees
                 WHERE  last_name = 'Haas');# 公司没有Haas这个人，子查询返回空值，最终结果也是空值，但不会报错
```

5、非法使用子查询

```sql
# 报错： Subquery returns more than 1 row
# 原因：因为子查询的结果是多行数据，而父查询使用单行操作符=，不知道到底等于哪个数据
SELECT employee_id, last_name
FROM   employees
WHERE  salary =(
                SELECT   MIN(salary)
                FROM     employees
                GROUP BY department_id); 
```

## 4.多行子查询

### 1、多行比较操作符

| 操作符 | 含义|
|--------|-----|
| in | 等于列表中的**任意一个** |
| any | 需要和单行比较操作符一起使用，和子查询返回的**某一个**值比较 |
| all | 需要和单行比较操作符一起使用，和子查询返回的**所有**值比较 |
| some | 实际上是any的别名，作用相同，一般常使用any |

```sql
# 返回其它job_id中比job_id为‘IT_PROG’部门任一工资低的员工的员工号、姓名、job_id 以及salary

SELECT employee_id,last_name,job_id,salary
FROM employees
WHERE salary< ANY(
                  SELECT salary
                  FROM employees     
                  WHERE job_id='IT_PROG')
AND job_id<>'IT_PROG'; # 注意去除IT_PROG本身

# 返回其它job_id中比job_id为‘IT_PROG’部门所有工资都低的员工的员工号、姓名、job_id以及salary
SELECT employee_id,last_name,job_id,salary
FROM employees
WHERE salary< ALL(
                  SELECT salary
                  FROM employees     
                  WHERE job_id='IT_PROG')
AND job_id<>'IT_PROG'; # 注意去除IT_PROG本身

# 查询平均工资最低的部门id
# 法一
SELECT department_id
FROM employees
GROUP BY department_id
HAVING AVG(salary) = (
			SELECT MIN(avg_sal) # 将子查询出来的数据作为一个临时表，一定要为所查询的列取别名和临时表取表名
			FROM(
				    SELECT AVG(salary) avg_sal
				    FROM employees
				    GROUP BY department_id
				)   t_dept_avg_sal
			);

# 法二
SELECT department_id
FROM employees
GROUP BY department_id
HAVING AVG(salary)<=ALL(  # 小于等于平均工资即相当于等于最小平均工资
                        SELECT AVG(salary)
                        FROM employees
                        GROUP BY department_id);

```

### 2、空值问题

```sql
SELECT last_name
FROM employees
WHERE employee_id NOT IN ( #返回结果为控制是因为子查询中查询出的manager_id有一个null值，导致not in判断有问题
			                  SELECT manager_id
			                  FROM employees
                             #WHERE manager_id IS NOT NULL    
			               );
```


参考：
- http://xpbag.com/496.html#%E5%9B%9B%E3%80%81%E8%81%94%E5%90%88%E6%9F%A5%E8%AF%A2
- https://blog.csdn.net/qq_44111805/article/details/124680208
