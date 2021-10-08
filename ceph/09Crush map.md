http://docs.ceph.org.cn/rados/operations/crush-map/

# 一、手动设置存储池规则

1、查看每个pool的详细信息，可以查看每个pool使用的crush_rule规则
```
# ceph osd pool ls detail
```

2、查看存储池有哪些规则
```
# ceph osd crush rule ls
```

3、查看存储池有哪些规则的详细信息
```
# ceph osd crush rule dump
[
    {
        "rule_id": 0,
        "rule_name": "replicated_rule",
        "ruleset": 0,
        "type": 1,
        "min_size": 1,
        "max_size": 10,
        "steps": [
            {
                "op": "take",
                "item": -1,
                "item_name": "default"
            },
            {
                "op": "chooseleaf_firstn",
                "num": 0,
                "type": "host"
            },
            {
                "op": "emit"
            }
        ]
    },
......
]
```

4、这是存储池使用哪条规则
```
# 语法ceph osd pool set {{pool_name}} crush_rule {{crush_rule_name}}
```

# 二、生产环境存储池迁移
```
# 暂时关闭数据迁移
ceph osd set norecover
ceph osd set nobackfill
ceph osd set norebalance

# 创建crush map使用ssd作为存储的规则
ceph osd crush rule create-simple rule-ssd default host

# 将hdd_rule的存储规则切换到ssd_rule
ceph osd pool set ssd_rule crush_rule ssd_rule
    
# 观察ceph -s的输出，直到PG状态都离开peering进入active+
watch ceph -s

# 发动数据迁移
ceph osd unset norecover
ceph osd unset nobackfill
ceph osd unset norebalance

# 观察ceph -s的输出，直到PG状态都离开进入active+clean
watch ceph -s
```

# 三、编辑 Crush map

1、从任何Mon节点获取Crush map  
```
# ceph osd getcrushmap -o crushmap_compiled_file
```  

2、对其反编译，将其转换为认类可读/可编辑的形式  
```
# crushtool -d crushmap_compiled_file -o crushmap_decompiled_file
```  

3、此时，可以在编辑器中编辑了  
```
# vim crushmap_decompiled_file
```

4、完成编辑后，编译这些更改  
```
# crushtool -c crushmap_decompiled_file -o newcrushmap
```  

5、将新映射应用到集群前，使用crushtool命令及--show-mappings选项来验证
```
# crushool -i newcrushmap --test --show-mappings --rule=5 --num-rep 3
```

6、将新编译后的 Crush map 注入 Ceph 集群  
```
# ceph osd setcrushmap -i newcrushmap
```



# 四、Crush map 介绍

CRUSH Map主要分为以下几个部分
- Tunables: 可调整的参数列表（仅一部分，非完整列表）
- Devices: 存储设备列表，列举了集群中所有的OSD
- Types: 类型定义，一般0为OSD，其它正整数代表host、chassis、rack等
- Buckets: 容器列表，指明了每个bucket下直接包含的children项及其权重值（非OSD的items统称为bucket）
- Rules: 规则列表，每个规则定义了一种选取OSD的方式

## 1)tunable（可调参数）
```
# begin crush map                     # 选择存放副本位置时的选择算法策略中的变量配置
tunable choose_local_tries 0
tunable choose_local_fallback_tries 0
tunable choose_total_tries 50
tunable chooseleaf_descend_once 1
tunable chooseleaf_vary_r 1
tunable chooseleaf_stable 1
tunable straw_calc_version 1
tunable allowed_bucket_algs 54
```

从版本v0.74开始，如果当前CRUSH可调参数不包含default配置文件中的所有最佳值，Ceph将发出运行状况警告。要使此警告消失，您有两种选择：  

方法一：切换为最优版  
```
# ceph osd crush tunables optimal
```  

方法二：不让它警告  
```
## 在 ceph.conf [mon] 部分 添加
mon warn on legacy crush tunables = false

## 使用命令立即生效
ceph tell mon.\* config set mon_warn_on_legacy_crush_tunables false
```  

可调参数最简单的使用方法，就是使用 crush 内置的配置文件  
- legacy：来自argonaut和更早的遗留行为。
- argonaut：原始argonaut版本支持的遗留值
- bobtail：bobtail发行版支持的值
- firefly：firefly发行版支持的值
- hammer：锤子释放支持的值
- jewel：宝石版本支持的值
- optimal：当前版本Ceph的最佳（即最佳）值
- default：默认为default。这些值取决于当前版本的Ceph，是硬编码的，通常是最佳值和传统值的混合。这些值通常与optimal之前LTS版本的配置文件相匹配，或者通常与我们通常除了更多用户拥有最新客户端的最新版本匹配。

设置  
```
# ceph osd crush tunables {PROFILE}
# ceph osd crush show-tunables          # 查看目前使用的参数
```  
- 请注意，这可能会导致一些数据移动。

## 2）devices（设备）
- 包含集群中所有 OSD 设备列表。OSD 是与ceph-osd守护程序对应的物理磁盘。要将PG映射到OSD设备，CRUSH需要OSD设备列表。
```
# devices
device 0 osd.0 class hdd
device 1 osd.1 class hdd
device 2 osd.2 class hdd
device 3 osd.3 class hdd
device 4 osd.4 class hdd
device 5 osd.5 class hdd
device 6 osd.6 class hdd
device 7 osd.7 class hdd
device 8 osd.8 class hdd
```

3）types（存储桶类型）
- 存储桶由物理位置（例如，行，机架，机箱，主机等）的分层聚合及其分配的权重组成。它们促进节点和叶子的层次结构，其中节点桶表示物理位置，叶片桶代表ceph-osd守护进程及其底层物理设备。
```
# types                   # 树形下的多种类型
type 0 osd                # osd守护进程，一般一个osd对应一个磁盘
type 1 host               # 一个包含一个或多个osds的主机名，表示是一个主机。
type 2 chassis            # 系列
type 3 rack               # 一个包含一个或多个主机的计算机机柜
type 4 row                # 第几排机柜
type 5 pdu                # 
type 6 pod                # 
type 7 room               # 一个房间包含机柜和排，主机
type 8 datacenter         # 一个数据中心包含多个房间
type 9 region             # 一个区域包含多个数据中心
type 10 root              # 根
```

通过以下方式获取集群的 Crush 简单的层次结构
```
ceph osd crush tree
```

## 4）buckets（存储桶实例）

```
host node65 {
        id -3           # do not change unnecessarily
        id -4 class hdd         # do not change unnecessarily
        # weight 0.195
        alg straw2
        hash 0  # rjenkins1
        item osd.0 weight 0.098
        item osd.2 weight 0.098
}
host node66 {
        id -5           # do not change unnecessarily
        id -6 class hdd         # do not change unnecessarily
        # weight 0.195
        alg straw2
        hash 0  # rjenkins1
        item osd.1 weight 0.098
        item osd.3 weight 0.098
}
root default {
        id -1           # do not change unnecessarily
        id -2 class hdd         # do not change unnecessarily
        # weight 0.391
        alg straw2
        hash 0  # rjenkins1
        item node65 weight 0.195
        item node66 weight 0.195
}
host pig-node65 {
        id -7           # do not change unnecessarily
        id -11 class hdd                # do not change unnecessarily
        # weight 2.000
        alg straw2
        hash 0  # rjenkins1
        item osd.0 weight 1.000
        item osd.2 weight 1.000
}
rack pig-rack1 {
        id -8           # do not change unnecessarily
        id -12 class hdd                # do not change unnecessarily
        # weight 2.000
        alg straw2
        hash 0  # rjenkins1
        item pig-node65 weight 2.000
}
host pig-node66 {
        id -15          # do not change unnecessarily
        id -17 class hdd                # do not change unnecessarily
        # weight 2.000
        alg straw2
        hash 0  # rjenkins1
        item osd.1 weight 1.000
        item osd.3 weight 1.000
}
rack pig-rack2 {
        id -16          # do not change unnecessarily
        id -18 class hdd                # do not change unnecessarily
        # weight 2.000
        alg straw2
        hash 0  # rjenkins1
        item pig-node66 weight 2.000
}
room pig-room {
        id -9           # do not change unnecessarily
        id -13 class hdd                # do not change unnecessarily
        # weight 4.000
        alg straw2
        hash 0  # rjenkins1
        item pig-rack1 weight 2.000
        item pig-rack2 weight 2.000
}
root piglet {
        id -10          # do not change unnecessarily
        id -14 class hdd                # do not change unnecessarily
        # weight 4.000
        alg straw2
        hash 0  # rjenkins1
        item pig-room weight 4.000
}
```
- bucket-name： 唯一的存储桶名称。
- id： 唯一ID,使用负整数表示。
- weight： Ceph在群集磁盘上均匀地写入数据，这有助于提高性能并改善数据分发。这会强制所有磁盘都参与群集，并确保所有群集磁盘的使用均等，而不管其容量如何。为此，Ceph使用加权机制。CRUSH为每个OSD分配权重。OSD的权重越高，它的物理存储容量就越大。权重是设备容量之间的相对差异。我们建议使用1.00作为1 TB存储设备的相对重量。类似地，0.5的重量代表大约500GB，而3.00的重量代表大约3TB。
- alg： Ceph支持多种算法桶类型供您选择。这些算法在性能和重组效率的基础上彼此不同。让我们简要介绍一下这些桶类型
  - uniform： 如果存储设备 具有完全相同的权重 ，则可以使用。对于非均匀权重，不应使用此桶类型。添加或删除此存储桶类型中的设备需要对数据进行完全重新调整，这使得此存储桶类型的效率降低。
  - list： 将其内容聚合为链接列表，并且可以包含具有任意权重的存储设备。在群集扩展的情况下，可以将新的存储设备添加到链表的头部，并且数据迁移最少。但是，存储设备的移除需要大量的数据移动。此外，list对于小文件有效，但它们可能不适合大型文件。
  - tree： 将其项目存储在二叉树中。它比列表桶更有效，因为桶包含更多的项目。树桶结构为加权二叉搜索树，叶子上有项目。每个内部节点知道其左右子树的总权重，并根据固定策略进行标记。该tree桶是一个全能的福音，提供了出色的性能和不俗的重组效率。
  - straw： 要使用list和tree桶选择项目，需要计算有限数量的哈希值并按权重进行比较。他们使用分而治之的策略，该策略优先于某些项目（例如，列表开头的那些项目）。这提高了副本放置过程的性能，但是当桶内容由于添加，删除或重新加权而发生变化时，它会引入适度的重组。
  - straw2： 这是一个改进的straw存储桶，当A和B的权重都没有改变时，它可以正确地避免A和B项之间的任何数据移动。换句话说，如果我们通过向其添加新设备来调整项目C的权重，或者通过完全删除它来调整项目C的权重，则数据移动将发生在C中或从C发生，永远不会发生在存储桶中的其他项目之间。因此，straw2桶算法减少了对群集进行更改时所需的数据迁移量。
- hash： 每个桶使用哈希算法。0为默认设置，即 rjenkins1
- item： 桶可能有一个或多个项目。这些项目可能包含节点桶或叶子

## 5）rules（规则）
- CRUSH map 包含CRUSH规则确定池的数据放置。顾名思义，这些是定义池属性和数据存储在池中的方式的规则。它们定义了允许CRUSH在Ceph集群中存储对象的复制和放置策略。默认CRUSH映射包含默认池的规则，即rbd。

```
# rules
rule replicated_rule {                         # rule的名称
        id 0                                   # rule ID
        type replicated                        # replicated代表适用于副本池，erasure代表适用于EC池
        min_size 1                             # 副本数最小值
        max_size 10                            # 副本数最大值
        step take default                      # 选择一个root bucket，做下一步的输入
        step chooseleaf firstn 0 type host     # 选择host级别到一个osd
        step emit                              # 提交
}
rule pig-rep {
        id 1
        type replicated
        min_size 1
        max_size 10
        step take piglet
        step chooseleaf firstn 0 type rack
        step emit
}
rule my-ec3 {
        id 2
        type erasure
        min_size 3
        max_size 5
        step set_chooseleaf_tries 5
        step set_choose_tries 100
        step take piglet
        step chooseleaf indep 0 type rack
        step emit
}
# end crush map
```
- step choose firstn  1 type row 可以分解为: `step <1> <2> <3> type <4>`
  - <1>: choose/chooseleaf
    - choose表示选择结果类型为故障域（由<4>指定）
    - chooseleaf表示在确定故障域后，还必须选出该域下面的OSD节点（即leaf）
  - <2>: firstn/indep
    - firstn: 适用于副本池，选择结果中rep（replica，指一份副本或者EC中的一个分块，下同）位置无明显意义
    - indep: 适用于EC池，选择结果中rep位置不可随意变动
    - 举例来说，副本池中每份副本保存的是完全相同的数据，因此选择结果为[0, 1, 2]（数字代表OSD编号）与[0, 2, 1]并无大的不同。但是EC池不一样，在2+1的配比下前两份是数据块，最后一份是校验块，后两份rep位置一交换就会导致数据出错。
  - <3>: num_reps 这个整数值指定需要选择的rep数目，可以是正值负值或0。
    - 正整数值即代表要选择的副本数，非常直观
    - 0表示的是与实际逻辑池的size相等；也就是说，如果2副本池用了这个rule，0就代表了2；如果3副本池用了此rule，0就相当于3
    - 负整数值代表与实际逻辑池size的差值；如果3副本池使用此rule将该值设为了-1，那边该策略只会选择出2个reps
  - <4>: failure domain
    - 指定故障域类型；CRUSH确保同一故障域最多只会被选中一次。

## Rule执行流程

1、osd级别，数据寻址
```
# rule
step take default
step choose firstn 3 type osd
step emit

# choose flow
rep=0, host=ceph0, go deeper -> osd=osd.0, OK
rep=1, host=ceph1, go deeper -> osd=osd.2, OK
rep=2, host=ceph0, go deeper -> osd=osd.1, OK
```
- 最后选中了同一个host ceph0下的两个OSD。在实际应用中，通常不会以OSD为故障域，而是使用高级的bucket（如host，rack）等作为故障域

2、host级别数据寻址
```
# rule
step take default
step choose firstn 3 type host
step emit
# choose flow
rep=0, host=ceph0, OK
rep=1, host=ceph1, OK
rep=2, host=ceph2, OK
```
- 最后只选到了host而没有OSD，那么数据的最终存放位置并没有确定，这个rule的设置不合理。

3、host级别数据寻址到指定osd,再增加一步choose
```
step take default
step choose firstn 3 type host
step choose firstn 1 type osd
step emit
```
新增的一步会在上述基础上，再以每个选中的host为起点，在host下选择1个OSD。另一个更方便的方案

4、精简写法同上一样，使用chooseleaf
```
step take default
step chooseleaf firstn 3 type host
step emit
```
- 这样在选中一个failure_domain type的bucket后，会递归调用一次choose函数来选择一个该bucket下的OSD。

## 纠删规则

1、配置纠删规则
```
ceph osd erasure-code-profile set my-ec3 k=3 m=2 ruleset-failure-domain=rack crush-root=piglet
```

2、查看纠删配置：
```
# ceph osd erasure-code-profile get my-ec3
crush-device-class=
crush-failure-domain=rack
crush-root=piglet
jerasure-per-chunk-alignment=false
k=3
m=2
plugin=jerasure
technique=reed_sol_van
w=8
```

3、创建crush map规则
```
# ceph osd crush rule create-erasure {rule_name} {ec-profile}
# ceph osd crush rule create-erasure my-ec3  my-ec3
```

4、创建副本池
```
# ceph osd pool create {pool-name} {pg-num} [{pgp-num}] [replicated] [crush-ruleset-name]

# ceph osd pool create my-rep-pool 8 8 replicated pig-rep
pool 4 'my-rep-pool' replicated size 2 min_size 1 crush_rule 1 object_hash rjenkins pg_num 8 pgp_num 8 last_change 41 flags hashpspool stripe_width 0
```

5、创建纠删池
```
# ceph osd pool create {pool-name} {pg-num}  {pgp-num}   erasure  [erasure-code-profile] [rule-name]

# ceph osd pool create test-1 8 8 erasure my-ec3 my-ec3
pool 7 'test-1' erasure size 5 min_size 4 crush_rule 2 object_hash rjenkins pg_num 8 pgp_num 8 
```

6、替换其他存储池crush map规则
```
ceph osd pool set [pool-name] crush_rule [rule-name]
```

# 五、命令创建crush rule示例

### 添加osd的在root下的系统拓扑
```
# host级别
ceph osd crush add osd.{osd_id} {osd weight} root={root_rulename} host={hostname}

# rack级别
ceph osd crush add osd.{osd_id} {osd weight} root={root_rulename} rack={rack_name} host={hostname}

# room级别
ceph osd crush add osd.{osd_id} {osd weight} root={root_rulename} room={room_name} rack={rack_name} host={hostname}


# 部署命令
ceph osd crush add osd.0 1 root=piglet room=pig-room rack=pig-rack1 host=pig-node65
ceph osd crush add osd.1 1 root=piglet room=pig-room rack=pig-rack2 host=pig-node66
ceph osd crush add osd.2 1 root=piglet room=pig-room rack=pig-rack1 host=pig-node65
ceph osd crush add osd.3 1 root=piglet room=pig-room rack=pig-rack2 host=pig-node66

# 副本规则
# rack级别
ceph osd crush rule create-simple {rule_name} root rack

# room级别
ceph osd crush rule create-simple {rule_name} root room

# host级别
ceph osd crush rule create-simple {rule_name} root host
```

1、添加root类型的bucket
```
# 创建一个新的桶叫ssd ，级别是root最高级
ceph osd crush add-bucket ssd root
```

2、添加host类型的bucket
```
# 创建一个新的桶叫node1-ssd ，级别是主机host
ceph osd crush add-bucket node1-ssd host

# 创建一个新的桶叫node2-ssd ，级别是主机host
ceph osd crush add-bucket node2-ssd host

# 创建一个新的桶叫node3-ssd ，级别是主机host
ceph osd crush add-bucket node3-ssd host
```

3、将host bucket加入到ssd bucket中
```
# 将node1-ssd归入ssd
ceph osd crush move node1-ssd root=ssd

# 将node2-ssd归入ssd
ceph osd crush move node2-ssd root=ssd

# 将node3-ssd归入ssd
ceph osd crush move node3-ssd root=ssd
```
- 如果设备被move移动，默认就没有了，可以使用`ceph osd crush link`

4、bucket填充数据，将osd 012移至root ssd
```
# 将osd.0 移动到主机host=node1-ssd root=ssd 中
ceph osd crush move osd.0 host=node1-ssd root=ssd

# 将osd.2 移动到主机host=node2-ssd root=ssd 中
ceph osd crush move osd.1 host=node2-ssd root=ssd

# 将osd.3 移动到主机host=node3-ssd root=ssd 中
ceph osd crush move osd.2 host=node3-ssd root=ssd
```

5、修改osd类型
```
ceph osd crush rm-device-class osd.0
ceph osd crush set-device-class ssd osd.0

ceph osd crush rm-device-class osd.1
ceph osd crush set-device-class ssd osd.1

ceph osd crush rm-device-class osd.2
ceph osd crush set-device-class ssd osd.2
```

6、查看osd tree
```
# ceph osd tree
ID  CLASS WEIGHT  TYPE NAME          STATUS REWEIGHT PRI-AFF 
 -9       0.14699 root ssd                                   
-10       0.04900     host node1-ssd                         
  0   ssd 0.04900         osd.0          up  1.00000 1.00000 
-11       0.04900     host node2-ssd                         
  1   ssd 0.04900         osd.1          up  1.00000 1.00000 
-12       0.04900     host node3-ssd                         
  2   ssd 0.04900         osd.2          up  1.00000 1.00000 
 -1       0.05699 root default                               
 -3       0.01900     host node1                             
  3   hdd 0.01900         osd.3          up  1.00000 1.00000 
 -5       0.01900     host node2                             
  4   hdd 0.01900         osd.4          up  1.00000 1.00000 
 -7       0.01900     host node3                             
  5   hdd 0.01900         osd.5          up  1.00000 1.00000
```

7、创建规则
```
# 创建crush rule，rule名称是ssd-demo，root=ssd，tpye=host，mode=ssd
ceph osd crush rule create-replicated ssd-demo ssd host ssd

# 查看crush规则
# ceph osd crush rule ls
replicated_rule
ssd-demo

# ceph osd crush rule dump
```

8、修改存储池crush rule
```
# 修改ceph-demo存储池规则为ssd-demo
# ceph osd pool set ceph-demo crush_rule ssd-demo

# 查看存储池ceph-demo规则
# ceph osd pool get ceph-demo crush_rule
crush_rule: ssd-demo

# rbd -p ceph-demo ls
crush-demo.img

# ceph osd map ceph-demo crush-demo.img
osdmap e519 pool 'ceph-demo' (10) object 'crush-demo.img' -> pg 10.d267742c (10.c) -> up ([0,1,2], p0) acting ([0,1,
```

# 六、自定义OSD上创建Ceph池

1、实验介绍

创建一个名为ssd-pool SSD磁盘支持的池，以及另一个名为sata-pool SATA的池，该池由SATA磁盘支持。为此，我们将编辑CRUSH地图并进行必要的配置。
- 假设 osd.0、osd.3、osd.6是 SSD 磁盘，osd.1、osd.5、osd.7是 SATA 磁盘

2、编译 crush map

（1）获取当前的 Crush map 并对其反编译
```
$ ceph osd getcrushmap -o crushmapdump
18
$ crushtool -d crushmapdump -o crushmapdump-decompiled
```

（2）编辑 crushmapdump-decompiled map 文件
```
$ vim crushmapdump-decompiled
# begin crush map
...
root ssd {
        id -9
        id -10
        alg straw2
        hash 0
        item osd.0 weight 0.010
        item osd.3 weight 0.010
        item osd.6 weight 0.010
}
root sata {
        id -11
        id -12
        alg straw2
        hash 0
        item osd.1 weight 0.010
        item osd.4 weight 0.010
        item osd.7 weight 0.010
}
...
rule ssd-pool {
        id 1
        type replicated
        min_size 1
        max_size 10
        step take ssd
        step chooseleaf firstn 0 type osd
        step emit
}
rule sata-pool {
        id 3
        type replicated
        min_size 1
        max_size 10
        step take sata
        step chooseleaf firstn 0 type osd
        step emit
}
# end crush map
```
- 上面分别创建了 ssd 和 sata 条目，然后创建了两条 rule,分别指向 两个条目。

（3）Ceph集群中编译并注入新的CRUSH映射
```
$ crushtool -c crushmapdump-decompiled -o crushmapdump-compiled

$ ceph osd setcrushmap -i crushmapdump-compiled

$ ceph osd tree                  # 查看应用后的 OSD 树状图
ID  CLASS WEIGHT  TYPE  NAME  STATUS  REWEIGHT  PRI-AFF
-12       0.02998 root  sata
  1   hdd 0.00999       osd.1    up    1.00000  1.00000
  4   hdd 0.00999       osd.4    up    1.00000  1.00000
  7   hdd 0.00999       osd.7    up    1.00000  1.00000
-10     0.02998   root ssd
  0   hdd 0.00999       osd.0    up    1.00000  1.00000
  3   hdd 0.00999       osd.3    up    1.00000  1.00000
  6   hdd 0.00999       osd.6    up    1.00000  1.00000
-1        0.35097 root default
-3        0.11699 host c720102
  0   hdd 0.03899       osd.0    up    1.00000  1.00000
  3   hdd 0.03899       osd.3    up    1.00000  1.00000
  6   hdd 0.03899       osd.6    up    1.00000  1.00000
...
```

3、创建池验证

（1）创建 ssd-pool
```
ceph osd pool create ssd-pool 8 8
ceph osd pool create sata-pool 8 8
```

(2)验证存储池，crush_rule默认是0
```
# ceph osd dump | grep -i ssd
pool 8 'ssd-pool' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_nus hashpspool stripe_width 0

# ceph osd dump|grep -i sata
pool 9 'sata-pool' replicated size 3 min_size 2 crush_rule 0 object_hash rjenkins pg_num 8 pgp_num 8 last_change 95 flags hashpspool stripe_width 0
```

（3）更改存储池规则
```
# 修改ssd存储池规则
# ceph osd pool set ssd-pool crush_rule ssd-pool
set pool 8 crush_rule to ssd-pool
# ceph osd dump | grep -i ssd
pool 8 'ssd-pool' replicated size 3 min_size 2 crush_rule 1 object_hash rjenkins pg_num 8 pgp_num 8 last_change 93 flags hashpspool stripe_width 0

# 修改stat存储池规则
# ceph osd pool set sata-pool crush_rule sata-pool
set pool 9 crush_rule to sata-pool
# ceph osd dump|grep -i sata
pool 9 'sata-pool' replicated size 3 min_size 2 crush_rule 3 object_hash rjenkins pg_num 8 pgp_num 8 last_change 99 flags hashpspool stripe_width 0
```

（4）添加一些对象，查看放置的对象存储在自定义的osd上
```
# rados -p ssd-pool ls                                   # 由于我们还没放置任何对象，应该为空
# rados -p sata-pool ls
# rados -p ssd-pool put dummy_object1 /etc/hosts         # 上传文件到存储池
# rados -p sata-pool put dummy_object1 /etc/hosts

# rados -p ssd-pool ls                                   # 查看存储池的对象
dummy_object1
# rados -p sata-pool ls
dummy_object1

# ceph osd map ssd-pool dummy_object1                    # 查看对象是否存储在我们定义的 OSD 上
osdmap e101 pool 'ssd-pool' (8) object 'dummy_object1' -> pg 8.71968e96 (8.6) -> up ([0,6,3], p0) acting ([0,6,3], p0)
# ceph osd map sata-pool dummy_object1
osdmap e101 pool 'sata-pool' (9) object 'dummy_object1' -> pg 9.71968e96 (9.6) -> up ([4,1,7], p4) acting ([4,1,7], p4)
```
- 创建的对象ssd-pool实际上存储在OSD集上 [0，6，3] ，并且创建的对象sata-pool存储在OSD集上 [4，1，7] 此输出是预期的，它验证我们创建的池使用我们请求的正确OSD集。这种类型的配置在生产设置中非常有用，您可以在其中创建仅基于SSD的快速池，以及基于机械磁盘的中/慢性池。

# 七、ceph Luminous新功能之crush class
	
### CRUSH devices class

- 这么做是为ceph不同类型的设备（HDD,SSD,NVMe）提供一个合理的默认，以便用户不必自己手动编辑指定。这相当于给磁盘组一个统一的class标签，根据class创建rule，然后根据role创建pool，整个操作不需要手动修改crushmap。


1、创建两个 class
```
# ceph osd crush class ls
[]
# ceph osd crush class create hdd
created class hdd with id 0 to crush map
# ceph osd crush class create ssd
created class ssd with id 1 to crush map
# ceph osd crush class ls
[
    "hdd",
    "ssd"
]
```


2、根据class，可以对osd进行以下两种操作

1）部署OSD时指定 class，比如，指定部署磁盘所在的 OSD 到指定 class 中
```
ceph-disk prepare --crush-device-class <class> /dev/XXX
```

2）将现有 osd 加入到指定 class 中，命令如下
```
ceph osd crush set-device-class osd.<id> <class>
```

### 以下对第二种操作进行实验，也是使用最多的

1、当前OSD 分布
```
# ceph osd tree
ID WEIGHT  TYPE NAME          UP/DOWN REWEIGHT PRIMARY-AFFINITY
-1 0.05814 root default
-2 0.01938     host luminous0
 1 0.00969         osd.1           up  1.00000          1.00000
 5 0.00969         osd.5           up  1.00000          1.00000
-3 0.01938     host luminous2
 0 0.00969         osd.0           up  1.00000          1.00000
 4 0.00969         osd.4           up  1.00000          1.00000
-4 0.01938     host luminous1
 2 0.00969         osd.2           up  1.00000          1.00000
 3 0.00969         osd.3           up  1.00000          1.00000
```
 

2、为class添加osd，将0、1、2分到hdd class，3、4、5分到ssd class
```
# for i in 0 1 2; do ceph osd crush set-device-class osd.$i hdd; done
set-device-class item id 3 name 'osd.0' device_class hdd
set-device-class item id 4 name 'osd.1' device_class hdd
set-device-class item id 5 name 'osd.2' device_class hdd

# for i in 3 4 5; do ceph osd crush set-device-class osd.$i ssd; done
set-device-class item id 3 name 'osd.3' device_class ssd
set-device-class item id 4 name 'osd.4' device_class ssd
set-device-class item id 5 name 'osd.5' device_class ssd
```

3、再查看osd分布
```
# ceph osd tree
ID  WEIGHT  TYPE NAME              UP/DOWN REWEIGHT PRIMARY-AFFINITY
-12 0.02907 root default~ssd
 -9 0.00969     host luminous0~ssd
  5 0.00969         osd.5               up  1.00000          1.00000
-10 0.00969     host luminous2~ssd
  4 0.00969         osd.4               up  1.00000          1.00000
-11 0.00969     host luminous1~ssd
  3 0.00969         osd.3               up  1.00000          1.00000
 -8 0.02907 root default~hdd
 -5 0.00969     host luminous0~hdd
  1 0.00969         osd.1               up  1.00000          1.00000
 -6 0.00969     host luminous2~hdd
  0 0.00969         osd.0               up  1.00000          1.00000
 -7 0.00969     host luminous1~hdd
  2 0.00969         osd.2               up  1.00000          1.00000
 -1 0.05814 root default
 -2 0.01938     host luminous0
  1 0.00969         osd.1               up  1.00000          1.00000
  5 0.00969         osd.5               up  1.00000          1.00000
 -3 0.01938     host luminous2
  0 0.00969         osd.0               up  1.00000          1.00000
  4 0.00969         osd.4               up  1.00000          1.00000
 -4 0.01938     host luminous1
  2 0.00969         osd.2               up  1.00000          1.00000
  3 0.00969         osd.3               up  1.00000          1.00000
```

4、创建rule
```
# ceph osd crush rule create-simple hdd-rule default~ssd host firstn
Invalid command:  invalid chars ~ in default~ssd
osd crush rule create-simple <name> <root> <type> {firstn|indep} :  create crush rule <name> to start from <root>, replicate across buckets of type <type>, using a choose mode of <firstn|indep> (default firstn; indep best for erasure pools)
Error EINVAL: invalid command
```

5、这里出现错误，我在想，是不是 class name 不用带上 default~ 这个符号，于是
```
# ceph osd crush rule create-simple hdd-rule ssd host firstn
Error ENOENT: root item ssd does not exist
```
- 依然出错，这是个bug，还在 merge 中,先跳过这个直接创建rule关联class的命令，后续BUG修复了再来实验

6、手动来创建rule

6.1、首先查看当前rule的状况
```
# ceph osd crush rule ls
[
    "replicated_rule"
]
```
- 只有一个默认的rule

6.2、第一步：获取crushmap *
```
# ceph osd getcrushmap -o c1
11
```

6.3、第二步：反编译crushmap
```
# crushtool -d c1 -o c2.txt
```

6.4、编辑crushmap
```
# vim c2.txt
# 在 # rule 那一栏 replicated_rule 的后面添加 hdd_rule 和 ssd_rule
# rules
rule replicated_rule {
        ruleset 0
        type replicated
        min_size 1
        max_size 10
        step take default
        step chooseleaf firstn 0 type host
        step emit
}

rule hdd_rule {
        ruleset 1
        type replicated
        min_size 1
        max_size 10
        step take default class hdd
        step chooseleaf firstn 0 type osd
        step emit
}

rule ssd_rule {
        ruleset 2
        type replicated
        min_size 1
        max_size 10
        step take default class ssd
        step chooseleaf firstn 0 type osd
        step emit
}
```

6.5、第三步：编译crushmap
```
# crushtool -c c2.txt -o c1.new
```

6.6、第四步：注入crushmap
```
# ceph osd setcrushmap -i c1.new
12
```

6.7、此时，查看rule
```
# ceph osd crush rule ls
[
    "replicated_rule",
    "hdd_rule",
    "ssd_rule"
]
```

### 有了新创建的两个rule，测试一下，rule 绑定 class是否成功

1、在 ssd_rule 上创建一个 pool
```
# ceph osd pool create testpool 64 64 ssd_rule
pool 'testpool' created
```

2、写一个对象
```
# rados -p testpool put object1 c2.txt
```

3、查看对象的osdmap
```
# ceph osd map testpool object1
osdmap e46 pool 'testpool' (7) object 'object1' -> pg 7.bac5debc (7.3c) -> up ([5,3,4], p5) acting ([5,3,4], p5)
```

# 八、ceph-创建一个使用该rule-ssd规则的存储池

1、实验环境
```
# cat /etc/redhat-release 
CentOS Linux release 7.3.1611 (Core) 

# ceph -v
    ceph version 12.2.1 (3e7492b9ada8bdc9a5cd0feafd42fbca27f9c38e) luminous (stable)
```

2、修改crush class

2.1、查看当前集群布局
```
# ceph osd tree
ID CLASS WEIGHT  TYPE NAME      STATUS REWEIGHT PRI-AFF 
-1       0.05878 root default                           
-3       0.01959     host node1                         
 0   hdd 0.00980         osd.0      up  1.00000 1.00000 
 3   hdd 0.00980         osd.3      up  1.00000 1.00000 
-5       0.01959     host node2                         
 1   hdd 0.00980         osd.1      up  1.00000 1.00000 
 4   hdd 0.00980         osd.4      up  1.00000 1.00000 
-7       0.01959     host node3                         
 2   hdd 0.00980         osd.2      up  1.00000 1.00000 
 5   hdd 0.00980         osd.5      up  1.00000 1.00000 
```
- 可以看到只有第二列CLASS，只有hdd类型。

通过查看crush class，确实只有hdd类型
```
# ceph osd crush class ls
[
    "hdd"
]
```

2.2、删除osd.0，osd.1，osd.2的class：
```
# for i in 0 1 2;do ceph osd crush rm-device-class osd.$i;done
done removing class of osd(s): 0
done removing class of osd(s): 1
done removing class of osd(s): 2
```

再次通过命令ceph osd tree查看osd.0，osd.1，osd.2的class
```
# ceph osd tree
ID CLASS WEIGHT  TYPE NAME      STATUS REWEIGHT PRI-AFF 
-1       0.05878 root default                           
-3       0.01959     host node1                         
 0       0.00980         osd.0      up  1.00000 1.00000 
 3   hdd 0.00980         osd.3      up  1.00000 1.00000 
-5       0.01959     host node2                         
 1       0.00980         osd.1      up  1.00000 1.00000 
 4   hdd 0.00980         osd.4      up  1.00000 1.00000 
-7       0.01959     host node3                         
 2       0.00980         osd.2      up  1.00000 1.00000 
 5   hdd 0.00980         osd.5      up  1.00000 1.00000 
```
- 可以发现osd.0，osd.1，osd.2的class为空

2.3、设置osd.0，osd.1，osd.2的class为ssd：
```
# for i in 0 1 2;do ceph osd crush set-device-class ssd osd.$i;done
set osd(s) 0 to class 'ssd'
set osd(s) 1 to class 'ssd'
set osd(s) 2 to class 'ssd'
```

再次通过命令ceph osd tree查看osd.0，osd.1，osd.2的class
```
# ceph osd tree
ID CLASS WEIGHT  TYPE NAME      STATUS REWEIGHT PRI-AFF 
-1       0.05878 root default                           
-3       0.01959     host node1                         
 3   hdd 0.00980         osd.3      up  1.00000 1.00000 
 0   ssd 0.00980         osd.0      up  1.00000 1.00000 
-5       0.01959     host node2                         
 4   hdd 0.00980         osd.4      up  1.00000 1.00000 
 1   ssd 0.00980         osd.1      up  1.00000 1.00000 
-7       0.01959     host node3                         
 5   hdd 0.00980         osd.5      up  1.00000 1.00000 
 2   ssd 0.00980         osd.2      up  1.00000 1.00000 
```
- 可以看到osd.0，osd.1，osd.2的class变为ssd

再查看一下crush class：
```
# ceph osd crush class ls
[
    "hdd",
    "ssd"
]
```
- 可以看到class中多出了一个名为ssd的class

2.4、创建一个优先使用ssd设备的crush rule

创建了一个rule的名字为：rule-ssd，在root名为default下的rule
```
# ceph osd crush rule create-replicated rule-ssd default  host ssd 
```

查看集群的rule
```
# ceph osd crush rule ls
replicated_rule
rule-ssd
```
- 可以看到多出了一个名为rule-ssd的rule

通过下面的命令下载集群crushmap查看有哪些变化：
```
# ceph osd getcrushmap -o crushmap
20

# crushtool -d crushmap -o crushmap

# cat crushmap
# begin crush map
tunable choose_local_tries 0
tunable choose_local_fallback_tries 0
tunable choose_total_tries 50
tunable chooseleaf_descend_once 1
tunable chooseleaf_vary_r 1
tunable chooseleaf_stable 1
tunable straw_calc_version 1
tunable allowed_bucket_algs 54
 
# devices
device 0 osd.0 class ssd
device 1 osd.1 class ssd
device 2 osd.2 class ssd
device 3 osd.3 class hdd
device 4 osd.4 class hdd
device 5 osd.5 class hdd
 
# types
type 0 osd
type 1 host
type 2 chassis
type 3 rack
type 4 row
type 5 pdu
type 6 pod
type 7 room
type 8 datacenter
type 9 region
type 10 root
     
# buckets
host node1 {
        id -3           # do not change unnecessarily
        id -4 class hdd         # do not change unnecessarily
        id -9 class ssd         # do not change unnecessarily
        # weight 0.020
        alg straw2
        hash 0  # rjenkins1
        item osd.0 weight 0.010
        item osd.3 weight 0.010
}
host node2 {
        id -5           # do not change unnecessarily
        id -6 class hdd         # do not change unnecessarily
        id -10 class ssd                # do not change unnecessarily
        # weight 0.020
        alg straw2
        hash 0  # rjenkins1
        item osd.1 weight 0.010
        item osd.4 weight 0.010
}
host node3 {
        id -7           # do not change unnecessarily
        id -8 class hdd         # do not change unnecessarily
        id -11 class ssd                # do not change unnecessarily
        # weight 0.020
        alg straw2
        hash 0  # rjenkins1
        item osd.2 weight 0.010
        item osd.5 weight 0.010
}
root default {
        id -1           # do not change unnecessarily
        id -2 class hdd         # do not change unnecessarily
        id -12 class ssd                # do not change unnecessarily
        # weight 0.059
        alg straw2
        hash 0  # rjenkins1
        item node1 weight 0.020
        item node2 weight 0.020
        item node3 weight 0.020
}
 
# rules
rule replicated_rule {
        id 0
        type replicated
        min_size 1
        max_size 10
        step take default
        step chooseleaf firstn 0 type host
        step emit
}
rule rule-ssd {
        id 1
        type replicated
        min_size 1
        max_size 10
        step take default class ssd
        step chooseleaf firstn 0 type host
        step emit
}
 
# end crush map
```
- 可以看到在root default下多了一行： id -12 class ssd。在rules下，多了一个rule rule-ssd其id为1

5，创建一个使用该rule-ssd规则的存储池：
```
# ceph osd pool create ssdpool 64 64 rule-ssd
pool 'ssdpool' created
```

查看ssdpool的信息可以看到使用的crush_rule 为1，也就是rule-ssd
```
# ceph osd pool ls detail
pool 1 'ssdpool' replicated size 3 min_size 2 crush_rule 1 object_hash rjenkins pg_num 64 pgp_num 64 last_change 39 flags hashpspool stripe_width 0
```

6，创建对象测试ssdpool

创建一个对象test并放到ssdpool中
```
# rados -p ssdpool ls
# echo "hahah" >test.txt
# rados -p ssdpool put test test.txt 
# rados -p ssdpool ls
test
```

查看该对象的osd组
```
# ceph osd map ssdpool test
osdmap e46 pool 'ssdpool' (1) object 'test' -> pg 1.40e8aab5 (1.35) -> up ([1,2,0], p1) acting ([1,2,0], p1)
```
可以看到该对象的osd组使用的都是ssd磁盘，至此验证成功。可以看出crush class相当于一个辨别磁盘类型的标签。



# 八、完整版crush map示例
```
# begin crush map
tunable choose_local_tries 0
tunable choose_local_fallback_tries 0
tunable choose_total_tries 50
tunable chooseleaf_descend_once 1
tunable chooseleaf_vary_r 1
tunable chooseleaf_stable 1
tunable straw_calc_version 1
tunable allowed_bucket_algs 54

# devices
device 0 osd.0 class hdd
device 1 osd.1 class hdd
device 2 osd.2 class hdd
device 3 osd.3 class hdd
device 4 osd.4 class hdd
device 5 osd.5 class hdd
device 6 osd.6 class hdd
device 7 osd.7 class hdd
device 8 osd.8 class hdd
device 9 osd.9 class hdd
device 10 osd.10 class hdd
device 11 osd.11 class hdd
device 12 osd.12 class hdd
device 13 osd.13 class hdd
device 14 osd.14 class hdd
device 15 osd.15 class hdd
device 16 osd.16 class hdd
device 17 osd.17 class hdd
device 18 osd.18 class hdd
device 19 osd.19 class hdd
device 20 osd.20 class hdd
device 21 osd.21 class hdd
device 22 osd.22 class hdd
device 23 osd.23 class hdd
device 24 osd.24 class hdd
device 25 osd.25 class hdd
device 26 osd.26 class hdd
device 27 osd.27 class hdd
device 28 osd.28 class hdd
device 29 osd.29 class hdd
device 30 osd.30 class hdd
device 31 osd.31 class hdd
device 32 osd.32 class hdd
device 33 osd.33 class hdd
device 34 osd.34 class hdd
device 35 osd.35 class hdd
device 36 osd.36 class hdd
device 37 osd.37 class hdd
device 38 osd.38 class hdd
device 39 osd.39 class ssd
device 40 osd.40 class ssd
device 41 osd.41 class ssd
device 42 osd.42 class hdd
device 43 osd.43 class ssd

# types
type 0 osd
type 1 host
type 2 chassis
type 3 rack
type 4 row
type 5 pdu
type 6 pod
type 7 room
type 8 datacenter
type 9 region
type 10 root

# buckets
root default {
	id -1		# do not change unnecessarily
	id -2 class hdd		# do not change unnecessarily
	id -33 class ssd		# do not change unnecessarily
	# weight 0.000
	alg straw2
	hash 0	# rjenkins1
}
host default-172.16.0.1 {
	id -3		# do not change unnecessarily
	id -7 class hdd		# do not change unnecessarily
	id -23 class ssd		# do not change unnecessarily
	# weight 108.934
	alg straw2
	hash 0	# rjenkins1
	item osd.1 weight 10.791
	item osd.5 weight 10.557
	item osd.9 weight 11.060
	item osd.12 weight 11.555
	item osd.18 weight 10.896
	item osd.20 weight 10.007
	item osd.24 weight 11.640
	item osd.27 weight 11.567
	item osd.32 weight 10.656
	item osd.35 weight 10.205
}
rack default-rack.1D02 {
	id -4		# do not change unnecessarily
	id -8 class hdd		# do not change unnecessarily
	id -24 class ssd		# do not change unnecessarily
	# weight 108.934
	alg straw2
	hash 0	# rjenkins1
	item default-172.16.0.1 weight 108.934
}
host default-172.16.1.1 {
	id -11		# do not change unnecessarily
	id -13 class hdd		# do not change unnecessarily
	id -25 class ssd		# do not change unnecessarily
	# weight 110.164
	alg straw2
	hash 0	# rjenkins1
	item osd.2 weight 11.789
	item osd.6 weight 10.689
	item osd.10 weight 11.358
	item osd.14 weight 10.362
	item osd.16 weight 11.246
	item osd.21 weight 11.537
	item osd.25 weight 10.265
	item osd.28 weight 11.524
	item osd.31 weight 10.986
	item osd.36 weight 10.409
}
rack default-rack.1D01 {
	id -12		# do not change unnecessarily
	id -14 class hdd		# do not change unnecessarily
	id -26 class ssd		# do not change unnecessarily
	# weight 110.164
	alg straw2
	hash 0	# rjenkins1
	item default-172.16.1.1 weight 110.164
}
host default-172.16.0.2 {
	id -15		# do not change unnecessarily
	id -17 class hdd		# do not change unnecessarily
	id -27 class ssd		# do not change unnecessarily
	# weight 108.928
	alg straw2
	hash 0	# rjenkins1
	item osd.0 weight 11.114
	item osd.4 weight 11.132
	item osd.8 weight 10.343
	item osd.13 weight 10.740
	item osd.17 weight 10.932
	item osd.22 weight 10.914
	item osd.26 weight 10.950
	item osd.29 weight 10.896
	item osd.33 weight 11.115
	item osd.37 weight 10.791
}
rack default-rack.1D03 {
	id -16		# do not change unnecessarily
	id -18 class hdd		# do not change unnecessarily
	id -28 class ssd		# do not change unnecessarily
	# weight 108.928
	alg straw2
	hash 0	# rjenkins1
	item default-172.16.0.2 weight 108.928
}
host default-172.16.0.3 {
	id -19		# do not change unnecessarily
	id -21 class hdd		# do not change unnecessarily
	id -29 class ssd		# do not change unnecessarily
	# weight 108.592
	alg straw2
	hash 0	# rjenkins1
	item osd.3 weight 10.377
	item osd.7 weight 10.38
	item osd.11 weight 10.220
	item osd.15 weight 10.688
	item osd.19 weight 11.269
	item osd.23 weight 11.269
	item osd.30 weight 10.597
	item osd.34 weight 11.023
	item osd.38 weight 11.555
	item osd.42 weight 11.403
}
rack default-rack.1D04 {
	id -20		# do not change unnecessarily
	id -22 class hdd		# do not change unnecessarily
	id -30 class ssd		# do not change unnecessarily
	# weight 108.592
	alg straw2
	hash 0	# rjenkins1
	item default-172.16.0.3 weight 108.592
}
datacenter default-datacenter.lhlt8f {
	id -5		# do not change unnecessarily
	id -9 class hdd		# do not change unnecessarily
	id -31 class ssd		# do not change unnecessarily
	# weight 436.618
	alg straw2
	hash 0	# rjenkins1
	item default-rack.1D02 weight 108.934
	item default-rack.1D01 weight 110.164
	item default-rack.1D03 weight 108.928
	item default-rack.1D04 weight 108.592
}
root default {
	id -6		# do not change unnecessarily
	id -10 class hdd		# do not change unnecessarily
	id -32 class ssd		# do not change unnecessarily
	# weight 436.618
	alg straw2
	hash 0	# rjenkins1
	item default-datacenter.lhlt8f weight 436.618
}
host fast-172.16.1.1 {
	id -34		# do not change unnecessarily
	id -38 class hdd		# do not change unnecessarily
	id -42 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item osd.40 weight 5.822
}
rack fast-rack.1D01 {
	id -35		# do not change unnecessarily
	id -39 class hdd		# do not change unnecessarily
	id -43 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item fast-172.16.1.1 weight 5.822
}
host fast-172.16.0.1 {
	id -46		# do not change unnecessarily
	id -48 class hdd		# do not change unnecessarily
	id -50 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item osd.39 weight 5.822
}
rack fast-rack.1D02 {
	id -47		# do not change unnecessarily
	id -49 class hdd		# do not change unnecessarily
	id -51 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item fast-172.16.0.1 weight 5.822
}
host fast-172.16.0.2 {
	id -52		# do not change unnecessarily
	id -54 class hdd		# do not change unnecessarily
	id -56 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item osd.41 weight 5.822
}
rack fast-rack.1D03 {
	id -53		# do not change unnecessarily
	id -55 class hdd		# do not change unnecessarily
	id -57 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item fast-172.16.0.2 weight 5.822
}
host fast-172.16.0.3 {
	id -58		# do not change unnecessarily
	id -60 class hdd		# do not change unnecessarily
	id -62 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item osd.43 weight 5.822
}
rack fast-rack.1D04 {
	id -59		# do not change unnecessarily
	id -61 class hdd		# do not change unnecessarily
	id -63 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item fast-172.16.0.3 weight 5.822
}
datacenter fast-datacenter.lhlt8f {
	id -36		# do not change unnecessarily
	id -40 class hdd		# do not change unnecessarily
	id -44 class ssd		# do not change unnecessarily
	# weight 23.288
	alg straw2
	hash 0	# rjenkins1
	item fast-rack.1D01 weight 5.822
	item fast-rack.1D02 weight 5.822
	item fast-rack.1D03 weight 5.822
	item fast-rack.1D04 weight 5.822
}
root fast {
	id -37		# do not change unnecessarily
	id -41 class hdd		# do not change unnecessarily
	id -45 class ssd		# do not change unnecessarily
	# weight 23.288
	alg straw2
	hash 0	# rjenkins1
	item fast-datacenter.lhlt8f weight 23.288
}

# rules
rule replicated_rule {
	id 0
	type replicated
	min_size 1
	max_size 10
	step take default
	step chooseleaf firstn 0 type host
	step emit
}
rule rep-default_datacenter {
	id 1
	type replicated
	min_size 1
	max_size 10
	step take default
	step chooseleaf firstn 0 type datacenter
	step emit
}
rule ec_8_3-default_datacenter {
	id 2
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take default
	step chooseleaf indep 0 type datacenter
	step emit
}
rule rep-default_room {
	id 3
	type replicated
	min_size 1
	max_size 10
	step take default
	step chooseleaf firstn 0 type room
	step emit
}
rule ec_8_3-default_room {
	id 4
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take default
	step chooseleaf indep 0 type room
	step emit
}
rule rep-default_rack {
	id 5
	type replicated
	min_size 1
	max_size 10
	step take default
	step chooseleaf firstn 0 type rack
	step emit
}
rule ec_8_3-default_rack {
	id 6
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take default
	step chooseleaf indep 0 type rack
	step emit
}
rule rep-default_host {
	id 7
	type replicated
	min_size 1
	max_size 10
	step take default
	step chooseleaf firstn 0 type host
	step emit
}
rule ec_8_3-default_host {
	id 8
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take default
	step chooseleaf indep 0 type host
	step emit
}
rule rep-fast_datacenter {
	id 9
	type replicated
	min_size 1
	max_size 10
	step take fast
	step chooseleaf firstn 0 type datacenter
	step emit
}
rule ec_8_3-fast_datacenter {
	id 10
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take fast
	step chooseleaf indep 0 type datacenter
	step emit
}
rule rep-fast_room {
	id 11
	type replicated
	min_size 1
	max_size 10
	step take fast
	step chooseleaf firstn 0 type room
	step emit
}
rule ec_8_3-fast_room {
	id 12
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take fast
	step chooseleaf indep 0 type room
	step emit
}
rule rep-fast_rack {
	id 13
	type replicated
	min_size 1
	max_size 10
	step take fast
	step chooseleaf firstn 0 type rack
	step emit
}
rule ec_8_3-fast_rack {
	id 14
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take fast
	step chooseleaf indep 0 type rack
	step emit
}
rule rep-fast_host {
	id 15
	type replicated
	min_size 1
	max_size 10
	step take fast
	step chooseleaf firstn 0 type host
	step emit
}
rule ec_8_3-fast_host {
	id 16
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take fast
	step chooseleaf indep 0 type host
	step emit
}

# end crush map
```
