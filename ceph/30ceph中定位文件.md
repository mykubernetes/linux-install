我们知道,将一个文件存到ceph里之后，ceph会将该文件条带化为若干个小的object，然后使用cursh算法，将每一个object复制若干份（根据pool size 来定）分别存储到不同的osd上。 本文会介绍，如何通过命令找到一个文件真正被存在哪里了。

# 1. 查找文件存放的物理位置

## 1) 列出当前系统下所有bucket信息
```
# radosgw-admin bucket list
[
    "small_rd_test_bucket",    
    "mynewtest",
    "mytest-2",
    "xuwenping-bucket-zj-4",
    "big_rd_test_bucket",
    "mytest",
    "my-scs-test",
    "write_test_bucket",
	"tsp_test_bucket",
]

# ceph osd pool ls
.rgw.root
default.rgw.control
default.rgw.data.root
default.rgw.gc
default.rgw.log
default.rgw.users.uid
default.rgw.users.keys
default.rgw.buckets.index
default.rgw.usage
default.rgw.buckets.data
default.rgw.buckets.non-ec
default.rgw.users.swift
benchmark
default.rgw.users.email
rbd-01
```
上述命令展示了当前ceph对象存储系统中涉及到的所有的bucket

## 2) 查看具体某个bucket的属性
```
# radosgw-admin bucket stats --bucket=tsp_test_bucket
{
    "bucket": "tsp_test_bucket",
    "pool": "oss-uat.rgw.buckets.data",
    "index_pool": "oss-uat.rgw.buckets.index",
    "id": "135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269",
    "marker": "135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269",
    "owner": "F6678E6FD4054150BA37521FBA8A67A6",
    "ver": "0#8449,1#5497,2#11205,3#6593,4#9879,5#7535,6#7839,7#8943,8#7079,9#6319,10#8283,11#7399,12#9805,13#13585,14#12475,15#7621",
    "master_ver": "0#0,1#0,2#0,3#0,4#0,5#0,6#0,7#0,8#0,9#0,10#0,11#0,12#0,13#0,14#0,15#0",
    "mtime": "2018-05-16 17:26:31.248464",
    "max_marker": "0#,1#,2#,3#,4#,5#,6#,7#,8#,9#,10#,11#,12#,13#,14#,15#",
    "usage": {
        "rgw.main": {
            "size_kb": 21028776,
            "size_kb_actual": 21029252,
            "num_objects": 26767
        },
        "rgw.multimeta": {
            "size_kb": 0,
            "size_kb_actual": 0,
            "num_objects": 518
        }
    },
    "bucket_quota": {
        "enabled": false,
        "max_size_kb": -1,
        "max_objects": -1
    }
}
```
上面的命令展示了bucket的名称, 所在的data pool，index pool以及对应的bucket ID。

## 3) 检查对应bucket在index中是否存在
```
# rados -p oss-uat.rgw.buckets.index ls - | grep "135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269"
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.2
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.5
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.10
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.6
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.3
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.7
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.0
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.14
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.1
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.15
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.12
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.11
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.8
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.13
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.9
.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.4
```
上面我们注意到，查询出来的结果需要在bucket ID前面加上.dir才是它在INDEX POOL中的索引。

## 4） 查看对应INDEX中记录的key
```
# rados -p oss-uat.rgw.buckets.index listomapkeys .dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.2
/home/.TempWrite.py.swp
/home/1024
/home/TempWrite.py
/home/crossdomain.xml
/home/download_url.txt
/home/region.conf.json
/home/region.conf.json.bk
/home/result
/home/s3Test.cpp
/home/s3testInMemory
/home/struct_def.h
/home/user.md.json
/home/user1.md.json
/home/user2.md.json
/home/user3.md.json
/home/user4.md.json
/home/zone.conf.json
```

可以通过如下方式统计文件数量：
```
# rados -p oss-uat.rgw.buckets.index listomapkeys .dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.2 | wc -l
988847
```

## 5) 查看文件索引存放的物理位置
```
# ceph osd map oss-uat.rgw.buckets.index .dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.2
osdmap e17117 pool 'oss-uat.rgw.buckets.index' (188) object '.dir.135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269.2' -> pg 188.c3437413 (188.13) -> up ([91,21,103], p91) acting ([91,21,103], p91) 
988847
```
通过上面的命令我们可以看到，BUCKET tsp_test_bucket的其中一个index信息落在OSD [91,21,103]上面，其中91为主OSD。

## 6) 查看文件存放的物理位置

首先通过下面找到某个文件的分片信息：
```
# rados -p oss-uat.rgw.buckets.data ls | grep "批量上传走joss文件 -003-KZyxg"
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.9ss6V-4Efpjof9AdqAayrGIOmkAPA-n.57
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.FTs9hvCvK3AxxgakEGmLrpgyslhm4zm.56
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.0TdGNIm7YIznPEf1UMPxcwYhHmR8VoL.101
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.FxDpkBUwC3LGAhsuRnHlh9RLDCjBZrr.49
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.JmqQHaFEcekAtxKH7AKgstpAH5RG6p7.39
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.GYI_Z3sgtCt2w4AXR5DKV6xYHKwoJJf.94
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.qgWUlcFQReljM64bmIDSV0PJlz56m9U.3
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.TWDDFzwb_mxHpEzjY2Rqe6LCG0y99sD.40
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.28ccmIApED0jTBx1NiQYt20JCcd7zIV.97
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.gOAjq4fqcl0jviok3FLS8QoY2XtxD_N.22
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.jbUJi32DMYT0vDmNJWD9cF8vOyh6L92.53
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.zHX_KU4W5xodJCkLdtCEVJWACUhri7s.18
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.8qAj-7dg8up4zdcyEPQh_aHcn5vKfE7.45
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.DRV-8NwZcCbrGSIdxjSaE2GT1z0ROb8.88
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.SZ-x9YbCkyLAr1SBXSH2cuSYWmRjCsr.11
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.iPFSlm5tecOPa5quQwX0Y9-Fhf-jWjS.36
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.5yUmMTQH6p8Oq0b0_fw7Qk32FDvL9qZ.103
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.2m0QrBOu12KDU6GnRfdKlw5HtFVLwbB.52
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.MkfgGCX-sMiZ4Ov_XY53RUhAAMS_ldI.37
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.WKwnMcOZb1wDKAPAhUjozmnvBRSsrB-.51
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.rw0xXWiXRBmfuboAXylO1kGlthfP2nG.2
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.2zBLvTYoj4cwFbSbCTlFRlLgWN4050r.61
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.UMNn7NS7mWKgL-uSHtyOJh0Gq0pH2mb.44
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.zxQUiXcdkNrUj0WxAnBavNbcG2Ag9nT.41
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.3RkO58JmJDrUE4JRbdmDHw4FfZE_p0i.90
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.97ngrv1LG1W2M0c6vDGImLDEWTyhh1s.100
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.-GidYbfZafvDcNK3tgTuEPWx8gtN5Z7.47
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.rt2heoWBQNvg57Sd6slr_6zHxtoXQS3.30
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.xAFJ69IjO-k2B1oPWfD4bLYGxd83reZ.86
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.hYcSkApMnY_PZL_t3Eg9VCUabkfoOuy.24
135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.EWUZWI7AcDJkCOX7Tau3FMio6vjP2NJ.102
...
```
其实执行上面的命令很费时，我们注意到查询出来的前一部分135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269正好是bucket的id，因此我们可以直接拼接来获取该对象在ceph中的名称。

接着使用如下命令找出该分片在osd上存放的实际位置：
```
# ceph osd map oss-uat.rgw.buckets.data 135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.VLRHO5x1l3nV4-v5W4r6YA2Fkqlfwj3.107
osdmap e16540 pool 'oss-uat.rgw.buckets.data' (189) object '-003-KZyxg.docx.VLRHO5x1l3nV4-v5W4r6YA2Fkqlfwj3.107/135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件' -> pg 189.db7b914a (189.14a) -> up ([66,9,68], p66) acting ([66,9,68], p66)
```
通过上面我们看到所查找文件的107分片分布在归置组189.14a上， 主归置组(pg)在osd.66上，在osd.9与osd.68上各有一份副本以保证数据的安全性。

我们进入osd.66对应的宿主机的/var/lib/ceph/osd-66/current/189.14a目录,查找对应的文件：
```
# pwd
/var/lib/ceph/osd/ceph-66/current/189.14a_head
# find ./ -name "*批量上传走joss文件*"
./DIR_1/DIR_A/DIR_B/DIR_D/135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269\u\umultipart\u批量上传走joss文件 -003-KZyxg.docx.GTC1zukNjjgNvpWalgjS77qP2gHIggn.78__head_8F52DBA1__bd
./DIR_1/DIR_A/DIR_B/DIR_E/135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269\u\umultipart\u批量上传走joss文件001-zEoD9.docx.2~7efn984ORCmhEbcMO3zJxjfIkvzEoD9.53__head_AFAEEBA1__bd
```

## 7) 下载分片

接着我们可以使用如下命令将分片下载下来：
```
# rados get 135882fc-2865-43ab-9f71-7dd4b2095406.20037185.269__multipart_批量上传走joss文件 -003-KZyxg.docx.9ss6V-4Efpjof9AdqAayrGIOmkAPA-n.57 /opt/批量上传走joss文件 -003-KZyxg.docx-part57 -p oss-uat.rgw.buckets.data

# ls /opt/
批量上传走joss文件 -003-KZyxg.docx-part57
```

# 2. 查找示例2

我们以查找OpenResty完全开发指南.pdf为例来演示相关过程：

## 1） 查看对应bucket相关信息
```
# radosgw-admin bucket list --bucket=liuzy_bucket
[
    {
        "name": "OpenResty完全开发指南.pdf",
        "instance": "",
        "namespace": "",
        "owner": "97B538618D3F46F8AE58EE91974EBCAB",
        "owner_display_name": "app_97B538618D3F46F8AE58EE91974EBCAB",
        "size": 155174619,
        "mtime": "2021-07-29 08:03:03.828342Z",
        "etag": "d1ca3c30886d9fdc722b1c25320431bd-37",
        "content_type": "binary\/octet-stream",
        "tag": "aeb60350-4244-488f-919a-6282e93464ea.202702.32611510",
        "flags": 0,
        "user_data": ""
    }
]
```

## 2) 查看object相关信息
```
# radosgw-admin object stat --bucket=liuzy_bucket --object=OpenResty完全开发指南.pdf
{
    "name": "OpenResty完全开发指南.pdf",
    "size": 155174619,
    "policy": {
        "acl": {
            "acl_user_map": [
                {
                    "user": "97B538618D3F46F8AE58EE91974EBCAB",
                    "acl": 15
                }
            ],
            "acl_group_map": [],
            "grant_map": [
                {
                    "id": "97B538618D3F46F8AE58EE91974EBCAB",
                    "grant": {
                        "type": {
                            "type": 0
                        },
                        "id": "97B538618D3F46F8AE58EE91974EBCAB",
                        "email": "",
                        "permission": {
                            "flags": 15
                        },
                        "name": "app_97B538618D3F46F8AE58EE91974EBCAB",
                        "group": 0
                    }
                }
            ]
        },
        "owner": {
            "id": "97B538618D3F46F8AE58EE91974EBCAB",
            "display_name": "app_97B538618D3F46F8AE58EE91974EBCAB"
        }
    },
    "etag": "d1ca3c30886d9fdc722b1c25320431bd-37\u0000",
    "tag": "aeb60350-4244-488f-919a-6282e93464ea.202702.32611510\u0000",
    "manifest": {
        "objs": [],
        "obj_size": 155174619,
        "explicit_objs": "false",
        "head_obj": {
            "bucket": {
                "name": "liuzy_bucket",
                "pool": "default.rgw.buckets.data",
                "data_extra_pool": "default.rgw.buckets.non-ec",
                "index_pool": "default.rgw.buckets.index",
                "marker": "aeb60350-4244-488f-919a-6282e93464ea.185494.42",
                "bucket_id": "aeb60350-4244-488f-919a-6282e93464ea.185494.42",
                "tenant": ""
            },
            "key": "",
            "ns": "",
            "object": "OpenResty完全开发指南.pdf",
            "instance": "",
            "orig_obj": "OpenResty完全开发指南.pdf"
        },
        "head_size": 0,
        "max_head_size": 0,
        "prefix": "OpenResty完全开发指南.pdf.2~jecqhUKZn4B5exHPkB9LfYgqbVBj5in",
        "tail_bucket": {
            "name": "liuzy_bucket",
            "pool": "default.rgw.buckets.data",
            "data_extra_pool": "default.rgw.buckets.non-ec",
            "index_pool": "default.rgw.buckets.index",
            "marker": "aeb60350-4244-488f-919a-6282e93464ea.185494.42",
            "bucket_id": "aeb60350-4244-488f-919a-6282e93464ea.185494.42",
            "tenant": ""
        },
        "rules": [
            {
                "key": 0,
                "val": {
                    "start_part_num": 1,
                    "start_ofs": 0,
                    "part_size": 4194304,
                    "stripe_max_size": 4194304,
                    "override_prefix": ""
                }
            },
            {
                "key": 150994944,
                "val": {
                    "start_part_num": 37,
                    "start_ofs": 150994944,
                    "part_size": 4179675,
                    "stripe_max_size": 4194304,
                    "override_prefix": ""
                }
            }
        ],
        "tail_instance": ""
    },
    "attrs": {
        "user.rgw.content_type": "binary\/octet-stream\u0000",
        "user.rgw.pg_ver": "�d\u0004\u0000\u0000\u0000\u0000\u0000",
        "user.rgw.source_zone": "j�\u001f�",
        "user.rgw.x-amz-acl": "private\u0000"
    }
}
```
从上面可以看到，对象OpenResty完全开发指南.pdf对应的：
- bucket_id为aeb60350-4244-488f-919a-6282e93464ea.185494.42；
- prefix为OpenResty完全开发指南.pdf.2~jecqhUKZn4B5exHPkB9LfYgqbVBj5in
- 对象总大小为155174619; 总的分片数为37片，分片序号为[1,37]; 每个分片的大小为4194304

参看下面的拼接方法可以拼接出一个分片在ceph内部的名称：
```
<bucket_id>__multipart_<prefix>.<part_idx>
```
因此，这里我们拼接出OpenResty完全开发指南.pdf的第9个分片在ceph内部的名称为：
```
aeb60350-4244-488f-919a-6282e93464ea.185494.42__multipart_OpenResty完全开发指南.pdf.2~jecqhUKZn4B5exHPkB9LfYgqbVBj5in.9
```

# 3) 查看对应分片在映射到了哪个PG
```
# ceph osd map default.rgw.buckets.data aeb60350-4244-488f-919a-6282e93464ea.185494.42__multipart_OpenResty完全开发指南.pdf.2~jecqhUKZn4B5exHPkB9LfYgqbVBj5in.9
osdmap e77518 pool 'default.rgw.buckets.data' (36) object 'aeb60350-4244-488f-919a-6282e93464ea.185494.42__multipart_OpenResty完全开发指南.pdf.2~jecqhUKZn4B5exHPkB9LfYgqbVBj5in.9' -> pg 36.4a19aa01 (36.1) -> up ([1,15,23], p1) acting ([1,15,23], p1)
```

# 4) 到对应的目录查找分片

通过上面我们知道OpenResty完全开发指南.pdf的第9个分片放在PG 36.1上，而PG 36.1映射情况如下：
```
up ([1,15,23], p1) acting ([1,15,23], p1)
```

因此，我们可以到osd.1的/var/lib/ceph/osd/ceph-1/current/36.1_head目录进行查找：
```
# find ./ -name "aeb60350-4244-488f-919a-6282e93464ea.185494.42\\\u\\\umultipart\\\uOpenResty完全开发指南.pdf.2~jecqhUKZn4B5exHPkB9LfYgqbVBj5in.9*"
./DIR_1/DIR_0/DIR_A/DIR_A/DIR_9/aeb60350-4244-488f-919a-6282e93464ea.185494.42\u\umultipart\uOpenResty完全开发指南.pdf.2~jecqhUKZn4B5exHPkB9LfYgqbVBj5in.9__head_4A19AA01__24
```
这里需要注意以下两点
- 在ceph内部， 紧邻multipart前后的_会被替换为\\\u
- 在分片名的最后面会添加上额外的一个后缀

# 3. 查找示例3

## 1) 集群osd树

当前我们的ceph集群状况如下：
```
# ceph osd tree
ID  WEIGHT  TYPE NAME                                UP/DOWN REWEIGHT PRIMARY-AFFINITY 
-20 1.34999 failure-domain sata-00-ssd                                                 
-19 1.34999     replica-domain replica-0-ssd                                           
-14 0.45000         rack rack-01-ssd                                                   
-13 0.45000             host sz-1-ssd                                                  
  0 0.45000                 osd.0                         up  1.00000          1.00000 
-16 0.45000         rack rack-02-ssd                                                   
-15 0.45000             host sz-2-ssd                                                  
  3 0.45000                 osd.3                         up  1.00000          1.00000 
-18 0.45000         rack rack-03-ssd                                                   
-17 0.45000             host sz-3-ssd                                                  
  6 0.45000                 osd.6                         up  1.00000          1.00000 
-10 1.34999 failure-domain sata-00                                                     
 -9 1.34999     replica-domain replica-0                                               
 -8 0.45000         host-domain host-group-0-rack-01                                   
 -2 0.45000             host sz-1                                                      
  1 0.14999                 osd.1                         up  1.00000          1.00000 
  2 0.14999                 osd.2                         up  1.00000          1.00000 
-11 0.45000         host-domain host-group-0-rack-02                                   
 -4 0.45000             host sz-2                                                      
  4 0.14999                 osd.4                         up  1.00000          1.00000 
  5 0.14999                 osd.5                         up  1.00000          1.00000 
-12 0.45000         host-domain host-group-0-rack-03                                   
 -6 0.45000             host sz-3                                                      
  7 0.14999                 osd.7                         up  1.00000          1.00000 
  8 0.14999                 osd.8                         up  1.00000          1.00000 
 -1 1.34999 root default                                                               
 -3 0.45000     rack rack-01                                                           
 -2 0.45000         host sz-1                                                          
  1 0.14999             osd.1                             up  1.00000          1.00000 
  2 0.14999             osd.2                             up  1.00000          1.00000 
 -5 0.45000     rack rack-02                                                           
 -4 0.45000         host sz-2                                                          
  4 0.14999             osd.4                             up  1.00000          1.00000 
  5 0.14999             osd.5                             up  1.00000          1.00000 
 -7 0.45000     rack rack-03                                                           
 -6 0.45000         host sz-3                                                          
  7 0.14999             osd.7                             up  1.00000          1.00000 
  8 0.14999             osd.8                             up  1.00000          1.00000
```
本测试集群共3台hosts，每台host上平均有3个osds。

## 2) pool size

通过如下的方式获得每个池的文件保存的副本数：
```
# ceph osd dump | grep pool
pool 18 '.rgw' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 32 pgp_num 32 last_change 194 flags hashpspool stripe_width 0
pool 19 '.rgw.root' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 16 pgp_num 16 last_change 195 flags hashpspool stripe_width 0
pool 20 '.rgw.control' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 16 pgp_num 16 last_change 196 flags hashpspool stripe_width 0
pool 21 '.rgw.gc' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 32 pgp_num 32 last_change 197 flags hashpspool stripe_width 0
pool 22 '.rgw.buckets' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 128 pgp_num 128 last_change 305 flags hashpspool stripe_width 0
pool 23 '.rgw.buckets.index' replicated size 2 min_size 2 crush_ruleset 6 object_hash rjenkins pg_num 64 pgp_num 64 last_change 206 flags hashpspool stripe_width 0
pool 24 '.log' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 32 pgp_num 32 last_change 198 flags hashpspool stripe_width 0
pool 25 '.intent-log' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 32 pgp_num 32 last_change 199 flags hashpspool stripe_width 0
pool 26 '.usage' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 32 pgp_num 32 last_change 200 flags hashpspool stripe_width 0
pool 27 '.users' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 32 pgp_num 32 last_change 201 flags hashpspool stripe_width 0
pool 28 '.users.email' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 32 pgp_num 32 last_change 202 flags hashpspool stripe_width 0
pool 29 '.users.swift' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 32 pgp_num 32 last_change 203 flags hashpspool stripe_width 0
pool 30 '.users.uid' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 32 pgp_num 32 last_change 204 flags hashpspool stripe_width 0
pool 31 '.rgw.buckets.extra' replicated size 2 min_size 2 crush_ruleset 5 object_hash rjenkins pg_num 32 pgp_num 32 last_change 207 flags hashpspool stripe_width 0
pool 32 '.rgw.buckets.ssd' replicated size 2 min_size 2 crush_ruleset 6 object_hash rjenkins pg_num 64 pgp_num 64 last_change 209 flags hashpspool stripe_width 0
```
本集群为测试集群，pool_size 值为 2。

## 3) ceph条带化对象尺寸

可以通过如下的方式查看ceph存储系统中条带化对象尺寸：
```
# ceph --show-config | grep rgw_obj_stripe_size
rgw_obj_stripe_size = 4194304
```
从上面我们可以看到对象条带化

## 4)上传文件

这里我们通过适当的方法将一个名称为`cmake-3.6.2-win64-x64.msi`的文件上传到ceph存储集群中，文件大小为15,771,063字节。

## 5)找出上述文件存放位置

### 5.1) 查看bucket中对象列表

查看test-bucket中的对象列表，确认文件是否已存到ceph集群里:
```
# radosgw-admin bucket list --bucket=test-bucket
[
    {
        "name": "cmake-3.6.2-win64-x64.msi",
        "instance": "",
        "namespace": "",
        "owner": "965DE31419464D8C92C20907668C9CE0",
        "owner_display_name": "app_965DE31419464D8C92C20907668C9CE0",
        "size": 15771063,
        "mtime": "2017-06-16 06:05:23.000000Z",
        "etag": "ef8f09c0e85fad29a1a62b339b992471-11",
        "content_type": "binary\/octet-stream",
        "tag": "default.19821.5258",
        "flags": 0
    }

]
```
### 5.2) 查看该文件在rados集群中的分布

在ceph的对象存储中，对象数据是保存在池.rgw.buckets.data中的(本例子保存在.rgw.buckets中)，我们来查看一下刚上传的文件在ceph存储集群中的对象名：
```
# rados -p .rgw.buckets ls | grep  cmake-3.6.2-win64-x64.msi
default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.10
default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.8
default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.4
default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.7
default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.6
default.21039.18_cmake-3.6.2-win64-x64.msi
default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.9
default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.1
default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.11
default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.5
default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.3
default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.2
```
上面一共列出了12个相关对象， 其中一个是元数据，其他的是刚刚上传的文件cmake-3.6.2-win64-x64.msi被条带化后产生的子object，子object的名称后面有它的序号。也就是说， cmake-3.6.2-win64-x64.msi被条带化了11个子object。结合本集群的条带化尺寸为4MB，文件大小为15,771,063字节， 15771063/4194304=3.76， 也就是需要4个子object。为什么和实际的11个子object不符呢？ 这是因为我们在上面进行上传时，使用了分片上传， 每个分片的大小是1.5MB， 15771063/(1.510241024) = 10.0269718170166015625，也就是说需要11个子object，正好与实际相符。

也就是说，只有当文件（包括：分片）的size大于rgw_obj_stripe_size时，才会触发条带化功能，而此例的分片size(1.5MB) < rgw_obj_strip_size(4MB)，所以根本没有触发ceph的条带化功能。而且，条带化是ceph的客户端（在此例中是rgw)来完成的，而不是rados层完成的。

### 5.3) 找出每个子Object的存储位置

接下来，我们逐个找出上面11个子object被ceph存在哪里，然后将它们的size相加，是否和原始文件的大小相等。下面以第一个子object：
```
default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.1
```

为例，讲解如何定位object的位置。
```
# ceph osd map .rgw.buckets default.21039.18__multipart_fm727chb174_build_setup.exe.2~9OQ6y6sBS3qGXujULlYDx5sAQy9h71h.1
osdmap e337 pool '.rgw.buckets' (22) object 'default.21039.18__multipart_fm727chb174_build_setup.exe.2~9OQ6y6sBS3qGXujULlYDx5sAQy9h71h.1' -> pg 22.a492dfd8 (22.58) -> up ([4,7], p4) acting ([4,7], p4)
```
可见，上述子object分布在归置组 22.58 上面，在 osd.4, osd.7 上面各有一份副本以保证数据的安全性。

5.4) 定位到子object

我们在前面通过osd tree可以看到，osd.4在host sz-2上面，我们SSH登录到host sz-2，并进入osd.4的数据目录：
```
# ssh sz-2
# cd /var/lib/ceph/osd/ceph-4/current/
```
然后，找出归置组 22.58 的数据目录:
```
# ll | grep 22.58   
drwxr-xr-x 3 root root 12288 Jun  3 13:53 22.58_head
drwxr-xr-x 2 root root     6 Jun  3 13:49 22.58_TEMP
# cd 22.58_head
```
找出子object在 osd.4的文件系统上的真实文件:
```
# ll | grep fm727
-rw-r--r-- 1 root root 1572864 Jun 16 14:46 default.21039.18\u\umultipart\ucmake\u3.6.2\uwin64\ux64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.1__head_A492DFD8__16
```
上面可见，子object default.21039.18__multipart_cmake-3.6.2-win64-x64.msi.2~kcu7j-Dfaenre3_ZPzygH0iLfjla1qR.1 的 size 为 1572864 字节。

5.5）求出文件总大小

按照上面的步骤，找出剩下的 10 个子objects 的 size，相加，正好等于15771063字节
