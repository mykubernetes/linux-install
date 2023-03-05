# 一、子查询

## 1.子查询的定义

定义: 出现在其他语句中的select语句,称为子查询或者内查询.外部的语句可以是insert,update,delete,select,如果外面为select语句,则称为外查询或者主查询.

## 2.子查询的分类

```sql
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

# 六、相关子查询

## 1、相关子查询执行流程

如果子查询的执行依赖于外部查询，通常情况下都是**因为子查询中的表用到了外部的表，并进行了条件关联**，因此每执行一次外部查询，子查询都要重新计算一次，这样的子查询就称之为 关联子查询。

相关子查询按照一行接一行的顺序执行，主查询的每一行都执行一次子查询。

```sql
# 查询员工中工资大于本部门平均工资的员工的last_name,salary和其department_id

# 法一：相关子查询
SELECT last_name,salary,department_id
FROM employees e1
WHERE salary>(
              SELECT AVG(salary)
              FROM employees e2   
              WHERE department_id=e1.department_id); # 注意“本部门”关键字眼

# 法二：在from中声明子查询

# from型的子查询：子查询是作为from的一部分，子查询要用()引起来，并且要给这个子查询取别
#名， 把它当成一张“临时的虚拟的表”来使用。
SELECT e.last_name,e.salary,e.department_id #注意此处要标明department_id所属的表，不然会报错(Column 'department_id' in field list is ambiguous)
FROM employees e,(
                  SELECT department_id,AVG(salary) avg_sal     
                  FROM employees
                  GROUP BY department_id) t_dept_avg_sal
WHERE e.department_id=t_dept_avg_sal.department_id
AND e.salary>t_dept_avg_sal.avg_sal;

# 查询员工的id,salary,按照department_name 排序
SELECT employee_id,salary
FROM employees e
ORDER BY (SELECT department_name # department_name在departmnets表中
          FROM departments d
          WHERE e.department_id=d.department_id);

# 重要结论：在SELECT中，除了GROUP BY 和 LIMIT之外，其他位置都可以声明子查询


# 若employees表中employee_id与job_history表中employee_id相同的数目不小于2，输出这些相同
# id的员工的employee_id,last_name和其job_id
SELECT e.employee_id,e.last_name,e.job_id
FROM employees e
WHERE 2<=(SELECT COUNT(*)
          FROM job_history
          WHERE employee_id=e.employee_id);
```

## 2、EXISTS 与 NOT EXISTS关键字

（1）关联子查询通常也会和 EXISTS操作符一起来使用，用来检查在子查询中是否存在满足条件的行。

（2）如果在子查询中不存在满足条件的行：
```
条件返回 FALSE ；
继续在子查询中查找。
```

（3）如果在子查询中存在满足条件的行：
```
不在子查询中继续查找；
条件返回 TRUE。
```

（4）NOT EXISTS关键字表示如果不存在某种条件，则返回TRUE，否则返回FALSE。

```sql
# 查询公司管理者的employee_id，last_name，job_id，department_id信息
# 方式一：自连接
SELECT DISTINCT e1.employee_id,e1.last_name,e1.job_id,e1.department_id # 因为管理者可能管理多个员工，所以需要去重
FROM employees e1 JOIN employees e2 # 相当于求交集
WHERE e1.employee_id=e2.manager_id;

# 方式二：子查询
SELECT employee_id,last_name,job_id,department_id
FROM employees
WHERE employee_id IN(
                    SELECT DISTINCT manager_id
                    FROM employees);

# 方式三：exists
SELECT e1.employee_id,e1.last_name,e1.job_id,e1.department_id
FROM employees e1
WHERE EXISTS(
              SELECT *
              FROM employees e2
              WHERE e1.employee_id=e2.manager_id
            );


# 查询departments表中，不存在于employees表中的部门的department_id和department_name
# 方式一：右连接
SELECT d.department_id,d.department_name
FROM employees e RIGHT JOIN departments d
ON e.department_id = d.department_id
WHERE e.department_id IS NULL; # employees表中没有的department_id

# 方式二：not exists(与上面一题方式三类似)
SELECT department_id,department_name
FROM departments d
WHERE NOT EXISTS (
		SELECT *
		FROM employees e
		WHERE d.department_id= e.department_id
		);
```

# 七、小练习
```sql
#1.查询和Zlotkey相同部门的员工姓名和工资

SELECT last_name,salary
FROM employees
WHERE department_id IN (
			SELECT department_id
			FROM employees
			WHERE last_name = 'Zlotkey'
			);

#2.查询工资比公司平均工资高的员工的员工号，姓名和工资。

SELECT employee_id,last_name,salary
FROM employees
WHERE salary > (
		SELECT AVG(salary)
		FROM employees
		);

#3.选择工资大于所有JOB_ID = 'SA_MAN'的员工的工资的员工的last_name, job_id, salary

SELECT last_name,job_id,salary
FROM employees
WHERE salary > ALL(
		SELECT salary
		FROM employees
		WHERE job_id = 'SA_MAN'
		);


#4.查询和姓名中包含字母u的员工在相同部门的员工的员工号和姓名

SELECT employee_id,last_name
FROM employees 
WHERE department_id IN (
			SELECT DISTINCT department_id
			FROM employees
			WHERE last_name LIKE '%u%'
			);


#5.查询在部门的location_id为1700的部门工作的员工的员工号

SELECT employee_id
FROM employees
WHERE department_id IN (
			SELECT department_id
			FROM departments
			WHERE location_id = 1700
			);


#6.查询管理者是King的员工姓名和工资

SELECT last_name,salary,manager_id
FROM employees
WHERE manager_id IN (
			SELECT employee_id
			FROM employees
			WHERE last_name = 'King'
			);



#7.查询工资最低的员工信息: last_name, salary

SELECT last_name,salary
FROM employees
WHERE salary = (
		SELECT MIN(salary)
		FROM employees
		);


#8.查询平均工资最低的部门信息
#方式1：
SELECT *
FROM departments
WHERE department_id = (
			SELECT department_id
			FROM employees
			GROUP BY department_id
			HAVING AVG(salary ) = (
						SELECT MIN(avg_sal)
						FROM (
							SELECT AVG(salary) avg_sal
							FROM employees
							GROUP BY department_id
							) t_dept_avg_sal

						)
			);
#方式2：

SELECT *
FROM departments
WHERE department_id = (
			SELECT department_id
			FROM employees
			GROUP BY department_id
			HAVING AVG(salary ) <= ALL(
						SELECT AVG(salary)
						FROM employees
						GROUP BY department_id
						)
			);

#方式3： LIMIT

SELECT *
FROM departments
WHERE department_id = (
			SELECT department_id
			FROM employees
			GROUP BY department_id
			HAVING AVG(salary ) =(
						SELECT AVG(salary) avg_sal
						FROM employees
						GROUP BY department_id
						ORDER BY avg_sal ASC
						LIMIT 1		
						)
			);

#方式4：

SELECT d.*
FROM departments d,(
		SELECT department_id,AVG(salary) avg_sal
		FROM employees
		GROUP BY department_id
		ORDER BY avg_sal ASC
		LIMIT 0,1
		) t_dept_avg_sal
WHERE d.`department_id` = t_dept_avg_sal.department_id
		
#9.查询平均工资最低的部门信息和该部门的平均工资（相关子查询）
#方式1：
SELECT d.*,(SELECT AVG(salary) FROM employees WHERE department_id = d.`department_id`) avg_sal
FROM departments d
WHERE department_id = (
			SELECT department_id
			FROM employees
			GROUP BY department_id
			HAVING AVG(salary ) = (
						SELECT MIN(avg_sal)
						FROM (
							SELECT AVG(salary) avg_sal
							FROM employees
							GROUP BY department_id
							) t_dept_avg_sal

						)
			);

#方式2：

SELECT d.*,(SELECT AVG(salary) FROM employees WHERE department_id = d.`department_id`) avg_sal
FROM departments d
WHERE department_id = (
			SELECT department_id
			FROM employees
			GROUP BY department_id
			HAVING AVG(salary ) <= ALL(
						SELECT AVG(salary)
						FROM employees
						GROUP BY department_id
						)
			);

#方式3： LIMIT

SELECT d.*,(SELECT AVG(salary) FROM employees WHERE department_id = d.`department_id`) avg_sal
FROM departments d
WHERE department_id = (
			SELECT department_id
			FROM employees
			GROUP BY department_id
			HAVING AVG(salary ) =(
						SELECT AVG(salary) avg_sal
						FROM employees
						GROUP BY department_id
						ORDER BY avg_sal ASC
						LIMIT 1		
						)
			);

#方式4：

SELECT d.*,(SELECT AVG(salary) FROM employees WHERE department_id = d.`department_id`) avg_sal
FROM departments d,(
		SELECT department_id,AVG(salary) avg_sal
		FROM employees
		GROUP BY department_id
		ORDER BY avg_sal ASC
		LIMIT 0,1
		) t_dept_avg_sal
WHERE d.`department_id` = t_dept_avg_sal.department_id

#10.查询平均工资最高的 job 信息

#方式1：
SELECT *
FROM jobs
WHERE job_id = (
		SELECT job_id
		FROM employees
		GROUP BY job_id
		HAVING AVG(salary) = (
					SELECT MAX(avg_sal)
					FROM (
						SELECT AVG(salary) avg_sal
						FROM employees
						GROUP BY job_id
						) t_job_avg_sal
					)
		);

#方式2：
SELECT *
FROM jobs
WHERE job_id = (
		SELECT job_id
		FROM employees
		GROUP BY job_id
		HAVING AVG(salary) >= ALL(
				     SELECT AVG(salary) 
				     FROM employees
				     GROUP BY job_id
				     )
		);

#方式3：
SELECT *
FROM jobs
WHERE job_id = (
		SELECT job_id
		FROM employees
		GROUP BY job_id
		HAVING AVG(salary) =(
				     SELECT AVG(salary) avg_sal
				     FROM employees
				     GROUP BY job_id
				     ORDER BY avg_sal DESC
				     LIMIT 0,1
				     )
		);

#方式4：
SELECT j.*
FROM jobs j,(
		SELECT job_id,AVG(salary) avg_sal
		FROM employees
		GROUP BY job_id
		ORDER BY avg_sal DESC
		LIMIT 0,1		
		) t_job_avg_sal
WHERE j.job_id = t_job_avg_sal.job_id
		
#11.查询平均工资高于公司平均工资的部门有哪些?

SELECT department_id
FROM employees
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING AVG(salary) > (
			SELECT AVG(salary)
			FROM employees
			);


#12.查询出公司中所有 manager 的详细信息

#方式1：自连接  xxx worked for yyy
SELECT DISTINCT mgr.employee_id,mgr.last_name,mgr.job_id,mgr.department_id
FROM employees emp JOIN employees mgr
ON emp.manager_id = mgr.employee_id;

#方式2：子查询

SELECT employee_id,last_name,job_id,department_id
FROM employees
WHERE employee_id IN (
			SELECT DISTINCT manager_id
			FROM employees
			);

#方式3：使用EXISTS
SELECT employee_id,last_name,job_id,department_id
FROM employees e1
WHERE EXISTS (
	       SELECT *
	       FROM employees e2
	       WHERE e1.`employee_id` = e2.`manager_id`
	     );

	
#13.各个部门中 最高工资中最低的那个部门的 最低工资是多少?

#方式1：
SELECT MIN(salary)
FROM employees
WHERE department_id = (
			SELECT department_id
			FROM employees
			GROUP BY department_id
			HAVING MAX(salary) = (
						SELECT MIN(max_sal)
						FROM (
							SELECT MAX(salary) max_sal
							FROM employees
							GROUP BY department_id
							) t_dept_max_sal
						)
			);

SELECT *
FROM employees
WHERE department_id = 10;

#方式2：
SELECT MIN(salary)
FROM employees
WHERE department_id = (
			SELECT department_id
			FROM employees
			GROUP BY department_id
			HAVING MAX(salary) <= ALL (
						SELECT MAX(salary)
						FROM employees
						GROUP BY department_id
						)
			);

#方式3：
SELECT MIN(salary)
FROM employees
WHERE department_id = (
			SELECT department_id
			FROM employees
			GROUP BY department_id
			HAVING MAX(salary) = (
						SELECT MAX(salary) max_sal
						FROM employees
						GROUP BY department_id
						ORDER BY max_sal ASC
						LIMIT 0,1
						)
			);
			
#方式4：
SELECT MIN(salary)
FROM employees e,(
		SELECT department_id,MAX(salary) max_sal
		FROM employees
		GROUP BY department_id
		ORDER BY max_sal ASC
		LIMIT 0,1
		) t_dept_max_sal
WHERE e.department_id = t_dept_max_sal.department_id


#14.查询平均工资最高的部门的 manager 的详细信息: last_name, department_id, email, salary

#方式1：
SELECT last_name, department_id, email, salary
FROM employees
WHERE employee_id = ANY (
			SELECT DISTINCT manager_id
			FROM employees
			WHERE department_id = (
						SELECT department_id
						FROM employees
						GROUP BY department_id
						HAVING AVG(salary) = (
									SELECT MAX(avg_sal)
									FROM (
										SELECT AVG(salary) avg_sal
										FROM employees
										GROUP BY department_id
										) t_dept_avg_sal
									)
						)
			);

#方式2：
SELECT last_name, department_id, email, salary
FROM employees
WHERE employee_id = ANY (
			SELECT DISTINCT manager_id
			FROM employees
			WHERE department_id = (
						SELECT department_id
						FROM employees
						GROUP BY department_id
						HAVING AVG(salary) >= ALL (
								SELECT AVG(salary) avg_sal
								FROM employees
								GROUP BY department_id
								)
						)
			);

#方式3：
SELECT last_name, department_id, email, salary
FROM employees
WHERE employee_id IN (
			SELECT DISTINCT manager_id
			FROM employees e,(
					SELECT department_id,AVG(salary) avg_sal
					FROM employees
					GROUP BY department_id
					ORDER BY avg_sal DESC
					LIMIT 0,1
					) t_dept_avg_sal
			WHERE e.`department_id` = t_dept_avg_sal.department_id
			);


#15. 查询部门的部门号，其中不包括job_id是"ST_CLERK"的部门号

#方式1：
SELECT department_id
FROM departments
WHERE department_id NOT IN (
			SELECT DISTINCT department_id
			FROM employees
			WHERE job_id = 'ST_CLERK'
			);

#方式2：
SELECT department_id
FROM departments d
WHERE NOT EXISTS (
		SELECT *
		FROM employees e
		WHERE d.`department_id` = e.`department_id`
		AND e.`job_id` = 'ST_CLERK'
		);



#16. 选择所有没有管理者的员工的last_name

SELECT last_name
FROM employees emp
WHERE NOT EXISTS (
		SELECT *
		FROM employees mgr
		WHERE emp.`manager_id` = mgr.`employee_id`
		);

#17．查询员工号、姓名、雇用时间、工资，其中员工的管理者为 'De Haan'

#方式1：
SELECT employee_id,last_name,hire_date,salary
FROM employees
WHERE manager_id IN (
		SELECT employee_id
		FROM employees
		WHERE last_name = 'De Haan'
		);

#方式2：
SELECT employee_id,last_name,hire_date,salary
FROM employees e1
WHERE EXISTS (
		SELECT *
		FROM employees e2
		WHERE e1.`manager_id` = e2.`employee_id`
		AND e2.last_name = 'De Haan'
		); 


#18.查询各部门中工资比本部门平均工资高的员工的员工号, 姓名和工资（相关子查询）

#方式1：使用相关子查询
SELECT last_name,salary,department_id
FROM employees e1
WHERE salary > (
		SELECT AVG(salary)
		FROM employees e2
		WHERE department_id = e1.`department_id`
		);

#方式2：在FROM中声明子查询
SELECT e.last_name,e.salary,e.department_id
FROM employees e,(
		SELECT department_id,AVG(salary) avg_sal
		FROM employees
		GROUP BY department_id) t_dept_avg_sal
WHERE e.department_id = t_dept_avg_sal.department_id
AND e.salary > t_dept_avg_sal.avg_sal


#19.查询每个部门下的部门人数大于 5 的部门名称（相关子查询）

SELECT department_name
FROM departments d
WHERE 5 < (
	   SELECT COUNT(*)
	   FROM employees e
	   WHERE d.department_id = e.`department_id`
	  );


#20.查询每个国家下的部门个数大于 2 的国家编号（相关子查询）

SELECT * FROM locations;

SELECT country_id
FROM locations l
WHERE 2 < (
	   SELECT COUNT(*)
	   FROM departments d
	   WHERE l.`location_id` = d.`location_id`
	 );

/* 
子查询的编写技巧（或步骤）：① 从里往外写  ② 从外往里写
如何选择？
① 如果子查询相对较简单，建议从外往里写。一旦子查询结构较复杂，则建议从里往外写
② 如果是相关子查询的话，通常都是从外往里写。
*/
```






参考：
- http://xpbag.com/496.html#%E5%9B%9B%E3%80%81%E8%81%94%E5%90%88%E6%9F%A5%E8%AF%A2
- https://blog.csdn.net/qq_44111805/article/details/124680208
