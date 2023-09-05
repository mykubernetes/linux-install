# setup模块
- ansible的setup模块是一个特殊的模块，用于收集有关远程主机的系统和环境信息。它可以自动运行在每个目标主机上，收集各种事实（facts），例如操作系统类型、发行版、内核版本、网络接口、硬件信息等等。

| 关键字 | 说明 |
|-------|-----|
| ansible_nodename | 节点名 |
| ansible_fqdn | FQDN名 |
| ansible_hostname | 主机短名称 |
| ansible_domain | 主机域名后缀 |
| ansible_memtotal_mb | 总物理内存 |
| ansible_swaptotal_mb | SWAP总大小 |
| ansible_processor | CPU信息 |
| ansible_processor_cores | CPU核心数量 |
| ansible_processor_vcpus | CPU逻辑核心数量 |
| ansible_all_ipv4_addresses | 有所IPV4地址 |
| ansible_all_ipv6_addresses | 所有IPV6地址 |
| ansible_default_ipv4 | 默认网关的网卡配置信息 |
| ansible_eth2 | 具体某张网卡信息 |
| ansible_dns | DNS设置信 |
| ansible_architecture | 系统架构 |
| ansible_machine | 主机类型 |
| ansible_kernel | 内核版本 |
| ansible_distribution | 发行版本 |
| ansible_distribution_major_version | 操作系统主版本号 |
| ansible_distribution_release | 发行版名称 |
| ansible_distribution_version | 完整版本号 |
| ansible_pkg_mgr | 软件包管理方式 |
| ansible_service_mgr | 进行服务方式 |
| ansible_os_family | 家族系列 |
| ansible_cmdline | 内核启动参数 |
| ansible_selinux | SElinux状态 |
| ansible_env | 当前环境变量参数 |
| ansible_date_time | 时间相关 |
| ansible_python_version | python版本 |
| ansible_lvm | LVM卷相关信息 |
| ansible_mounts | 所有挂载点 |
| ansible_device_links | 所有挂载的设备的UUID和卷标名 |
| ansible_devices | 所有/dev/下的正在使用的设备的信息 |
| ansible_user_dir | 执行用户的家目录 |
| ansible_user_gecos | 执行用户的描述信息 |
| ansible_user_gid | 执行用户的的GID |
| ansible_user_id | 执行用户的的用户名 |
| ansible_user_shell | 执行用户的shell类型 |
| ansible_user_uid | 执行用户的UID |


```
常用选项：
filter #只返回与这个shell样式(fnmatch)通配符匹配的事实。
使用方法：
ansible all -m setup  -a 'filter="*mem*"'
对比于free -m
ansible all -m shell -a 'free -m'
```

```
- `all`: 收集所有的信息（默认选项）。
- `all_ipv4_addresses`: 收集所有的IPv4地址。
- `all_ipv6_addresses`: 收集所有的IPv6地址。
- `apparmor`: 收集AppArmor配置。
- `architecture`: 收集系统架构信息。
- `caps`: 收集系统能力信息。
- `chroot`: 收集当前是否处于chroot环境。
- `cmdline`: 收集内核启动参数。
- `date_time`: 收集日期和时间信息。
- `default_ipv4`: 收集默认的IPv4地址。
- `default_ipv6`: 收集默认的IPv6地址。
- `devices`: 收集设备信息。
- `distribution`: 收集发行版信息。
- `distribution_major_version`: 收集发行版的主要版本号。
- `distribution_release`: 收集发行版的发布版本。
- `distribution_version`: 收集发行版的完整版本号。
- `dns`: 收集DNS配置。
- `effective_group_ids`: 收集有效的组ID。
- `effective_user_id`: 收集有效的用户ID。
- `env`: 收集环境变量。
- `facter`: 通过Facter收集事实。
- `fibre_channel_wwn`: 收集光纤通道WWN（World Wide Name）。
- `fips`: 收集FIPS模式信息。
- `hardware`: 收集硬件信息。
- `interfaces`: 收集网络接口信息。
- `is_chroot`: 收集当前是否处于chroot环境。
- `iscsi`: 收集iSCSI配置。
- `kernel`: 收集内核信息。
- `kernel_version`: 收集内核版本。
- `local`: 收集本地信息。
- `lsb`: 收集LSB（Linux Standard Base）信息。
- `machine`: 收集处理器架构信息。
- `machine_id`: 收集机器ID。
- `mounts`: 收集挂载信息。
- `network`: 收集网络信息。
- `nvme`: 收集NVMe（Non-Volatile Memory Express）设备信息。
- `ohai`: 通过Ohai收集事实。
- `os_family`: 收集操作系统家族信息。
- `pkg_mgr`: 收集软件包管理器信息。
- `platform`: 收集平台信息。
- `processor`: 收集处理器信息。
- `processor_cores`: 收集处理器核心数量。
- `processor_count`: 收集处理器数量。
- `python`: 收集Python信息。
- `python_version`: 收集Python版本。
- `real_user_id`: 收集真实用户ID。
- `selinux`: 收集SELinux配置。
- `service_mgr`: 收集服务管理器信息。
- `ssh_host_key_dsa_public`: 收集SSH DSA公钥。
- `ssh_host_key_ecdsa_public`: 收集SSH ECDSA公钥。
- `ssh_host_key_ed25519_public`: 收集SSH Ed25519公钥。
- `ssh_host_key_rsa_public`: 收集SSH RSA公钥。
- `ssh_host_pub_keys`: 收集SSH主机公钥。
- `ssh_pub_keys`: 收集SSH用户公钥。
- `system`: 收集系统信息。
- `system_capabilities`: 收集系统能力信息。
- `system_capabilities_enforced`: 收集系统能力强制信息。
- `user`: 收集用户信息。
- `user_dir`: 收集用户目录。
- `user_gecos`: 收集用户GECOS信息。
- `user_gid`: 收集用户组ID。
- `user_id`: 收集用户ID。
- `user_shell`: 收集用户Shell。
- `user_uid`: 收集用户UID。
- `virtual`: 收集虚拟化信息。
- `virtualization_role`: 收集虚拟化角色。
- `virtualization_type`: 收集虚拟化类型。
```

