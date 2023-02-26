```
select pipeline_name from pipeline where pipline_name like '%_trigger_%' and cast(substring_index(pipeline_name),'_',-1) as signed) <= cast('1676016656' as signed)*1000

delete from pipeline where pipline_name like '%_trigger_%' and cast(substring_index(pipeline_name),'_',-1) as signed) <= cast('1676016656' as signed)*1000

## 查询中台定时批作业启动中、待启动、运行中的任务超过三十分钟的
select
	tmp.pipeline_name,
	tmp.trigger_name,
	tmp.start_time,
	tmp.pipeline_status,
	tmp.time_diff
	from
	(select 
		p.pipeline_name,
		t.pipeline_name as trigger_name,
		p.pipeline_status,
		FROM_UNIXTIME(SUBSTR(t.create_time,1,10),'%Y-%m-%d %H:%i:%s') as start_time,
		TIMESTAMPDIFF(MINUTE,FROM_UNIXTIME(SUBSTR(t.create_time,1,10),'%Y-%m-%d %H:%i:%s'),NOW()) as time_diff
		from 
		jax_db.tb_pipeline p
	left join jax_db.tb_pipeline t 
		on p.pipeline_name = t.trigger_by
	where
		p.pipeline_type = 'batch_schedule'
		and t.pipeline_status = 'RUNNING'
		or t.pipeline_status = 'STARTING'
		or t.pipeline_status = 'WAITING_START'
		) tmp
		where tmp.time_diff > 30 order by time_diff desc;
		

## 查询最近运行失败累计次数超过3次的任务
select 
	tmp.pipeline_name,
	count(*) as nums
	from
	(select 
		p.pipeline_name,
		t.pipeline_name as trigger_name
		from 
		jax_db.tb_pipeline p
	left join jax_db.tb_pipeline t 
		on p.pipeline_name = t.trigger_by
	where
		p.pipeline_type = 'batch_schedule'
		and t.pipeline_status = 'FAILED')tmp
		group by tmp.pipeline_name having nums > 3 order by nums desc;
```

参考：
- https://www.cnblogs.com/kissdodog/p/4168721.html
- https://zhuanlan.zhihu.com/p/360367679
- https://blog.csdn.net/Sheenky/article/details/125142451
- https://blog.csdn.net/qq_52253798/article/details/121588253
- https://www.cnblogs.com/thomasbc/p/15205130.html
- https://www.cnblogs.com/hanease/p/15690141.html
