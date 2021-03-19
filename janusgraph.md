官网  
https://docs.janusgraph.org/

github  
https://github.com/JanusGraph/janusgraph/releases/

提供了Gremlin和SQL语句的转化样例，帮助快速上手Gremlin图查询语言  
http://sql2gremlin.com/提供了Gremlin和SQL语句的转化样例，帮助快速上手Gremlin图查询语言

Gremlin中文文档  
http://tinkerpop-gremlin.cn/

https://blog.csdn.net/weixin_39409615/article/details/101519438

https://www.jianshu.com/p/83e46d70dd92


基础语句
| 用法 | 说明 |
|------|-----|
| graph = JanusGraphFactory.open('conf/gremlin-server/socket-janusgraph-hbase-server.properties') | 打开数据库连接 |
| g=graph.traversal() | 的到实列 |
| V() | 查询顶点，一般作为图查询的第1步，后面可以续接的语句种类繁多。例，g.V()，g.V('v_id')，查询所有点和特定点； |
| E() | 查询边，一般作为图查询的第1步，后面可以续接的语句种类繁多； |
| id() | 获取顶点、边的id。例：g.V().id()，查询所有顶点的id； |
| label() | 获取顶点、边的 label。例：g.V().label()，可查询所有顶点的label。 |
| key() / values() | 获取属性的key/value的值。 |
| properties() | 获取顶点、边的属性；可以和 key()、value()搭配使用，以获取属性的名称或值。例：g.V().properties('name')，查询所有顶点的 name 属性； |
| valueMap() | 获取顶点、边的属性，以Map的形式体现，和properties()比较像； |
| values() | 获取顶点、边的属性值。例，g.V().values() 等于 g.V().properties().value() |

遍历（以定点为基础）
| 用法 | 说明 |
|------|-----|
| out(label) | 根据指定的 Edge Label 来访问顶点的 OUT 方向邻接点（可以是零个 Edge Label，代表所有类型边；也可以一个或多个 Edge Label，代表任意给定 Edge Label 的边，下同）； |
| in(label) | 根据指定的 Edge Label 来访问顶点的 IN 方向邻接点； |
| both(label) | 根据指定的 Edge Label 来访问顶点的双向邻接点； |
| outE(label) | 根据指定的 Edge Label 来访问顶点的 OUT 方向邻接边； |
| inE(label) | 根据指定的 Edge Label 来访问顶点的 IN 方向邻接边； |
| bothE(label) | 根据指定的 Edge Label 来访问顶点的双向邻接边； |

遍历（以边为基础）
| 用法 | 说明 |
|------|-----|
| outV() | 访问边的出顶点，出顶点是指边的起始顶点； |
| inV() | 访问边的入顶点，入顶点是指边的目标顶点，也就是箭头指向的顶点； |
| bothV() | 访问边的双向顶点； |
| otherV() | 访问边的伙伴顶点，即相对于基准顶点而言的另一端的顶点； |

过滤
| 用法 | 说明 |
|------|-----|
| has(key,value) | 通过属性的名字和值来过滤顶点或边； |
| has(label, key, value) | 通过label和属性的名字和值过滤顶点和边； |
| has(key,predicate) | 通过对指定属性用条件过滤顶点和边，例：g.V().has('age', gt(20))，可得到年龄大于20的顶点； |
| hasLabel(labels…) | 通过 label 来过滤顶点或边，满足label列表中一个即可通过； |
| hasId(ids…) | 通过 id 来过滤顶点或者边，满足id列表中的一个即可通过； |
| hasKey(keys…) | 通过 properties 中的若干 key 过滤顶点或边； |
| hasValue(values…) | 通过 properties 中的若干 value 过滤顶点或边； |
| has(key) | properties 中存在 key 这个属性则通过，等价于hasKey(key)； |
| hasNot(key) | 和 has(key) 相反； |
