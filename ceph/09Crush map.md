http://docs.ceph.org.cn/rados/operations/crush-map/

1、查看每个pool的详细信息，可以查看每个pool使用的crush_rule规则
```
# ceph osd pool ls detail
pool 1 '.rgw.root' replicated size 3 min_size 2 crush_rule 15 object_hash rjenkins pg_num 8 pgp_num 8 last_change 977 flags hashpspool stripe_width 0 application rgw
pool 2 '00000000-default.rgw.buckets.index' replicated size 3 min_size 2 crush_rule 15 object_hash rjenkins pg_num 256 pgp_num 256 last_change 885 flags hashpspool stripe_width 0 application rgw
pool 3 'default.rgw.meta' replicated size 3 min_size 2 crush_rule 15 object_hash rjenkins pg_num 4 pgp_num 4 last_change 886 flags hashpspool stripe_width 0 application rgw
pool 4 'default.rgw.control' replicated size 3 min_size 2 crush_rule 15 object_hash rjenkins pg_num 4 pgp_num 4 last_change 887 flags hashpspool stripe_width 0 application rgw
pool 5 '00000000-default.rgw.buckets.non-ec' replicated size 3 min_size 2 crush_rule 15 object_hash rjenkins pg_num 16 pgp_num 16 last_change 888 flags hashpspool stripe_width 0 application rgw
pool 6 'default.rgw.log' replicated size 3 min_size 2 crush_rule 15 object_hash rjenkins pg_num 4 pgp_num 4 last_change 890 flags hashpspool stripe_width 0 application rgw
pool 7 '00000000-default.rgw.buckets.data' replicated size 3 min_size 2 crush_rule 7 object_hash rjenkins pg_num 4096 pgp_num 4096 last_change 1241 flags hashpspool stripe_width 0 expected_num_objects 819200000 application rgw
```

2、查看存储池有哪些规则
```
# ceph -c $(ls /data/cos/ceph.*.conf | head -1) osd crush rule ls
replicated_rule
rep_00000000-default_datacenter
ec_8_3_00000000-default_datacenter
rep_00000000-default_room
ec_8_3_00000000-default_room
rep_00000000-default_rack
ec_8_3_00000000-default_rack
rep_00000000-default_host
ec_8_3_00000000-default_host
crep_00000000-fast_datacenter
ec_8_3_00000000-fast_datacenter
rep_00000000-fast_room
cec_8_3_00000000-fast_room
rep_00000000-fast_rack
ec_8_3_00000000-fast_rack
rep_00000000-fast_host
ec_8_3_00000000-fast_host
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
# ceph osd pool set .rgw.root crush_rule rep_0000000-fast_host
```


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
host 00000000-default-172.16.0.1 {
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
rack 00000000-default-rack.1D02 {
	id -4		# do not change unnecessarily
	id -8 class hdd		# do not change unnecessarily
	id -24 class ssd		# do not change unnecessarily
	# weight 108.934
	alg straw2
	hash 0	# rjenkins1
	item 00000000-default-172.16.0.1 weight 108.934
}
host 00000000-default-172.16.1.1 {
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
rack 00000000-default-rack.1D01 {
	id -12		# do not change unnecessarily
	id -14 class hdd		# do not change unnecessarily
	id -26 class ssd		# do not change unnecessarily
	# weight 110.164
	alg straw2
	hash 0	# rjenkins1
	item 00000000-default-172.16.1.1 weight 110.164
}
host 00000000-default-172.16.0.2 {
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
rack 00000000-default-rack.1D03 {
	id -16		# do not change unnecessarily
	id -18 class hdd		# do not change unnecessarily
	id -28 class ssd		# do not change unnecessarily
	# weight 108.928
	alg straw2
	hash 0	# rjenkins1
	item 00000000-default-172.16.0.2 weight 108.928
}
host 00000000-default-172.16.0.3 {
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
rack 00000000-default-rack.1D04 {
	id -20		# do not change unnecessarily
	id -22 class hdd		# do not change unnecessarily
	id -30 class ssd		# do not change unnecessarily
	# weight 108.592
	alg straw2
	hash 0	# rjenkins1
	item 00000000-default-172.16.0.3 weight 108.592
}
datacenter 00000000-default-datacenter.lhlt8f {
	id -5		# do not change unnecessarily
	id -9 class hdd		# do not change unnecessarily
	id -31 class ssd		# do not change unnecessarily
	# weight 436.618
	alg straw2
	hash 0	# rjenkins1
	item 00000000-default-rack.1D02 weight 108.934
	item 00000000-default-rack.1D01 weight 110.164
	item 00000000-default-rack.1D03 weight 108.928
	item 00000000-default-rack.1D04 weight 108.592
}
root 00000000-default {
	id -6		# do not change unnecessarily
	id -10 class hdd		# do not change unnecessarily
	id -32 class ssd		# do not change unnecessarily
	# weight 436.618
	alg straw2
	hash 0	# rjenkins1
	item 00000000-default-datacenter.lhlt8f weight 436.618
}
host 00000000-fast-172.16.1.1 {
	id -34		# do not change unnecessarily
	id -38 class hdd		# do not change unnecessarily
	id -42 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item osd.40 weight 5.822
}
rack 00000000-fast-rack.1D01 {
	id -35		# do not change unnecessarily
	id -39 class hdd		# do not change unnecessarily
	id -43 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item 00000000-fast-172.16.1.1 weight 5.822
}
host 00000000-fast-172.16.0.1 {
	id -46		# do not change unnecessarily
	id -48 class hdd		# do not change unnecessarily
	id -50 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item osd.39 weight 5.822
}
rack 00000000-fast-rack.1D02 {
	id -47		# do not change unnecessarily
	id -49 class hdd		# do not change unnecessarily
	id -51 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item 00000000-fast-172.16.0.1 weight 5.822
}
host 00000000-fast-172.16.0.2 {
	id -52		# do not change unnecessarily
	id -54 class hdd		# do not change unnecessarily
	id -56 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item osd.41 weight 5.822
}
rack 00000000-fast-rack.1D03 {
	id -53		# do not change unnecessarily
	id -55 class hdd		# do not change unnecessarily
	id -57 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item 00000000-fast-172.16.0.2 weight 5.822
}
host 00000000-fast-172.16.0.3 {
	id -58		# do not change unnecessarily
	id -60 class hdd		# do not change unnecessarily
	id -62 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item osd.43 weight 5.822
}
rack 00000000-fast-rack.1D04 {
	id -59		# do not change unnecessarily
	id -61 class hdd		# do not change unnecessarily
	id -63 class ssd		# do not change unnecessarily
	# weight 5.822
	alg straw2
	hash 0	# rjenkins1
	item 00000000-fast-172.16.0.3 weight 5.822
}
datacenter 00000000-fast-datacenter.lhlt8f {
	id -36		# do not change unnecessarily
	id -40 class hdd		# do not change unnecessarily
	id -44 class ssd		# do not change unnecessarily
	# weight 23.288
	alg straw2
	hash 0	# rjenkins1
	item 00000000-fast-rack.1D01 weight 5.822
	item 00000000-fast-rack.1D02 weight 5.822
	item 00000000-fast-rack.1D03 weight 5.822
	item 00000000-fast-rack.1D04 weight 5.822
}
root 00000000-fast {
	id -37		# do not change unnecessarily
	id -41 class hdd		# do not change unnecessarily
	id -45 class ssd		# do not change unnecessarily
	# weight 23.288
	alg straw2
	hash 0	# rjenkins1
	item 00000000-fast-datacenter.lhlt8f weight 23.288
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
rule cos_rep_00000000-default_datacenter {
	id 1
	type replicated
	min_size 1
	max_size 10
	step take 00000000-default
	step chooseleaf firstn 0 type datacenter
	step emit
}
rule cos_ec_8_3_00000000-default_datacenter {
	id 2
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take 00000000-default
	step chooseleaf indep 0 type datacenter
	step emit
}
rule cos_rep_00000000-default_room {
	id 3
	type replicated
	min_size 1
	max_size 10
	step take 00000000-default
	step chooseleaf firstn 0 type room
	step emit
}
rule cos_ec_8_3_00000000-default_room {
	id 4
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take 00000000-default
	step chooseleaf indep 0 type room
	step emit
}
rule cos_rep_00000000-default_rack {
	id 5
	type replicated
	min_size 1
	max_size 10
	step take 00000000-default
	step chooseleaf firstn 0 type rack
	step emit
}
rule cos_ec_8_3_00000000-default_rack {
	id 6
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take 00000000-default
	step chooseleaf indep 0 type rack
	step emit
}
rule cos_rep_00000000-default_host {
	id 7
	type replicated
	min_size 1
	max_size 10
	step take 00000000-default
	step chooseleaf firstn 0 type host
	step emit
}
rule cos_ec_8_3_00000000-default_host {
	id 8
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take 00000000-default
	step chooseleaf indep 0 type host
	step emit
}
rule cos_rep_00000000-fast_datacenter {
	id 9
	type replicated
	min_size 1
	max_size 10
	step take 00000000-fast
	step chooseleaf firstn 0 type datacenter
	step emit
}
rule cos_ec_8_3_00000000-fast_datacenter {
	id 10
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take 00000000-fast
	step chooseleaf indep 0 type datacenter
	step emit
}
rule cos_rep_00000000-fast_room {
	id 11
	type replicated
	min_size 1
	max_size 10
	step take 00000000-fast
	step chooseleaf firstn 0 type room
	step emit
}
rule cos_ec_8_3_00000000-fast_room {
	id 12
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take 00000000-fast
	step chooseleaf indep 0 type room
	step emit
}
rule cos_rep_00000000-fast_rack {
	id 13
	type replicated
	min_size 1
	max_size 10
	step take 00000000-fast
	step chooseleaf firstn 0 type rack
	step emit
}
rule cos_ec_8_3_00000000-fast_rack {
	id 14
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take 00000000-fast
	step chooseleaf indep 0 type rack
	step emit
}
rule cos_rep_00000000-fast_host {
	id 15
	type replicated
	min_size 1
	max_size 10
	step take 00000000-fast
	step chooseleaf firstn 0 type host
	step emit
}
rule cos_ec_8_3_00000000-fast_host {
	id 16
	type erasure
	min_size 3
	max_size 11
	step set_chooseleaf_tries 5
	step set_choose_tries 100
	step take 00000000-fast
	step chooseleaf indep 0 type host
	step emit
}

# end crush map
```
