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
```  

4、完成编辑后，编译这些更改  
```
# crushtool -c crushmap_decompiled_file -o newcrushmap
```  

5、将新编译后的 Crush map 注入 Ceph 集群  
```
# ceph osd setcrushmap -i newcrushmap
```

6、 tunable (可调参数)  
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
