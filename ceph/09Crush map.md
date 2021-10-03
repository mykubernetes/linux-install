Crush map 编辑
===
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

# begin crush map 选择存放副本位置时的选择算法策略中的变量配置
tunable choose_local_tries 0
tunable choose_local_fallback_tries 0
tunable choose_total_tries 50
tunable chooseleaf_descend_once 1
tunable straw_calc_version 1

# devices              # 一般指的是叶子节点osd
device 0 osd.0
device 1 osd.1
device 2 osd.2

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

# buckets                 # 躯干部分 host一般是表示一个物理节点，root是树形的根部
host thinstack-test0 {
id -2 
# weight 0.031
alg straw                 # ceph作者实现的选择item的算法
hash 0                    # rjenkins1 这代表的是使用哪个hash算法，0表示选择rjenkins1这种hash算法
item osd.0 weight 0.031
}
host thinstack-test1 {    # 类型host，名字为thinstack-test1
id -3                     # bucket的id，一般为负值
# weight 0.031            # 权重，默认为子item的权重之和
alg straw                 # bucket随机选择的算法
hash 0                    # bucket随机选择的算法使用的hash函数，这里0代表使用hash函数rjenkins1
item osd.1 weight 0.031
}
host thinstack-test2 {
id -4
# weight 0.031
alg straw
hash 0
item osd.2 weight 0.031
}
root default {            # root类型的bucket，名字为default
id -1                     # id号
# weight 0.094
alg straw                 # 随机选择的算法
hash 0                    # rjenkins1
item thinstack-test0 weight 0.031
item thinstack-test1 weight 0.031
item thinstack-test2 weight 0.031
}

# rules                                # 副本选取规则的设定
rule replicated_ruleset {
ruleset 0                              # ruleset的编号id
type replicated                        # 类型:repliated或者erasure code
min_size 1                             # 副本数最小值
max_size 10                            # 副本数最大值
step take default                      # 选择一个root bucket，做下一步的输入
step choose firstn  1 type row         # 选择一个row，同一排
step choose firstn  3 type cabinet     # 选择三个cabinet, 三副本分别在不同的cabinet
step choose firstn  1 type osd         # 在上一步输出的三个cabinet中，分别选择一个osd
step emit                              # 提交
}

# end crush map


step chooseleaf firstn {num} type {bucket-type}
chooseleaf表示选择bucket-type的bucket并选择其的叶子节点（osd）
当num等于0时：表示选择副本数量个bucket
当num > 0 and num < 副本数量时：表示选择num个bucket
当num < 0： 表示选择 副本数量 - num 个bucket
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

7、 tunable (可调参数)  
```
# cat crushmap_compiled_file 
# begin crush map
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
1、方法一：切换为最优版  
```
# ceph osd crush tunables optimal
```  

2、方法二：不让它警告  
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
- default：从头开始安装的新群集的默认值。这些值取决于当前版本的Ceph，是硬编码的，通常是最佳值和传统值的混合。这些值通常与optimal之前LTS版本的配置文件相匹配，或者通常与我们通常除了更多用户拥有最新客户端的最新版本匹配。

设置  
```
# ceph osd crush tunables {PROFILE}
# ceph osd crush show-tunables #查看目前使用的参数
```  
