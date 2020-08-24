索引
---

写入测试数据
```
> use testdb

> for (i=1;i<=10000;i++) db.students.insert({name: "student"+i,age:(i%120), address: "#89 Wenhua Road, Zhengzhou, China"})

> db.students.find().count()
10000

构建索引，在name创建一个升序的所有
> db.students.ensureIndex({name: 1})
{
	"createdCollectionAutomatically" : false,
	"numIndexesBefore" : 1,
	"numIndexesAfter" : 2,
	"ok" : 1
  

显示索引个数
> db.students.getIndexes()
[
	{
		"v" : 2,
		"key" : {
			"_id" : 1
		},
		"name" : "_id_",
		"ns" : "testdb.students"
	},
	{
		"v" : 2,
		"key" : {
			"name" : 1
		},
		"name" : "name_1",
		"ns" : "testdb.students"
	}
]

删除索引
> db.students.dropIndex("name_1")
{ "nIndexesWas" : 2, "ok" : 1 }

再次查看索引个数
> db.students.getIndexes()
[
	{
		"v" : 2,
		"key" : {
			"_id" : 1
		},
		"name" : "_id_",
		"ns" : "testdb.students"
	}
]

构建唯一键索引
> db.students.ensureIndex({name: 1},{unique: true})
{
	"createdCollectionAutomatically" : false,
	"numIndexesBefore" : 1,
	"numIndexesAfter" : 2,
	"ok" : 1
}

插入数据测试，不能插入
> db.students.insert({name: "student20", age: 20})
WriteResult({
	"nInserted" : 0,
	"writeError" : {
		"code" : 11000,
		"errmsg" : "E11000 duplicate key error collection: testdb.students index: name_1 dup key: { : \"student20\" }"
	}
})
```
