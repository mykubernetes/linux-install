```
# ceph osd perf
osd fs_commit_latency(ms) fs_apply_latency(ms)
9   0                     3
8   0                     1
7   0                     1
6   0                     1
5   0                     0
```
- fs_commit_latency # 写入延迟时间，表示写journal的完成时间(毫秒)
- fs_apply_latency # 读取延迟，表示写到osd的buffer cache里的完成时间(毫秒)
