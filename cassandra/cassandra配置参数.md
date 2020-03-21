```
cluster_name           #集群的名称
num_tokens             #这定义了随机分配给环上该节点的令牌数。相对于其他节点，令牌数越多，该节点将存储的数据比例越大。您可能希望所有节点具有相同数量的令牌，假设它们具有相等的硬件能力。
如果你留下这个未指定，Cassandra将使用默认的1令牌的旧兼容性，并将使用initial_token如下所述。
指定initial_token将在后续启动时覆盖节点初始启动时的设置，即使设置了初始令牌，此设置也将应用。 
如果您已经有一个节点有1个令牌的集群，并希望迁移到每个节点的多个令牌。

默认值: 256
λ   allocate_tokens_for_keyspace
默认情况下，此选项被注释掉。
触发此节点的num_tokens令牌的自动分配。 分配算法尝试以优化数据中心中的节点上的复制负载的方式选择令牌，以用于指定的键空间使用的复制策略。
分配给每个节点的负载将接近与其节点的数量成比例。
仅支持Murmur3Partitioner。默认值: KEYSPACE
λ   initial_token
默认情况下，此选项被注释掉。 
initial_token允许您手动指定标记。 虽然您可以使用vnodes（num_tokens> 1，上面） - 在这种情况下，您应该提供一个逗号分隔的列表 - 它主要用于将节点添加到未启用vnode的旧群集。 
λ   hinted_handoff_enabled
可能是“true”或“false”以启用全局
默认值: true
λ   hinted_handoff_disabled_datacenters
默认情况下，此选项被注释掉。
当hinted_handoff_enabled为true时，将不执行暗示切换的数据中心的黑名单
默认值 (复杂选项):
#    - DC1
#    - DC2
λ   max_hint_window_in_ms
这定义了死主机将生成提示的最大时间量。 它已经死了这么长的时间，它的新提示将不会创建，直到它被看到活着，并再次下降。
默认值: 10800000 # 3 hours
λ   hinted_handoff_throttle_in_kb
每个传递线程的最大速度（KB）/秒。 这将与集群中的节点数成比例地减少。（如果集群中有两个节点，则每个传递线程将使用最大速率;如果有三个节点，则每个节点将节流到最大值的一半，因为我们期望两个节点同时传递提示）。
默认值: 1024
λ   max_hints_delivery_threads
传递提示的线程数; 在进行多dc部署时，请考虑增加此数，因为交叉直流切换往往较慢
默认值: 2
λ   hints_directory
默认情况下，此选项被注释掉
Cassandra应该存储提示的目录。 如果未设置，则默认目录为$ CASSANDRA_HOME / data / hints。
默认值: /var/lib/cassandra/hints
λ   hints_flush_period_in_ms
提示应该从内部缓冲区刷新到磁盘的频率。不会触发fsync。
默认值: 10000
λ   max_hints_file_size_in_mb
单个提示文件的最大大小（MB）。
默认值: 128
λ   hints_compression
默认情况下，此选项将被注释掉。
压缩以应用于提示文件。 如果省略，hints文件将被解压缩。支持LZ4，Snappy和Deflate压缩机。
默认值 (复杂选项):
#   - class_name: LZ4Compressor
#     parameters:
#         -
λ   batchlog_replay_throttle_in_kb
最大速率（KB）/秒，总数。这将与集群中的节点数成比例地减少。
默认值: 1024
λ   authenticator
后端认证，实现IAuthenticator;用于标识用户，Cassandra提供了org.apache.cassandra.auth。{AllowAllAuthenticator，PasswordAuthenticator}。
AllowAllAuthenticator不执行任何检查 - 将其设置为禁用身份验证。
PasswordAuthenticator依赖用户名/密码对来验证用户。它将用户名和散列密码保存在system_auth.credentials表中。如果使用此验证器，请增加system_auth键空间复制因子。如果使用PasswordAuthenticator，还必须使用CassandraRoleManager（见下文）
默认值: AllowAllAuthenticator
λ   authorizer
后端授权，实现IAuthorizer;用于限制访问/提供权限，Cassandra提供了org.apache.cassandra.auth。{AllowAllAuthorizer，CassandraAuthorizer}。
AllowAllAuthorizer 允许任何用户的任何操作 - 将其设置为禁用授权。
CassandraAuthorizer 在system_auth.permissions表中存储权限。如果使用此授权器，请增加system_auth键空间复制因子。
默认值: AllowAllAuthorizer
λ   role_manager
部分认证和授权后端，实现IRoleManager; 用于维护角色之间的授权和成员资格。 Cassandra提供了org.apache.cassandra.auth.CassandraRoleManager，它在system_auth键空间中存储角色信息。IRoleManager的大多数功能需要经过身份验证的登录，因此除非配置的IAuthenticator实际上实现身份验证，否则大多数此功能将不可用。
CassandraRoleManager将角色数据存储在system_auth键空间中。如果使用此角色管理器，请增加system_auth键空间复制因子。
默认值: CassandraRoleManager
λ   roles_validity_in_ms
角色缓存的有效期（获取授权角色可能是一个昂贵的操作，取决于角色管理器，CassandraRoleManager是一个示例）授予的角色缓存为AuthenticatedUser中的已验证会话，并在此处指定的时间段后成为资格（async）重新加载。默认为2000，设置为0以完全禁用缓存。将自动禁用AllowAllAuthenticator。
默认值: 2000
λ   roles_update_interval_in_ms
默认情况下，此选项被注释掉
角色缓存的刷新间隔（如果已启用）。 在此时间间隔之后，缓存条目将有资格进行刷新。在下一次访问时，将调度异步重载，并返回旧值，直到完成为止。如果roles_validity_in_ms非零，那么这也必须是。默认为与roles_validity_in_ms相同的值。
默认值: 2000
λ   permissions_validity_in_ms
权限缓存的有效期（获取权限可以是一个昂贵的操作，取决于授权人，CassandraAuthorizer isone示例）。默认为2000，设置为0以禁用。将为AllowAllAuthorizer自动禁用。
默认值: 2000
λ   permissions_update_interval_in_ms
默认情况下，此选项被注释掉
权限缓存的刷新间隔（如果已启用）。 在此时间间隔之后，缓存条目将有资格进行刷新。在下一次访问时，将调度异步重载，并返回旧值，直到完成为止。如果permissions_validity_in_ms非零，那么这也必须是。默认为与permissions_validity_in_ms相同的值。
默认值: 2000
λ   credentials_validity_in_ms
凭证缓存的有效期。 此缓存与提供的IAuthenticator的PasswordAuthenticator实现紧密耦合。如果配置了另一个IAuthenticator实现，则不会自动使用此缓存，因此以下设置将不起作用。请注意，凭证以其加密形式缓存，因此在激活此缓存时可能会减少对基础表执行的查询数量，但可能无法显着降低单个身份验证尝试的延迟。默认为2000，设置为0以禁用凭据缓存。
默认值: 2000
λ   credentials_update_interval_in_ms
默认情况下，此选项被注释掉
凭据缓存的刷新间隔（如果已启用）。 在此时间间隔之后，缓存条目将有资格进行刷新。在下一次访问时，将调度异步重载，并返回旧值，直到完成为止。如果credentials_validity_in_ms非零，那么这也必须是。默认为与credentials_validity_in_ms相同的值。
默认值: 2000
λ   partitioner
分区器负责在集群中的节点之间分布行组（按分区键）。 你应该留下这个单独的新集群。 分区器不能在不重新加载所有数据的情况下更改，因此在升级时，应将其设置为您已在使用的相同分区器。
除了Murmur3Partitioner，包括用于向后兼容性的分区器包括RandomPartitioner，ByteOrderedPartitioner和Order Preserving Partitioner。
默认值: org.apache.cassandra.dht.Murmur3Partitioner
λ   data_file_directories
默认情况下，此选项被注释掉
Cassandra应该将数据存储在磁盘上的目录。 Cassandra将按照配置的压缩策略的粒度均匀地在它们之间传播数据。 如果未设置，则默认目录为$ CASSANDRA_HOME / data / data。
默认值 (复杂选项):
#     - /var/lib/cassandra/data
λ   commitlog_directory
默认情况下，此选项被注释掉。 提交日志。 当在磁性HDD上运行时，这应当是与数据目录分开的主轴。 如果未设置，则默认目录为$ CASSANDRA_HOME / data / commitlog。
默认值: /var/lib/cassandra/commitlog
λ   cdc_enabled
在每个节点的基础上启用/禁用CDC功能。 这将修改用于写入路径分配拒绝的逻辑（标准：从不拒绝。cdc：如果在cdc_raw_directory中的空间限制，则拒绝包含启用CDC的表的变动）。  
默认值: false
λ   cdc_raw_directory
默认情况下，此选项被注释掉
CommitlogSegments在flush时移动到此目录，如果cdc_enabled：true，并且segment包含启用CDC的表的突变，那么这应该放在与数据目录分开的主轴上。如果未设置，则默认目录为$ CASSANDRA_HOME / data / cdc_raw。
默认值: /var/lib/cassandra/cdc_raw
disk_failure_policy
数据磁盘故障策略：
die
关闭gossip和客户端传输，并针对任何文件系统错误或单sstable错误终止JVM，替换节点。
λ   stop_paranoid
关闭gossip和客户端传输，即使是单稳定错误，也可以在启动期间杀死JVM以获取错误。
stop
关闭gossip和客户端传输，使节点有效死亡，但仍然可以通过JMX检查，在启动期间杀死JVM的错误。
λ   best_effort
停止使用故障磁盘并根据剩余的可用sstables响应请求。这意味着您将在CL.ONE看到过时的数据！
ignore
Cassandra1.2之前版本忽略致命错误并让请求失败。
默认值: stop
commit_failure_policy
提交磁盘故障的策略：
die
关闭gossip和Thrift并杀死JVM，替换节点。
stop
关闭gossip和Thrift，使节点有效死亡，但仍然可以通过JMX进行检查。
stop_commit
如Cassandra 2.0.5之前版本关闭提交日志，但是继续读取服务收集信息。
ignore
忽略致命错误，并让批次失败
默认值: stop
prepared_statements_cache_size_mb
本地协议预编译语句高速缓存的最大大小
有效值为“auto”（省略该值）或值大于0。
注意，指定太大的值将导致长时间运行的GC和可能的内存不足错误。将值保持在堆的一小部分。
如果你经常看到“预编译语句在最后一分钟被丢弃，达到了超过限制”消息，第一步是调查这些消息的根本原因，并检查预编译语句是否被正确使用。对可变部分使用绑定标记。
只有当你真的有更多的预编译语句在缓存中时才要修改默认值。 在大多数情况下，更改此值不是必需的。不断重新编译预编译语句是一种性能损失。
默认值（“auto”）：是堆的1 / 256或10MB，以较大者为准
thrift_prepared_statements_cache_size_mb
Thrift预编译语句缓存的最大大小
如果你根本不使用Thrift，那么将此值保留在“auto”是安全的。
有关详细信息，请参见上面的“prepared_statements_cache_size_mb”的描述。
默认值（“auto”）：是堆的1 / 256或10MB，以较大者为准
key_cache_size_in_mb
内存中密钥缓存的最大大小。
每个键缓存中保存1个查找，每个行缓存中至少保存2个查找。 密钥缓存所保存数据的生存时间非常短暂，因此它适用于缓存大数字。行高速缓存节省了更多的时间，但必须包含整个行，所以它空间密集型。 如果你有热行或静态行，最好只使用行缓存。
注意：如果减小大小，您可能无法在启动时加载最热键。
默认值为空，设置为“自动”后是堆的5％或100MB，以较小者为准。设置为0可禁用密钥缓存。
key_cache_save_period
Cassandra保存的密钥缓存持续时间（以秒为单位）。缓存保存到saved_caches_directory，并在配置文件中指定。
保存的高速缓存大大提高了冷启动速度，并且在密钥高速缓存方面I / O相对便宜。行高速缓存更昂贵，并且使用有限。
默认值是14400或4小时.
默认值: 14400
key_cache_keys_to_save
默认情况下，此选项被注释掉
密钥缓存中要保存的密钥数默认情况下禁用，意味着所有密钥都将保存
默认值: 100
row_cache_class_name
默认情况下，此选项被注释掉
行缓存实现类名。 可用实现：
org.apache.cassandra.cache.OHCProvider
完全堆外行缓存实现（默认）。
org.apache.cassandra.cache.SerializingCacheProvider
这是先前版本Cassandra中可用的行缓存实现。
默认值: org.apache.cassandra.cache.OHCProvider
row_cache_size_in_mb
请注意，OHC缓存实现需要一些额外的堆外存储器来管理映射结构和一些在运行期间在缓存条目可以针对缓存容量计算之前/之后的运行中的内存。这个开销通常比整个容量小。不要指定更多的内存，系统在最坏的情况下可以承受，并留下一些空间用于操作系统块级缓存。不要让你的系统交换。
默认值为0，以禁用行缓存。
默认值: 0
row_cache_save_period
Cassandra保存的行缓存持续时间（以秒为单位）。缓存保存到saved_caches_directory，并在配置文件中指定。
保存的高速缓存大大提高了冷启动速度，并且在密钥高速缓存方面I / O相对便宜。行高速缓存更昂贵，并且使用有限。
默认值为0，禁用保存行高速缓存 
默认值: 0
row_cache_keys_to_save
默认情况下，此选项被注释掉
来自行缓存的键的数量（默认值是0），表示所有键都将被保存
默认: 100
counter_cache_size_in_mb
内存中计数器高速缓存的最大大小。
计数器高速缓存有助于减少计数器锁对热计数器单元的争用。 在RF = 1的情况下，计数器高速缓存命中将导致Cassandra在完全写入之前跳过读取。 在RF> 1的情况下，计数器缓存命中仍将有助于减少锁定保持的持续时间，帮助热计数器单元更新，但不允许完全跳过读取。只有计数器单元的本地（时钟，计数）元组保存在存储器中，而不是整个计数器，因此它消耗的资源相对较少。
注意：如果减小大小，您可能无法在启动时加载最热键。
默认值为空，使其为“auto”（堆的2.5％和50MB中较小的值）。设置为0以禁用计数器高速缓存。注意：如果执行计数器删除并依赖于低gcgs，则应禁用计数器高速缓存。
counter_cache_save_period
Cassandra应保存计数器缓存（仅keys）持续时间（以秒为单位）。缓存保存到saved_caches_directory，并在配置文件中指定。
默认值为7200或2小时。
默认值: 7200
counter_cache_keys_to_save
默认情况下，此选项被注释掉
计数器缓存中键的数量，默认禁用，意味着所有键都将被保存
默认值: 100
saved_caches_directory
默认情况下，此选项被注释掉
保存缓存的位置如果未设置，默认目录为$ CASSANDRA_HOME / data / saved_caches。
默认值: /var/lib/cassandra/saved_caches
commitlog_sync
默认情况下，此选项被注释掉
commitlog_sync可以是“periodic”或“batch”。
在批处理模式下，Cassandra不会进行ack写操作，直到提交日志已经同步到磁盘。它将在同步期间等待commitlog_sync_batch_window_in_ms毫秒。这个窗口应该保持简短，因为写入线程将无法在等待时执行额外的工作。（基于同样的原因，您可能需要增加concurrent_writes。）
默认值: batch
commitlog_sync_batch_window_in_ms
默认情况下，此选项被注释掉
默认值: 2
commitlog_sync
另一个选项是“periodic”，该选项可以立即执行写入并且每隔commitlog_sync_period_in_ms毫秒对Commitlog进行简单的同步。
默认值: periodic
commitlog_sync_period_in_ms
默认值: 10000
commitlog_segment_size_in_mb
各个commitlog文件段的大小。 一旦提交日志段中的所有数据（可能来自系统中的每个列系统）已被刷新到sstables，那么它可以被归档，删除或循环。 
默认大小是32，32基本上是符合所有正常情况下的使用，但如果您归档commitlog段（请参阅commitlog_archiving.properties），那么您可能需要更精细的归档粒度;8或16 MB是合理的。最大突变大小也可以通过cassandra.yaml中的max_mutation_size_in_kb设置进行配置。默认值为commitlog_segment_size_in_mb * 1024的一半。
如果明确设置了max_mutation_size_in_kb，则必须将commitlog_segment_size_in_mb设置为至少两倍大小max_mutation_size_in_kb / 1024
默认值: 32
commitlog_compression
默认情况下，此选项被注释掉
应用压缩提交日志。 如果省略，提交日志将被解压缩。 支持LZ4，Snappy和Deflate压缩机。
默认值 (复杂选项):
#   - class_name: LZ4Compressor
#     parameters:
#         -
seed_provider
任何实现Seed的类都提供程序接口并且具有采用Map <String，String>参数的构造函数的类。
默认值 (复杂选项):
# Addresses of hosts that are deemed contact points.
# Cassandra nodes use this list of hosts to find each other and learn
# the topology of the ring.  You must change this if you are running
# multiple nodes!
- class_name: org.apache.cassandra.locator.SimpleSeedProvider
  parameters:
      # seeds is actually a comma-delimited list of addresses.
      # Ex: "<ip1>,<ip2>,<ip3>"
      - seeds: "127.0.0.1"
concurrent_reads
对于具有比内存可容纳数据更多的数据的工作负载，Cassandra的瓶颈将是需要从磁盘提取数据的读取。“concurrent_reads”应该设置为（16 * number_of_drives），以便降低堆栈中排队的操作，操作系统和驱动器可以对它们重新排序。这同样适用于“concurrent_counter_writes”，因为计数器写入在递增和写回它们之前读取当前值。
另一方面，由于写入几乎没有IO限制，“concurrent_writes”的理想数量取决于系统中的核心数;（8 * number_of_cores）是一个好的经验法则。
默认值: 32
concurrent_writes
默认值: 32
concurrent_counter_writes
默认值: 32
concurrent_materialized_view_writes
对于物化视图写入，由于涉及到读取，因此这应该受到并发读取或并发写入数量的限制。
默认值: 32
file_cache_size_in_mb
默认情况下，此选项被注释掉。
用于sstable块缓存和缓冲池的最大内存。 其中32MB保留用于池缓冲区，其余的用作保存未压缩sstable块的高速缓存。默认为堆的1/4或512MB的较小值。此池是在堆外分配的，因此除了为堆分配的内存之外。缓存还具有堆上开销，每个块大约为128字节（即如果使用默认的64k块大小，则为保留大小的0.2％）。内存只在需要时分配。
默认值: 512
buffer_pool_use_heap_if_exhausted
默认情况下，此选项被注释掉。
当sstable缓冲池耗尽时，即当它已超过最大内存file_cache_size_in_mb时，它将指示是否分配on或off堆的标志，超过它将不会缓存缓冲区，而是根据请求分配。
默认值: true
disk_optimization_strategy
默认情况下，此选项被注释掉。
优化磁盘读取的策略可能的值为：ssd（对于固态磁盘，默认值）spin（用于旋转磁盘）。
默认值: ssd
memtable_heap_space_in_mb
默认情况下，此选项被注释掉。
用于memtables的总内存。 Cassandra将在超过限制时停止接受写操作，直到刷新完成，并将根据memtable_cleanup_threshold触发刷新。如果省略，Cassandra将设置为堆大小的1/4。
默认值: 2048
memtable_offheap_space_in_mb
默认情况下，此选项被注释掉。
默认值: 2048
memtable_cleanup_threshold
默认情况下，此选项被注释掉。
不推荐使用memtable_cleanup_threshold。默认计算是唯一合理的选择。
占用的非刷新memtable大小与memtable的最大大小之比。较大的mct将意味着更大的刷新，因此压缩更少，但是也更少的并发刷新活动，这可能使得难以保持您的磁盘在巨大的写入负载下馈送。
memtable_cleanup_threshold默认为1 /（memtable_flush_writers + 1）
默认值: 0.11
memtable_allocation_type
指定Cassandra分配和管理memtable内存的方式。选项包括：
heap_buffers
堆nio缓冲区
offheap_buffers
非堆（直接）nio缓冲区
offheap_objects
非堆对象
默认值: heap_buffers
commitlog_total_space_in_mb
默认情况下，此选项被注释掉。
磁盘上用于提交日志的总空间。
如果空间超过此值，Cassandra将清除最旧段中的每个脏CF并删除它。因此，小的总commitlog空间将导致对活动较少的列族的更多刷新活动。 
默认值是8192和1/4commitlog卷总空间的较小值。
默认值: 8192
λ   memtable_flush_writers
默认情况下，此选项被注释掉。
这将设置每个磁盘的memtable flush写线程数以及可以同时刷新的memtables的总数。这些通常是计算和IO绑定的组合。
memtable刷新比memtable提取在CPU上更加高效，单个线程可以跟上单个快速磁盘上整个服务器的吞吐率，直到它在通常使用压缩的争用中暂时变为IO绑定。这时你需要多个刷新线程。在将来的某个时候，它可能成为CPU限制所有的时间。 
你可以使用MemtablePool.BlockedOnAllocation指标来判断刷新是否落后，该指标应该为0，但如果线程被阻塞等待刷新以释放内存，则该值将为非零。
对于单个数据目录，memtable_flush_writers默认为两个。这意味着两个memtables可以同时刷新到单个数据目录。如果你有多个数据目录，默认是一次刷新一个memtable，但每个数据目录刷新将使用一个线程，所以你会得到两个或更多的写入。
两个通常足以在作为单个数据目录安装的快速磁盘上刷新。添加更多刷新写入将导致更小的更频繁的刷新，从而引入更多的压缩开销。
在可以同时刷新的memtables数量、flush大小和频率之间有一个直接的权衡。更多并不一定更好，你只需要足够的flush写入保证不出现程序停止，等待刷新释放内存。
默认值: 2
cdc_total_space_in_mb
默认情况下，此选项被注释掉。
磁盘上用于更改数据捕获日志的总空间。
如果空间超过此值，Cassandra将在Mutations（包括启用CDC的表）上抛出WriteTimeoutException。CDCCompactor负责解析原始CDC日志，并在解析完成时删除它们。
默认值为4096 mb和1/8cdc_raw_directory所在驱动器的总空间的较小值。
默认值: 4096
cdc_free_space_check_interval_ms
默认情况下，此选项被注释掉。
当我们打开cdc_raw限制并且CDCCompactor运行在后面或遇到背压时，我们在以下时间间隔检查是否有任何新的cdc-tracked表空间可用。默认为250ms
默认值: 250
index_summary_capacity_in_mb
用于SSTable索引摘要的固定内存池大小（MB）。 如果留空，这将默认为堆大小的5％。 如果所有索引摘要的内存使用超过此限制，则具有低读取速率的SSTables将缩减其索引摘要，以满足此限制。然而，这是一个尽力而为的过程。在极端条件下，Cassandra可能需要使用超过这个数量的内存。
index_summary_resize_interval_in_minutes
索引摘要应重复取样的频率。 这是定期完成的，以便将内存从固定大小的池中根据sstables最近的读取速率按比例重新分配到sstables中。设置为-1将禁用此过程，将现有索引摘要保留在当前采样级别。
默认值: 60
trickle_fsync
是否在进行顺序写入时将间隔时间设置为fsync（）以强制操作系统刷新脏缓冲区。启用此选项可避免突然的脏缓冲区冲刷影响读取延迟。 对于SSD来说这几乎总是一个好主意。
默认值: false
trickle_fsync_interval_in_kb
默认值: 10240
storage_port
TCP端口，用于命令和数据,出于安全原因不应将此端口公开到互联网。如果必须公开到互联网需要打开防火墙。
默认值: 7000
ssl_storage_port
SSL端口，用于加密通信。 默认情况下不使用，除非在encryption_options中出于安全原因启用，您不应将此端口公开到互联网。如果必须公开到互联网需要打开防火墙。
默认值: 7001
listen_address
绑定地址或接口并告诉其他Cassandra节点连接到该地址或接口。如果你想要多个节点能够沟通则必需改变这个！
设置listen_address或listen_interface其中之一，不要对两者都进行设置。
留下空白给InetAddress.getLocalHost（）。这将始终正确地配置节点（主机名，名称解析等），并且使用与主机名相关联的地址。
将listen_address设置为0.0.0.0总是错误的。
默认值: localhost
listen_interface
默认情况下，此选项被注释掉。
设置listen_address或listen_interface其中之一，不要对两者都进行设置。接口必须对应于单个地址，不支持IP别名。
默认值: eth0
listen_interface_prefer_ipv6
默认情况下，此选项被注释掉。
如果选择按名称指定接口，并且接口具有ipv4和ipv6地址，您可以指定应使用listen_interface_prefer_ipv6选择哪个。如果为false，将使用第一个ipv4地址。如果为true，将使用第一个ipv6地址。默认为false使用ipv4。如果只有一个地址，它将被选择，而不考虑ipv4 / ipv6。
默认值: false
broadcast_address
默认情况下，此选项被注释掉。
要广播到其他Cassandra节点的地址保留此空白将将其设置为与listen_address相同的值
默认值: 1.2.3.4
listen_on_broadcast_address
默认情况下，此选项被注释掉。
当使用多个物理网络接口时，将此设置为true可以在listen_address之外的broadcast_address上侦听，从而允许节点在两个接口中进行通信。如果网络配置在公共网络和专用网络（例如EC2）之间自动路由，请忽略此属性。
默认值: false
internode_authenticator
默认情况下，此选项被注释掉。
Internode后端认证，实现IInternodeAuthenticator;用于允许/禁止来自对等节点的连接。
默认值: org.apache.cassandra.auth.AllowAllInternodeAuthenticator
start_native_transport
是否启动本地传输服务器。 请注意，本地传输绑定的地址与rpc_address相同。端口不同，下面指定。
默认值: true
native_transport_port
该端口为CQL本地传输监听客户端。出于安全原因不应将此端口公开到互联网。如果必须公开到互联网需要打开防火墙。
默认值: 9042
native_transport_port_ssl
默认情况下，此选项被注释掉。
在client_encryption_options中启用本地传输加密允许您对标准端口使用加密，或者使用专用的附加端口以及未加密的标准native_transport_port。启用客户端加密并禁用native_transport_port_ssl将对native_transport_port使用加密。将native_transport_port_ssl设置为与native_transport_port不同的值将对native_transport_port_ssl使用加密，同时保持native_transport_port未加密。
默认值: 9142
native_transport_max_threads
默认情况下，此选项被注释掉。
使用本地传输时处理请求的最大线程数。这类似于rpc_max_threads，尽管默认值略有不同（并且没有native_transport_min_threads，空闲线程将始终在30秒后停止）。
默认值: 128
native_transport_max_frame_size_in_mb
默认情况下，此选项被注释掉。
允许的帧的最大大小。 大于此值的帧（请求）将被拒绝为无效。默认值为256MB。如果您要更改此参数，可能需要相应地调整max_value_size_in_mb。
默认值: 256
native_transport_max_concurrent_connections
默认情况下，此选项被注释掉。
并发客户端连接的最大数量。默认值为-1，表示无限制。
默认值: -1
native_transport_max_concurrent_connections_per_ip
默认情况下，此选项被注释掉。
每个源ip的并发客户端连接的最大数量。默认值为-1，表示无限制。
默认值: -1
start_rpc
是否启动thrift rpc服务器。
默认值: false
rpc_address
绑定Thrift RPC服务和本地传输服务器的地址或接口。
设置rpc_address或rpc_interface，仅需设置一个。
留下rpc_address空白具有与listen_address相同的效果（即它将基于节点的已配置主机名）。 
与listen_address不同，可以指定0.0.0.0，但是还必须将broadcast_rpc_address设置为除0.0.0.0之外的值。 
出于安全原因不应将此端口公开到互联网。如果必须公开到互联网需要打开防火墙。
默认值: localhost
rpc_interface
默认情况下，此选项被注释掉。
设置rpc_address或rpc_interface，仅需设置一个。接口必须对应于单个地址，不支持IP别名。 
默认值: eth1
rpc_interface_prefer_ipv6
默认情况下，此选项被注释掉。
如果选择按名称指定接口，并且接口具有ipv4和ipv6地址，则使用rpc_interface_prefer_ipv6指定选择哪个。如果为false，将使用第一个ipv4地址。如果为true，将使用第一个ipv6地址，默认为false。如果只有一个地址，它将被选择，而不考虑ipv4 / ipv6。
默认值: false
rpc_port
端口为Thrift监听客户端
默认值: 9160
broadcast_rpc_address
默认情况下，此选项被注释掉。
RPC地址广播到驱动程序和其他Cassandra节点。 此值不能设置为0.0.0.0。 如果留空，这将被设置为rpc_address的值。 如果rpc_address设置为0.0.0.0，则必须设置broadcast_rpc_address。
默认值: 1.2.3.4
rpc_keepalive
在rpc /本地连接上启用或禁用keepalive
默认值: true
rpc_server_type
Cassandra为RPC服务器提供了两个选项：
sync
每个节点连接一个线程。 对于具有大量链接的客户端，内存将是您的限制因素。在64位JVM上，180KB是每个线程的最小堆栈大小，这将对应于您使用虚拟内存（但物理内存可能受限于堆栈空间的使用）。
hsha
代表“半同步，半异步”。所有节点客户端都使用少量线程进行异步处理，这些线程不会随thrift客户端的数量而变化（因此可以很好地扩展到许多客户端）。rpc请求仍然是同步的（每个活动请求一个线程）。如果选择hsha，那么rpc_max_threads必须从unlimited的缺省值中改变。
默认值为同步，因为在Windows中hsha大约慢30％。 在Linux上，sync / hsha性能大致相同，hsha当然使用更少的内存。
或者，可以通过提供可创建其实例的o.a.c.t.TServerFactory的完全限定类名来提供您自己的RPC服务器。
默认值: sync
rpc_min_threads
默认情况下，此选项被注释掉。
取消注释rpc_min | max_thread以设置请求池大小限制。
无论您选择什么RPC服务器（见上文），RPC线程池中的最大请求数量都决定了可能有多少并发请求（但如果您使用同步RPC服务器，则它还会指定哪些可以连接）。
默认值是无限的，因此不会对防止服务器超负荷的客户端提供保护。我们鼓励您在生产环境中设置最大值，但请记住，rpc_max_threads表示此服务器可能同时执行的最大客户端请求数。
默认值: 16
rpc_max_threads
默认情况下，此选项被注释掉。
默认值: 2048
rpc_send_buff_size_in_bytes
默认情况下，此选项被注释掉。
取消注释在rpc连接上设置套接字缓冲区大小
rpc_recv_buff_size_in_bytes
默认情况下，此选项被注释掉。
internode_send_buff_size_in_bytes
默认情况下，此选项被注释掉。
取消注释为节点间通信设置套接字缓冲区大小。设置此值时，缓冲区大小受net.core.wmem_max的限制，不设置时，它由net.ipv4.tcp_wmem定义，另见：/ proc / sys / net /core / wmem_max / proc / sys / net / core / rmem_max / proc / sys / net / ipv4 / tcp_wmem / proc / sys / net / ipv4 / tcp_wmem和'man tcp'
internode_recv_buff_size_in_bytes
默认情况下，此选项被注释掉。
取消注释为节点间通信设置套接字缓冲区大小。设置此时，缓冲区大小受限于net.core.wmem_max，并且当不设置时，它由net.ipv4.tcp_wmem定义
thrift_framed_transport_size_in_mb
节点的帧大小（最大消息长度）。
默认值: 15
incremental_backups
设置为true，为Cassandra键空间backups /子目录中每个数据的sstable刷新或流传输创建本地硬链接。删除这些链接是运营商的责任。
默认值: false
snapshot_before_compaction
是否在每次压缩之前创建快照。 小心使用此选项，因为Cassandra不会为您清理快照。 
默认值: false
auto_snapshot
是否在删除键空间或删除列族之前删除数据的快照。 STRONGLY建议的默认值为true应该用于提供数据安全。 如果将此标志设置为false，则将丢失截断或丢弃的数据。
默认值: true
column_index_size_in_kb
分区中行的排序规则索引的粒度。 如果行很大，或者每个分区的行数非常多，则增加。相互竞争的目标是： 
较小的粒度意味着生成更多的索引条目，并且通过排序列查找具有分区的行更快
但是，Cassandra会在热行（作为密钥缓存的一部分）的内存中保持排序规则索引，因此较大的粒度意味着可以缓存更多热行
默认值: 64
column_index_cache_size_in_kb
每个超过此大小的索引的索引缓存条目（上述内存中的排序规则索引）不会在堆上保留。这意味着只有分区信息保存在堆上，并且索引条目从磁盘读取。 
请注意，此大小指的是序列化索引信息的大小，而不是分区的大小。
默认值: 2
concurrent_compactors
默认情况下，此选项被注释掉。
允许同时压缩的数量，不包括用于反熵修复的验证“压缩”。 同时压缩可以通过减少在单个长时间运行压缩期间小的sstables累积的趋势来帮助保持混合读/写工作负载中的读取性能。 所设置的默认值通常可以使压缩的性能很好，如果你遇到压缩运行太慢或太快的问题，你应该首先查看compaction_throughput_mb_per_sec。
concurrent_compactors默认为（磁盘数目，核心数目）中的较小值，最小值为2，最大值为8。
如果数据目录由SSD支持，则应将其增加到核心数。
默认值: 1
compaction_throughput_mb_per_sec
调节压缩到整个系统的给定总吞吐量。 插入数据的速度越快，您需要压缩的速度越快，以便保持稳定计数，但一般来说，将其设置为插入数据的16到32倍是足够的。将其设置为0将禁用调节。此帐户适用于所有类型的压缩，包括验证压缩。
默认值: 16
sstable_preemptive_open_interval_in_mb
当压实时，替换的sstables在它们被完全写入之前打开，并且用于代替任何范围内先前已经写入的sstable。这有助于在sstables之间平滑地传输读取，减少页面缓存搅乱和保持热点行的热度。
默认值: 50
stream_throughput_outbound_megabits_per_sec
默认情况下，此选项被注释掉。
将此节点上的所有出站流文件传输速率调整为给定的总吞吐量（Mbps）。这是必要的，因为Cassandra在引导或修复期间流式传输数据时大多数是顺序IO，这可能导致网络连接饱和并降低rpc性能。取消设置时，默认值为200 Mbps或25 MB / s。
默认值: 200
inter_dc_stream_throughput_outbound_megabits_per_sec
默认情况下，此选项被注释掉。
调节数据中心之间的所有流文件传输，此设置允许用户调节交叉流流吞吐量，同时抑制所有网络流流量，如配置为stream_throughput_outbound_megabits_per_sec时取消设置, 默认值为200 Mbps或25 MB / s
默认值: 200
read_request_timeout_in_ms
协调器应为完成读操作等待多长时间
默认值: 5000
range_request_timeout_in_ms
协调器应为seq和索引扫描等待多长时间
默认值: 10000
write_request_timeout_in_ms
协调器应为完成写入等待多长时间
默认值: 2000
counter_write_request_timeout_in_ms
协调器应为完成计数器写入等待多长时间
默认值: 5000
cas_contention_timeout_in_ms
协调器应该继续重试与同一行的其他提案进行竞争的CAS操作的时间长度
默认值: 1000
truncate_request_timeout_in_ms
协调器应该为完成截断操作等待多长时间（这可能会更长，因为除非自动快照被禁用，否则我们需要先清除，以便在删除数据之前进行快照）。
默认值: 60000
request_timeout_in_ms
其他操作的默认超时
默认值: 10000
slow_query_log_timeout_in_ms
节点记录慢速查询前等待多长时间。 选择花费时间超过此超时时间执行的查询，将生成聚合日志消息，以便识别慢速查询。将此值设置为零可禁用慢查询日志记录。
默认值: 500
cross_node_timeout
在节点之间启用操作超时信息交换，以准确测量请求超时。 如果禁用，副本将假定协调器立即将请求转发给它们，这意味着在过载情况下，我们将浪费大量额外的时间来处理已超时的请求。
警告：在启用此属性之前，请确保已安装ntp并且节点之间的时间同步。
默认值: false
streaming_keep_alive_period_in_secs
默认情况下，此选项被注释掉。
设置流的保持活动周期。 此节点将当前周期内周期性地发送保持活动消息。如果节点在2个周期内没有从对等体接收保持活动消息那么流会话就会超时和失败。一个周期的默认值是300s（5分钟），这意味着停止的流在默认情况下10分钟超时。
默认值: 300
phi_convict_threshold
默认情况下，此选项被注释掉。
必须达到一个主机被标记的phi值。大多数用户永远不需要调整这个。
默认值: 8
endpoint_snitch
endpoint_snitch - 将此设置为实现IEndpointSnitch的类。该信号具有两个功能： 
它教会Cassandra关于您的网络拓扑信息以有效地路由请求
它允许Cassandra在您的集群周围传播副本，以避免相关的故障。它通过将机器分组为“数据中心”和“机架”来实现这一点。Cassandra将尽最大努力在同一个“机架”上不要有多个副本（实际上可能不是物理位置）
CASSANDRA不允许您切换到不可分段的一个数据插入到群集器。这将导致数据丢失。这意味着如果您使用默认的SimpleSnitch（它定位了“datacenter1”中的“rack1”上的每个节点），则只有在需要添加另一个数据中心时GossipingPropertyFileSnitch（和旧的PFS）是唯一的选项。如果你想迁移到一个不兼容的snell例如Ec2Snitch，你可以通过在Ec2Snitch下添加新节点（这将定位他们在一个新的“数据中心”）和退役旧节点。
Cassandra提供：
SimpleSnitch:
将战略顺序视为接近度。这可以在禁用读修复时提高缓存位置。仅适用于单数据中心部署。
GossipingPropertyFileSnitch
这应该是你的生产使用的。本地节点的机架和数据中心在cassandra-rackdc.properties中定义，并通过gossip传播到其他节点。如果存在cassandra-topology.properties，它将用作回退，从而允许从PropertyFileSnitch进行迁移。
PropertyFileSnitch:
接近性由机架和数据中心决定，这些在cassandra-topology.properties中显式配置。
Ec2Snitch:
适用于单个区域中的EC2部署。从EC2 API加载区域和可用区域信息。区域被视为数据中心，可用区域被视为机架。仅使用私有IP，因此这不会在多个区域工作。
Ec2MultiRegionSnitch:
使用公共IP作为broadcast_address以允许跨区域连接。（因此，您应该将集群seed地址设置为公共IP。）您将需要打开公共IP防火墙上的storage_port或ssl_storage_port。（对于区域内流量，Cassandra将在建立连接后切换到专用IP）。
RackInferringSnitch:
接近性由机架和数据中心确定，假定它们分别对应于每个节点的IP地址的第3和第2个八位字节。除非这种情况符合您的部署约定，这最好用作编写自定义Snitch类的示例，并以此精神提供。
您可以使用自定义Snitch，将其设置为snitch的完整类名，这将被假定在您的类路径上。
默认值: SimpleSnitch
dynamic_snitch_update_interval_in_ms
控制执行主机分数计算的较耗费资源部分的频率
默认值: 100
dynamic_snitch_reset_interval_in_ms
控制重置所有主机分数的频率，允许坏主机可恢复
默认值: 600000
dynamic_snitch_badness_threshold
如果设置大于零并且read_repair_chance <1.0，这将允许副本“锁定”到主机，以便增加缓存容量。坏性阈值将控制被锁定的主机在动态信道将优先于其它副本之前要有多糟糕。这表示为表示百分比的double。 因此，值为0.2意味着Cassandra将继续优选静态snitch值，直到固定主机比最快的20％差。
默认值: 0.1
request_scheduler
request_scheduler - 将其设置为一个实现RequestequestScheduler的类，它将根据特定策略调度传入客户端请求。这对于具有单个Cassandra集群的多租户非常有用。注意：这是专门用于来自客户端的请求，不影响节点间的通信..org.org.apache.cassandra.scheduler.NoScheduler - 没有调度进行到.org.apache.cassandra.scheduler。RoundRobinScheduler - 将客户机请求轮询到具有每个request_scheduler_id的单独队列的节点。 调度程序由如下所述的request_scheduler_options进一步定制。
默认值: org.apache.cassandra.scheduler.NoScheduler
request_scheduler_options
默认情况下，此选项被注释掉。
调度程序选项根据调度程序的类型而有所不同
NoScheduler
没有选项
RoundRobin
throttle_limit
throttle_limit是每个客户端的飞行中请求数。 超出限制的请求将排队等候，直到运行请求可以完成。此处的80值是concurrent_reads + concurrent_writes的两倍。
default_weight
default_weight是可选的，允许覆盖默认值为1。
权重（weights）
权重是可选的，默认为1或覆盖的default_weight。权重转换为在RoundRobin的每次轮转期间基于调度程序ID处理多少请求。
默认值 (复杂选项):
#    throttle_limit: 80
#    default_weight: 5
#    weights:
#      Keyspace1: 1
#      Keyspace2: 5
request_scheduler_id
默认情况下，此选项被注释掉。
request_scheduler_id - 用于执行请求调度的标识符。目前唯一有效的选项是keyspace。
默认值: keyspace
server_encryption_options
启用或禁用节点间加密支持的SSL套接字协议和密码套件的JVM默认值可以使用自定义加密选项进行替换。 除非您有适用于某些设置的策略，或者需要禁用易受攻击的密码或协议以防JVM无法更新，否则不建议这样做。 FIPS兼容设置可以在JVM级别配置，不应涉及更改加密设置.注意无自定义加密选项 此时可用的节点选项有：all，none，dc，rack。
如果设置为dc cassandra将加密DC之间的流量如果设置为rack cassandra将加密机架之间的流量。
这些选项中使用的密码必须与生成密钥库和信任库时使用的密码相匹配。  
默认值 (复杂选项):
internode_encryption: none
keystore: conf/.keystore
keystore_password: cassandra
truststore: conf/.truststore
truststore_password: cassandra
# More advanced defaults below:
# protocol: TLS
# algorithm: SunX509
# store_type: JKS
# cipher_suites: [TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]
# require_client_auth: false
# require_endpoint_verification: false
client_encryption_options
启用或禁用客户端/服务器加密。
默认值 (复杂选项):
enabled: false
# If enabled and optional is set to true encrypted and unencrypted connections are handled.
optional: false
keystore: conf/.keystore
keystore_password: cassandra
# require_client_auth: false
# Set trustore and truststore_password if require_client_auth is true
# truststore: conf/.truststore
# truststore_password: cassandra
# More advanced defaults below:
# protocol: TLS
# algorithm: SunX509
# store_type: JKS
# cipher_suites: [TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]
internode_compression
internode_compression控制节点之间的流量是否被压缩。 可以是:
all
所有流量都被压缩
dc
不同数据中心之间的流量被压缩
none
没有压缩。
默认值: dc
inter_dc_tcp_nodelay
为dc间通信启用或禁用tcp_nodelay。 禁用它将导致发送更大（但更少）的网络数据包，从而减少TCP协议本身的开销，如果您阻止跨数据中心响应，则以增加延迟为代价。
默认值: false
tracetype_query_ttl
TTL用于在记录修复过程期间使用的不同跟踪类型。
默认值: 86400
tracetype_repair_ttl
默认值: 604800
gc_log_threshold_in_ms
默认情况下，此选项被注释掉。
默认情况下，Cassandra在INFO级别记录大于200毫秒的GC暂停此阈值可以调整，以便在必要时最小化记录
默认值: 200
enable_user_defined_functions
如果取消设置，则大于gc_log_threshold_in_ms的所有GC暂停将以INFO级别记录。默认情况下禁用UDF（用户定义的函数）。 从Cassandra 3.0有一个沙箱，应该防止恶意代码的执行。
默认值: false
enable_scripted_user_defined_functions
启用脚本化UDF（JavaScript UDF）。 如果enable_user_defined_functions为true，则始终启用Java UDF。 启用此选项可以使用具有“language javascript”的UDF或任何自定义JSR-223提供程序。 如果enable_user_defined_functions为false，此选项不起作用。
默认值: false
windows_timer_interval
默认Windows内核定时器和调度分辨率为15.6ms的功率节省。 在Windows上降低此值可以提供更加紧密的延迟和更好的吞吐量，但是某些虚拟化环境可能会将此设置更改为低于系统默认值，从而对性能产生负面影响。 sysinternals的clockres工具可以确认您的系统的默认设置。
默认值: 1
transparent_data_encryption_options
启用静态加密数据（在磁盘上）。 可以插入不同的密钥提供程序，但缺省值从JCE样式的密钥库读取。 单个密钥库可以容纳多个密钥，但是由“key_alias”引用的密钥是唯一用于加密操作的密钥; 以前使用的密钥仍然可以（并且应该！）在密钥库中，并且将用于解密操作（处理密钥旋转的情况）。
强烈建议为您的JDK版本下载并安装Java Cryptography Extension（JCE）无限强制管辖权政策文件。 
目前，只有以下文件类型支持透明数据加密，虽然在未来的cassandra版本中会有更多的文件类型：commitlog，hints。
默认值 (复杂选项):
enabled: false
chunk_length_kb: 64
cipher: AES/CBC/PKCS5Padding
key_alias: testing:1
# CBC IV length for AES needs to be 16 bytes (which is also the default size)
# iv_length: 16
key_provider:
  - class_name: org.apache.cassandra.security.JKSKeyProvider
    parameters:
      - keystore: conf/.keystore
        keystore_password: cassandra
        store_type: JCEKS
        key_password: cassandra
tombstone_warn_threshold
SAFETY THRESHOLDS #
当在分区内或跨分区执行扫描时，我们需要保留在内存中看到的墓碑（tombstone），以便我们可以将它们返回到协调器，协调器将使用它们来确保其他副本也知道已删除的行。 对于生成大量墓碑的工作负载，这可能会导致性能问题，甚至驱散服务器堆。 （ ）如果您了解危险并且想要扫描更多的墓碑，请在此处调整阈值。 这些阈值也可以在运行时使用StorageService mbean进行调整。
默认值 : 1000
tombstone_failure_threshold
默认值 : 100000
batch_size_warn_threshold_in_kb
在超过此值的任何多分区批处理大小上记录WARN。 默认情况下为每批5kb。 应该注意增加此阈值的大小，因为它可能导致节点不稳定。
默认值 : 5
batch_size_fail_threshold_in_kb
超过此值的任何多分区批处理失败。 默认为50kb（10x警告阈值）。
默认值 : 50
unlogged_batch_across_partitions_warn_threshold
跨越比此限制更多的分区时在任何类型不是LOGGED的批次上记录WARN。
默认值 : 10
compaction_large_partition_warning_threshold_mb
在压缩分区大于此值时记录警告
默认值 : 100
gc_warn_threshold_in_ms
GC大于gc_warn_threshold_in_ms的暂停将在WARN级别记录。 根据您的应用程序吞吐量要求调整阈值。默认情况下，Cassandra记录在INFO级别的GC暂停大于200 ms
默认值 : 1000
max_value_size_in_mb
默认情况下，此选项被注释掉。
SSTables中的任何值的最大大小。 早期检测SSTable腐败的安全措施。 任何大于此阈值的值大小将导致将SSTable标记为已损坏。
默认值 : 256
back_pressure_enabled
背压设置＃如果启用，协调器将对发送到副本的每个突变应用下面指定的背压策略，目的是减少重载副本上的压力。
默认值: false
back_pressure_strategy
应用背压策略。 默认实现RateBasedBackPressure采用三个参数：高比率，因子和流类型，并使用传入突变响应和传出突变请求之间的比率。 如果低于高比率，输出突变根据进入速率由给定因子降低而进行速率限制; 如果高于比率，则速率限制增加给定因子; 这样的因子通常最好配置在1和10之间，使用更大的值，以更快的恢复，代价是潜在更多的突变; 根据流类型应用速率限制：如果FAST，它的速率限制在最快的副本的速度，如果SLOW以最慢的速度。 可以添加新策略。 实现者需要实现org.apache.cassandra.NET.BackpressureStrategy并提供一个接受Map <String，Object>的公共构造函数。
```
