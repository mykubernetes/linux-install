索引生命周期管理功能是elasticsearch 在 6.7.0 引入的。此功能主要是用于管理时间序列数据的索引。

对于时间序列的索引，生命周期有4个阶段：
- hot: 索引被频繁写入和查询
- warm: 索引不再写入，但是仍在查询
- cold: 索引很久不被更新，同时很少被查询。但现在考虑删除数据还为时过早，仍然有需要这些数据的可能，但是可以接受较慢的查询响应。
- delete: 索引不再需要，可以删除。

一个index将在热的阶段开始，然后是温，冷，最后是删除阶段，生命周期策略控制索引如何在这些阶段中转换以及在每个阶段对索引执行的操作。

# 创建生命周期策略

下面是一个创建生命周期的例子，策略不一定需要为索引配置每个阶段:
```
PUT _ilm/policy/full_policy      //full_policy 策略名
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {         // 滚动索引
            "max_age": "7d",
            "max_size": "50G"
          },
          "set_priority": {
            "priority": 100    // 优先加载
          }
        }
      },
      "warm": {
        "min_age": "30d",
        "actions": {
          "forcemerge": {
            "max_num_segments": 1    // force merge 
          },
          "shrink": {                // 压缩shard
            "number_of_shards": 1
          },
          "allocate": {
            "number_of_replicas": 2  // 分配副本
          },
          "set_priority": {
            "priority": 50
          }
        }
      },
      "cold": {
        "min_age": "60d",
        "actions": {
          "freeze" : {}            // 冷冻
        }
      },
      "delete": {
        "min_age": "90d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

# 时间参数

索引根据时间参数min_age进入生命周期阶段，若未设置，默认是0ms。min_age通常是从创建索引的时间开始计算，如果索引被设置为滚动索引，那么min_age是从索引滚动开始计算。注意，在检查min_age参数并进入下一个阶段前，当前阶段的操作必须完成。

# action

| 阶段\action | 优先级设置 | 取消跟随 | 滚动索引 | 分片分配 | 只读 | 强制段合并 | 收缩索引 | 冻结索引 | 删除 |
|-------------|-----------|---------|---------|----------|-----|-----------|----------|---------|-----|
| hot | √ | √ | √ | × | × | × | × | × | × |
| warm | √ | √ | × | √ | √ | √ | √ | × | × |
| cold | √ | √ | × | √ | × | × | × | √ | × |
| delete | × | × | × | × | × | × | × | × | √ |

## 优先级设置

这个action等同于设置索引属性index.priority的值。具有较高优先级的索引将在节点重启后优先恢复。通常，热阶段的指数应具有最高值，而冷阶段的指数应具有最低值。未设置此值的指标的隐含默认优先级为1。索引的优先级。必须为0或更大。也可以设置为null以删除优先级。
```
{
  "set_priority" : {
      "priority": 50
  }
}
```

## 滚动索引

使用滚动索引有几个注意事项：

索引命名必须`^.*-\\d+$`
索引必须设置index.lifecycle.rollover_alias为滚动的别名。索引还必须是别名的写入索引。
```
PUT log-000001
{
  "settings": {
    "index.lifecycle.name": "my_policy",
    "index.lifecycle.rollover_alias": "log_write"
  },
  "aliases": {
    "logs_write": {
      "is_write_index": true   // true表示索引是别名的当前写入索引。
    }
  }
}
```

| 名称 | 描述 |
|-----|------|
| max_size | 索引所有主分片最大存储大小 |
| max_docs | 滚动前索引要包含的最大文档数 |
| max_age | 索引创建后的最长时间 |

## 分片分配

| 名称 | 描述 |
|-----|------|
| number_of_replicas | 要分配给索引的副本数 |
| include | 为具有至少一个属性的节点分配索引 |
| exclude | 为没有任何属性的节点分配索引 |
| require | 为具有所有属性的节点分配索引 |

## 强制合并

使用强制合并时，索引将变成只读。
```
PUT _ilm/policy/my_policy
{
  "policy": {
    "phases": {
      "warm": {
        "actions": {
          "forcemerge" : {
            "max_num_segments": 1  //合并后的shard里的lucene segments数,
          }
        }
      }
    }
  }
}
```

## 收缩索引

使用收缩索引时，索引将变成只读。收缩索引API允许您将现有索引缩减为具有较少主分片的新索引。目标索引中请求的主分片数必须是源索引中分片数的一个因子。如果索引中的分片数是素数，则只能缩小为单个主分片。

新索引将有一个新名称：`shrink-<origin-index-name>`。因此，如果原始索引称为“logs”，则新索引将命名为“shrink-logs”。
```
PUT _ilm/policy/my_policy
{
  "policy": {
    "phases": {
      "warm": {
        "actions": {
          "shrink" : {
            "number_of_shards": 1
          }
        }
      }
    }
  }
}
```

## 冻结索引

为了使索引可用且可查询更长时间但同时降低其硬件要求，它们可以转换为冻结状态。一旦索引被冻结，它的所有瞬态分片内存（除了映射和分析器）都会被移动到持久存储。
```
PUT _ilm/policy/my_policy
{
  "policy": {
    "phases": {
      "cold": {
        "actions": {
          "freeze" : { }
        }
      }
    }
  }
}
```
注意冻结一个索引会close并reopen,这会导致短时间内不可用，集群会变red，直到这个索引的分片分配完毕。

# 应用策略

1、直接应用到索引
```
PUT test-index
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1,
    "index.lifecycle.name": "my_policy"
  }
}
不要将create index API与定义rollover操作的策略一起使用。如果这样做，作为滚动结果的新索引将不会继承该策略。始终使用索引模板来定义具有滚动操作的策略。

1、应用到模板
```
UT _template/my_template
{
  "index_patterns": ["test-*"], 
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1,
    "index.lifecycle.name": "my_policy", 
    "index.lifecycle.rollover_alias": "test-alias" // rollover 别名
  }
}
 
PUT test-000001
{
  "aliases": {
    "test-alias":{
      "is_write_index": true 
    }
  }
}
```

# 更新策略

1、如果没有index应用这份策略，那么我们可以直接更新该策略。  
2、如果有index应用了这份策略，那么当前正在执行的阶段不会同步修改，当当前阶段结束后，会进入新版本策略的下个阶段。  
3、如果更换了策略，当前正在执行的阶段不会变化，在结束当前阶段后，将会由新的策略管理下一个生命周期。  

# 策略错误处理

当在生命周期策略处理中出现异常时，会进入错误阶段，停止策略的执行。
```
GET /myindex/_ilm/explain
```

使用上述API可以看到异常的原因，当解决这个问题，并更新策略后，可以通过下面的API进行重试：
```
POST /myindex/_ilm/retry
```

# ilm的启用禁用

ilm的状态查看：
```
GET _ilm/status
{
  "operation_mode": "RUNNING"
}
```

| Name | Description |
|------|-------------|
| RUNNING | Normal operation where all policies are executed as normal |
| STOPPING | ILM has received a request to stop but is still processing some policies |
| STOPPED | This represents a state where no policies are executed |

开启和关闭：
```
POST _ilm/start
POST _ilm/stop
```
参考：
- https://www.elastic.co/guide/en/elasticsearch/reference/current/_actions.html#ilm-rollover-action
- https://www.elastic.co/guide/en/elasticsearch/reference/current/_actions.html#ilm-rollover-action


参考：
- https://www.elastic.co/guide/en/elasticsearch/reference/7.5/getting-started-index-lifecycle-management.html
- https://blog.csdn.net/m0_37635053/article/details/128570369
- https://www.bbsmax.com/A/kPzO9oa15x/
