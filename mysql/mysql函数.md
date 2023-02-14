```
select pipeline_name from pipeline where pipline_name like '%_trigger_%' and cast(substring_index(pipeline_name),'_',-1) as signed) <= cast('1676016656' as signed)*1000

delete from pipeline where pipline_name like '%_trigger_%' and cast(substring_index(pipeline_name),'_',-1) as signed) <= cast('1676016656' as signed)*1000
```

参考：
- https://www.cnblogs.com/kissdodog/p/4168721.html
- https://zhuanlan.zhihu.com/p/360367679
