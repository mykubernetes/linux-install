ElasticSearch聚合查询
求和
最大值
最小值
平均值
去重
百分比
占比
中位数
topN
分组聚合


# 一、ES聚合分析查询的写法
```
"aggregations" : {
    "<aggregation_name>" : {                                 <!--聚合的名字 -->
        "<aggregation_type>" : {                             <!--聚合的类型 -->
            <aggregation_body>                               <!--聚合体：对哪些字段进行聚合 -->
        }
        [,"meta" : {  [<meta_data_body>] } ]?                <!--元 -->
        [,"aggregations" : { [<sub_aggregation>]+ } ]?       <!--在聚合里面在定义子聚合 -->
    }
}
```

# 二、求和（Sum）

- 求所有老师的薪资总和
- size:0，参数表示不用返回文档列表，只返回汇总的数据即可

```
GET teacher_info/_search
{
  "size":0,
  "aggs":{
    "sum_salary":{
      "sum":{
        "field":"salary"
      }
    }
  }
}
```

# 三、最大值（Max）

- 求薪资最大值

```
GET /teacher_info/_search
{
    "size":0,
    "aggs":{
        "max_salary":{
            "max":{
                "field":"salary"
            }
        }
    }
}
```

# 四、最小值（Min）

- 求薪资最小值

```
GET /teacher_info/_search
{
    "size":"0",
    "aggs":{
        "min_salary":{
            "min":{
                "field":"salary"
            }
        }
    }
}
```

# 五、平均值（Avg）

- 求薪资平均值

```
GET /teacher_info/_search
{
    "size":"0",
    "aggs":{
        "avg_salary":{
            "avg":{
                "field":"salary"
            }
        }
    }
}
```

# 六、去重数值（cardinality）

- 类似mysql的count distinct
- 案例：老师一共教了多少学科

```
GET /teacher_info/_search
{
  "size":0,
  "aggs":{
    "job_count":{
      "cardinality": {
        "field": "job.keyword"
      }
    }
  }
}
```

# 七、多值查询-最大最小值和平均值

- 查询最低、最高和平均工资

```
GET /teacher_info/_search
{
  "size":0,
  "aggs":{
    "max_salary":{
      "max":{
        "field":"salary"
      }
    },
    "min_salary":{
      "min":{
        "field":"salary"
      }
    },
    "avg_salary":{
      "avg":{
        "field":"salary"
      }
    }
  }
}
```

# 八、返回多个聚合值(Status)

- stats统计，请求后会直接显示多种聚合结果，总记录数，最大值，最小值，平均值，汇总值

```
GET /teacher_info/_search
{
  "size":0,
  "aggs":{
    "salary_stats":{
      "stats":{
        "field":"salary"
      }
    }
  }
}
```

# 九、百分比(Percentiles)

- 对指定字段的值按从小到大累计每个值对应的文档数的占比，返回指定占比比例对应的值

```
GET /teacher_info/_search
{
  "size":0,
  "aggs":{
    "age_percentiles":{
      "percentiles":{
        "field":"age"
      }
    }
  }
}
```

key-value形式返回，添加参数"keyed":false
```
GET /teacher_info/_search
{
  "size":0,
  "aggs":{
    "age_percentiles":{
      "percentiles":{
        "field":"age",
        "keyed":false
      }
    }
  }
}
```

# 十、文档值占比(Percentile Ranks)

- 这里指定值，查占比。注意占比是小于文档值的比例
```
GET /teacher_info/_search
{
  "size":0,
  "aggs":{
    "age_percentiles":{
      "percentile_ranks":{
        "field":"age",
        "values":[22,25,33]
      }
    }
  }
}
```

# 十一、中位数查询

- 求工资中位数

```
GET /teacher_info/_search
{
  "size":0,
  "aggs":{
    "load_time_outlier":{
      "percentiles":{
        "field":"salary",
        "percents":[50,99],
        "keyed":false
      }
    }
  }
}
```

# 十二、分组取Top N之（Top Hits）

- 根据性别分组，展示工资排名top3
```
GET /teacher_info/_search?size=0
{
  "aggs":{
    "top_tags":{
      "terms":{
        "field":"sex"
      },
      "aggs":{
        "top_sales_hits":{
          "top_hits":{
            "sort":[
              {
                "salary":{
                  "order":"desc"
                }
              }
            ],
            "_source":{
              "includes":["name","sex","salary"]
            },
            "size":3
          }
        }
      }
    }
  }
}
```

# 十三、分组之聚合

- 根据性别分组求平均工资
```
GET /teacher_info/_search
{
  "size":0,
  "aggs":{
    "top_tags":{
      "terms":{
        "field":"sex"
      },
      "agg":{
        "avg_salary":{
          "avg":{
            "field":"salary"
          }
        }
      }
    }
  }
}
```

# 十四、总记录数查询

- 类似mysql的count
```
# 方式1：统计年龄>=25的记录数
GET /teacher_info/_count
{
  "query":{
    "range":{
      "age":{
        "gte":25
      }
    }
  }
}
# 方式2：统计年龄>=25的记录数
GET teacher_info/_search?size=0
{
  "query":{
    "range":{
      "age":{
        "gte":25
      }
    }
  }
}
```
