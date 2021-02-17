一、前言

- 如果Kong是以集群的状态的运行的，只需要将管理API的请求发送到其中的一个节点中，Kong会自动同步信息到其他的节点。

Kong大概有以下几个管理对象：
- 节点信息
- 服务
- 路由
- 用户
- 插件
- 证书
- SNI
- 上游信息
- 目标

二、节点信息
---
1、查看节点信息

```
curl -s http://192.168.0.184:8001 | python -m json.tool
```

2、查看节点状态

- 主要是显示nginx进程处理连接的情况，以及数据库连接的情况。
- 如果Kong是以集群的方式运行，那么如果要查看其他节点的情况，必须要一个一个访问节点的此接口。
- 因为Kong是基于nginx的，可以直接使用Nginx的监控工具。

```
curl -s http://192.168.0.184:8001/status | python -m json.tool
{
    "database": {
        "reachable": true
    },
    "server": {
        "connections_accepted": 111,
        "connections_active": 1,
        "connections_handled": 111,
        "connections_reading": 0,
        "connections_waiting": 0,
        "connections_writing": 1,
        "total_requests": 64
    }
}
```
- total_requests：客户端请求的总数。
- connections_active：当前活动客户端连接数，包括等待连接。
- connections_accepted：已接受的客户端连接总数。
- connections_handled：已处理连接的总数。通常，参数值与accept相同，除非已达到某些资源限制。
- connections_reading：Kong正在读取请求标头的当前连接数。
- connections_writing：nginx将响应写回客户端的当前连接数。
- connections_waiting：等待请求的当前空闲客户端连接数。
- -s参数表示静默模式，curl将不输入信息，可以不打印不需要关注的信息。

三、服务
---
服务是每一个后端真实接口的抽象，它与路由关联，客户端发起请求，如果路由匹配到了，那么会将这个请求代理到与匹配路由相关联的服务中。

| 参数名 | 类型 | 默认值 | 是否必须 | 说明 |
|-------|------|--------|---------|------|
| name | string | | 否 | 服务名称，全局唯一 |
| protocol | string | http | 是 | 和上游通讯的协议取值http或https |
| host | string | | 是 | 上游服务器的主机 |
| port | int | 80 | 是 | 上游服务器的端口 |
| path | string | | 否 | 上游服务器请求中的路径，必须以/开头 |
| retries | int | 5 | 否 | 代理失败时要执行的重试次数 |
| connect_timeout | int | 60000 | 否 | 与上游连接的超时时间，单位毫秒 |
| write_timeout | int | 60000 | 否 | 向上游发送请求两次连续写操作的超时时间 ，单位毫秒 |
| read_timeout | int | 60000 | 否 | 用于向上游服务器发送请求的两次连续读取操作之间的超时 ，单位毫秒 |

1、添加服务
```
curl -s -X POST --url http://192.168.0.184:8001/services/ \
-d 'name=linuxops_server' \
-d 'protocol=http' \
-d 'host=www.baidu.com'\
| python -m json.tool

{
    "connect_timeout": 60000,
    "created_at": 1537924532,
    "host": "www.baidu.com",
    "id": "27f30248-fef1-4ddc-9fdc-4ca73f354c64",
    "name": "linuxops_server",
    "path": null,
    "port": 80,
    "protocol": "http",
    "read_timeout": 60000,
    "retries": 5,
    "updated_at": 1537924532,
    "write_timeout": 60000
}
```

2、查询所有服务

| 参数名 | 类型 | 默认值 | 是否必须 | 说明 |
|-------|------|--------|---------|------|
| offset | string | 否 | 分页偏移，用于定义列表中的唯一 |
| size | int | 100 | 否 | 每页返回的对象的数量 |

```
curl -s --url http://192.168.0.184:8001/services/?size=1 | python -m json.tool

{
    "data": [
        {
            "connect_timeout": 60000,
            "created_at": 1537986798,
            "host": "www.baidu.com",
            "id": "27f30248-fef1-4ddc-9fdc-4ca73f354c64",
            "name": "linuxops_server",
            "path": null,
            "port": 80,
            "protocol": "http",
            "read_timeout": 60000,
            "retries": 5,
            "updated_at": 1537986798,
            "write_timeout": 60000
        }
    ],
    "next": "/services?offset=WyIyN2YzMDI0OC1mZWYxLTRkZGMtOWZkYy00Y2E3M2YzNTRjNjQiXQ",
    "offset": "WyIyN2YzMDI0OC1mZWYxLTRkZGMtOWZkYy00Y2E3M2YzNTRjNjQiXQ"
}
```
- size的参数来限定每一页的数量，在返回的结果中有两个字段，next表示下一页的端点，offset是本页的偏移。

3、查询单个服务
```
curl -s --url http://192.168.0.184:8001/services/27f30248-fef1-4ddc-9fdc-4ca73f354c64 | python -m json.tool
{
    "connect_timeout": 60000,
    "created_at": 1537986798,
    "host": "www.baidu.com",
    "id": "27f30248-fef1-4ddc-9fdc-4ca73f354c64",
    "name": "linuxops_server",
    "port": 80,
    "protocol": "http",
    "read_timeout": 60000,
    "retries": 5,
    "updated_at": 1537986798,
    "write_timeout": 60000
}
```

4、更新服务
```
curl -s -X PATCH --url http://192.168.0.184:8001/services/linuxops_server \
-d 'name=linuxops_server_patch' \
-d 'protocol=http' \
-d 'host=www.baidu.com' \
 | python -m json.tool

{
    "connect_timeout": 60000,
    "created_at": 1537986798,
    "host": "www.baidu.com",
    "id": "27f30248-fef1-4ddc-9fdc-4ca73f354c64",
    "name": "linuxops_server_patch",
    "path": null,
    "port": 80,
    "protocol": "http",
    "read_timeout": 60000,
    "retries": 5,
    "updated_at": 1537989418,
    "write_timeout": 60000
}
```

5、更新或者创建服务
```
curl -s -X PUT --url http://192.168.0.184:8001/services/linuxops_server_put \
-d 'name=linuxops_server_patch' \
-d 'protocol=http' \
-d 'host=www.baidu.com' \
 | python -m json.tool

{
    "connect_timeout": 60000,
    "created_at": 1537991524,
    "host": "www.baidu.com",
    "id": "7242306f-3a55-46b5-9cda-cfb6c25a421c",
    "name": "linuxops_server_put",
    "path": null,
    "port": 80,
    "protocol": "http",
    "read_timeout": 60000,
    "retries": 5,
    "updated_at": 1537991524,
    "write_timeout": 60000
}
```

6、删除服务
```
curl -i  -X DELETE --url http://192.168.0.184:8001/services/b6094754-07da-4c31-bb95-0a7caf5e6c0b
```

四、路由
---
路由用来匹配客户端请求的规则，每一个路由都要与一个服务相关联，当一个请求到达Kong的时候，会先给路由匹配，如果匹配成功，那么会将请求转发给服务，服务再去后端请求数据。所以路由是Kong的入口。

| 参数名 | 类型 | 默认值 | 是否必须 | 说明 |
| ------|------|--------|---------|------|
| protocols | string or list | ["http", "https"] | 否 | 此路由允许的协议，取值http或https |
| methods | string or list | null | *否 | 此路由允许的方法 |
| hosts | string or list | null | *否 | 此路由允许的域名 |
| paths | string or list | null | *否 | 此路由匹配的path |
| strip_path | bool | true | 否 | 匹配到path时，是否删除匹配到的前缀 |
| preserve_host | bool | false | 否 | 匹配到hosts时，使用请求头部的值为域名向后端发起请求，请求的头部为"host",例如"host:api.abc.com" |
| service | string | | 是 | 关联的服务id。 |

1、添加路由
```
curl -s -X POST --url http://192.168.0.184:8001/routes \
-d 'protocols=http' \
-d 'methods=GET'  \
-d 'paths=/weather' \
-d 'service.id=43921b23-65fc-4722-a4e0-99bf84e26593' \
| python -m json.tool

{
    "created_at": 1538089234,
    "hosts": null,
    "id": "cce1a279-d05a-4faa-8c10-1f9d27b881c9",
    "methods": [
        "GET"
    ],
    "paths": [
        "/weather"
    ],
    "preserve_host": false,
    "protocols": [
        "http"
    ],
    "regex_priority": 0,
    "service": {
        "id": "43921b23-65fc-4722-a4e0-99bf84e26593"
    },
    "strip_path": true,
    "updated_at": 1538089234
}
```
- 创建了一个路由并且关联了一个服务，在创建路由的时候并没有指定hosts，路由匹配到host的时候会允许所有，因为默认值为null。当然如果不指定其他的也是一样的。
- 值得注意的是，methods，hosts，paths这三个参数必须要指定一个，否则无法创建路由。


2、查询所有路由

| 参数名 | 类型 | 默认值 | 是否必须 | 说明 |
|--------|-----|--------|---------|------|
| offset | string | 否 | 分页偏移，用于定义列表中的唯一 |
| size | int | 100 | 否 | 每页返回的对象的数量 |

```
curl -s --url http://192.168.0.184:8001/routes/?size=1 | python -m json.tool

{
    "data": [
        {
            "created_at": 1538004899,
            "hosts": [],
            "id": "cce1a279-d05a-4faa-8c10-1f9d27b881c9",
            "methods": [
                "GET",
                "POST"
            ],
            "paths": [],
            "preserve_host": false,
            "protocols": [
                "http",
                "https"
            ],
            "regex_priority": 0,
            "service": {
                "id": "43921b23-65fc-4722-a4e0-99bf84e26593"
            },
            "strip_path": true,
            "updated_at": 1538071225
        }
    ],
    "next": "/routes?offset=WyIxOTM3NzY4MS1iYTFjLTQzZGMtOWViNi1mZjExNzQ2N2NlOTYiXQ",
    "offset": "WyIxOTM3NzY4MS1iYTFjLTQzZGMtOWViNi1mZjExNzQ2N2NlOTYiXQ"
}
```

3、查看单个路由
```
curl -s http://192.168.0.184:8001/routes/cce1a279-d05a-4faa-8c10-1f9d27b881c9 | python -m json.tool
{
    "created_at": 1538089668,
    "id": "cce1a279-d05a-4faa-8c10-1f9d27b881c9",
    "paths": [
        "/weather"
    ],
    "preserve_host": false,
    "protocols": [
        "http",
        "https"
    ],
    "regex_priority": 0,
    "service": {
        "id": "43921b23-65fc-4722-a4e0-99bf84e26593"
    },
    "strip_path": true,
    "updated_at": 1538089668
}
```

4、更新路由
```
curl -s -X PATCH --url http://192.168.0.184:8001/routes/cce1a279-d05a-4faa-8c10-1f9d27b881c9 \
-d 'protocols=http' \
-d 'methods=GET'  \
-d 'paths=/weather' \
-d 'service.id=43921b23-65fc-4722-a4e0-99bf84e26593' \
| python -m json.tool

{
    "created_at": 1538089668,
    "hosts": null,
    "id": "cce1a279-d05a-4faa-8c10-1f9d27b881c9",
    "methods": [
        "GET"
    ],
    "paths": [
        "/weather"
    ],
    "preserve_host": false,
    "protocols": [
        "http"
    ],
    "regex_priority": 0,
    "service": {
        "id": "43921b23-65fc-4722-a4e0-99bf84e26593"
    },
    "strip_path": true,
    "updated_at": 1538090658
}
```

5、更新或者添加路由

```
curl -s -X PUT --url http://192.168.0.184:8001/routes/6c6b7863-9a05-4d51-bf7e-2962c1d6b0e6 \
-d 'protocols=http' \
-d 'methods=GET'  \
-d 'paths=/weather' \
-d 'service.id=43921b23-65fc-4722-a4e0-99bf84e26593' \
| python -m json.tool

{
    "created_at": 1538091038,
    "hosts": null,
    "id": "6c6b7863-9a05-4d51-bf7e-2962c1d6b0e6",
    "methods": [
        "GET"
    ],
    "paths": [
        "/weather"
    ],
    "preserve_host": false,
    "protocols": [
        "http"
    ],
    "regex_priority": 0,
    "service": {
        "id": "43921b23-65fc-4722-a4e0-99bf84e26593"
    },
    "strip_path": true,
    "updated_at": 1538091038
}
```

6、查看和服务关联的路由
```
curl -s http://192.168.0.184:8001/services/wechat/routes | python -m json.tool

{
    "data": [
        {
            "created_at": 1538089623,
            "id": "cdfee2bc-a5eb-4f80-96f5-64bfe3b85507",
            "methods": [
                "GET"
            ],
            "preserve_host": false,
            "protocols": [
                "http",
                "https"
            ],
            "regex_priority": 0,
            "service": {
                "id": "43921b23-65fc-4722-a4e0-99bf84e26593"
            },
            "strip_path": true,
            "updated_at": 1538089623
        },
        {
            "created_at": 1538089397,
            "id": "f8ef8876-9681-4629-a2ee-d7fac8a8094a",
            "methods": [
                "GET"
            ],
            "paths": [
                "/weather"
            ],
            "preserve_host": false,
            "protocols": [
                "http",
                "https"
            ],
            "regex_priority": 0,
            "service": {
                "id": "43921b23-65fc-4722-a4e0-99bf84e26593"
            },
            "strip_path": true,
            "updated_at": 1538089397
        }
    ],
    "next": null
}
```

7、查看和路由关联的服务
```
curl -s http://192.168.0.184:8001/routes/f8ef8876-9681-4629-a2ee-d7fac8a8094a/service | python -m json.tool

{
    "connect_timeout": 60000,
    "created_at": 1538000258,
    "host": "t.weather.sojson.com",
    "id": "43921b23-65fc-4722-a4e0-99bf84e26593",
    "name": "wechat",
    "path": "/api/weather/city/",
    "port": 80,
    "protocol": "http",
    "read_timeout": 60000,
    "retries": 5,
    "updated_at": 1538005796,
    "write_timeout": 60000
}
```

8、删除路由
```
curl -s http://192.168.0.184:8001/routes/f8ef8876-9681-4629-a2ee-d7fac8a8094a/service | python -m json.tool
```

五、用户
---
1、添加用户

| 参数名 | 类型 | 默认值 | 是否必须 | 说明 |
|-------|------|--------|---------|-------|
| username | string | null | *否 | 全局唯一的用户名 |
| custom_id | string | null | *否 | 全局唯一的用户ID |

```
curl -s -X POST --url http://192.168.0.184:8001/consumers  -d 'username=linuxops' | python -m json.tool
{
    "created_at": 1538126090,
    "custom_id": null,
    "id": "376a9ccf-7d10-45a7-a956-77eb129d8ff0",
    "username": "linuxops"
}
```
- 指定了一个username来创建一个用户，从返回值看出，如果没有指定参数，那么默认值为空。
- 在调用这个接口，必须要指定username 和 custom_id其中一个参数，不能同时不指定。


2、查询所有用户

| 参数名 | 类型 | 默认值 | 是否必须 | 说明 |
|-------|------|--------|---------|------|
| offset | string | | 否 | 分页偏移，用于定义列表中的唯一 |
| size | int | 100 | 否 | 每页返回的对象的数量 |

```
curl -s http://192.168.0.184:8001/consumers?size=1 | python -m json.tool

{
    "data": [
        {
            "created_at": 1538126090,
            "custom_id": null,
            "id": "376a9ccf-7d10-45a7-a956-77eb129d8ff0",
            "username": "linuxops"
        }
    ],
    "next": "/consumers?offset=WyIzNzZhOWNjZi03ZDEwLTQ1YTctYTk1Ni03N2ViMTI5ZDhmZjAiXQ",
    "offset": "WyIzNzZhOWNjZi03ZDEwLTQ1YTctYTk1Ni03N2ViMTI5ZDhmZjAiXQ"
}
```

3、查询用户
```
curl -s http://192.168.0.184:8001/consumers/linuxops | python -m json.tool

{
    "created_at": 1538126090,
    "id": "376a9ccf-7d10-45a7-a956-77eb129d8ff0",
    "username": "linuxops"
}
```


4、更新用户
```
curl -s -X PATCH --url http://192.168.0.184:8001/consumers/376a9ccf-7d10-45a7-a956-77eb129d8ff0 -d "custom_id=linuxops123456789" | python -m json.tool

{
    "created_at": 1538126090,
    "custom_id": "linuxops123456789",
    "id": "376a9ccf-7d10-45a7-a956-77eb129d8ff0",
    "username": "linuxops"
}
```

5、更新或者添加用户
```
curl -s -X PUT --url http://192.168.0.184:8001/consumers/376a9ccf-7d10-45a7-a956-77eb129d8ff0 -d "custom_id=linuxops123456789" | python -m json.tool

{
    "created_at": 1538127246,
    "custom_id": "linuxops123456789",
    "id": "376a9ccf-7d10-45a7-a956-77eb129d8ff0",
    "username": null
}
```

6、删除用户

```
curl -i -X DELETE --url http://192.168.0.184:8001/consumers/376a9ccf-7d10-45a7-a956-77eb129d8ff0 
```

六、插件
---

可以通过配置指定某个服务或者路由或者用户启用某个插，插件始终只运行一次，所以对于不同的实体配置相同插件时就有优先级的概念。

多次配置插件的优先级如下：
- 在以下组合上配置的插件：路由，服务和使用者。 （消费者意味着必须对请求进行身份验证）。
- 在Route和Consumer的组合上配置的插件。 （消费者意味着必须对请求进行身份验证）。
- 在服务和使用者的组合上配置的插件。 （消费者意味着必须对请求进行身份验证）。
- 在路由和服务的组合上配置的插件。
- 在Consumer上配置的插件。 （消费者意味着必须对请求进行身份验证）。
- 在路由上配置的插件。
- 在服务上配置的插件。
- 配置为全局运行的插件。

1、添加插件

可以通过以下几种不同的方式添加插件：
- 对于每个Service/Route和consumer。不要设置consumer_id和设置service_id或route_id。
- 适用于每个Service/Route和特定consumer。只有设定consumer_id。
- 适用于每个consumer和特定Service。仅设置service_id（警告：某些插件只允许设置route_id）
- 对于每个consumer和特定的Route。仅设置route_id（警告：某些插件只允许设置service_id）
- 对于特定的Service/Route和consumer。设置两个service_id/ route_id和consumer_id。

并非所有插件都允许指定consumer_id。检查插件文档。

| 参数名 | 类型 | 默认值 | 是否必须 | 说明 |
|--------|------|-------|----------|------|
| name | string | | 是 | 要添加的插件的名称。目前，插件必须分别安装在每个Kong实例中。 |
| consumer_id | string | null | 否 | 使用者的唯一标识符，用于覆盖传入请求中此特定使用者的现有设置。 |
| service_id | string | null | 否 | 服务的唯一标识符，用于覆盖传入请求中此特定服务的现有设置。 |
| route_id | string | null | 否 | 路由的唯一标识符，它覆盖传入请求中此特定路由的现有设置。 |
| config.{property} | string | null | 否 | 插件的配置属性，可以在Kong Hub的插件文档页面找到。 |
| enabled | bool | true | 否 | 是否应用插件。默认值：true。 |

```
curl -s -X POST --url http://192.168.0.184:8001/plugins/ \
-d 'name=basic-auth' \
-d 'route_id=d1a10507-ea15-4c61-9d8c-7f10ebc79ecb' \
| python -m json.tool

{
    "config": {
        "anonymous": "",
        "hide_credentials": false
    },
    "created_at": 1540102452000,
    "enabled": true,
    "id": "900aeaa3-0a47-49a1-9fea-649e6c90ab7f",
    "name": "basic-auth",
    "route_id": "d1a10507-ea15-4c61-9d8c-7f10ebc79ecb"
}
```
- 在route上添加了basic-auth插件，这个插件用于认证，通过http的头部带入用户名和密码信息进行认证。

启用插件后，需要对user设置好basic-auth的凭证,否则访问不了，并且返回如下信息
```
{
"message": "Unauthorized"
}
```

2、查询所有插件

| 参数名 | 类型 | 默认值 | 是否必须 | 说明 |
|--------|-----|--------|---------|------|
| id | string | | 否 | 通过id查询 |
| name | string | | 否 | 通过name查 |
| service_id | string | | 否 | 通过service_id查 |
| route_id | string | | 否 | 通过iroute_id查 |
| consumer_id | string | | 否 | 通过consumer_id查 |
| offset | string | | 否 | 分页偏移，用于定义列表中的唯一 |
| size | int | 100 | 否 | 每页返回的对象的数量 |

```
curl -s --url http://192.168.0.184:8001/plugins/?size=1 | python -m json.tool
{
    "data": [
        {
            "config": {
                "anonymous": "",
                "hide_credentials": false
            },
            "created_at": 1540102452000,
            "enabled": true,
            "id": "900aeaa3-0a47-49a1-9fea-649e6c90ab7f",
            "name": "basic-auth",
            "route_id": "d1a10507-ea15-4c61-9d8c-7f10ebc79ecb"
        }
    ],
    "total": 1
}
```

3、查询单个插件
```
curl -s --url http://192.168.0.184:8001/plugins/900aeaa3-0a47-49a1-9fea-649e6c90ab7f  | python -m json.tool

{
    "config": {
        "anonymous": "",
        "hide_credentials": false
    },
    "created_at": 1540102452000,
    "enabled": true,
    "id": "900aeaa3-0a47-49a1-9fea-649e6c90ab7f",
    "name": "basic-auth",
    "route_id": "d1a10507-ea15-4c61-9d8c-7f10ebc79ecb"
}
```

4、更新插件
```
curl -s -X PATCH --url http://192.168.0.184:8001/plugins/900aeaa3-0a47-49a1-9fea-649e6c90ab7f -d "service_id=da4dce88-4df3-4723-b544-b11b27184e97" | python -m json.tool

{
    "config": {
        "anonymous": "",
        "hide_credentials": false
    },
    "created_at": 1540102452000,
    "enabled": true,
    "id": "900aeaa3-0a47-49a1-9fea-649e6c90ab7f",
    "name": "basic-auth",
    "route_id": "d1a10507-ea15-4c61-9d8c-7f10ebc79ecb",
    "service_id": "da4dce88-4df3-4723-b544-b11b27184e97"
}
```
在上面的请求示例中，我更新了这个插件，原本只针对route启用的，现在又增加了对service生效，由此看出，一个插件是可以对多个实体生效的（前提是插件本身要支持此实体生效），因为插件只会在请求的生命周期中运行一次，所以对多个实体启用同一个插件会受到优先级的限制。

5、更新或添加插件
```
curl -s -X PUT --url http://192.168.0.184:8001/plugins/900aeaa3-0a47-49a1-9fea-649e6c90ab7f -d "service_id=da4dce88-4df3-4723-b544-b11b27184e97" | python -m json.tool

{
    "config": {
        "anonymous": "",
        "hide_credentials": false
    },
    "created_at": 1540102452000,
    "enabled": true,
    "id": "900aeaa3-0a47-49a1-9fea-649e6c90ab7f",
    "name": "basic-auth",
    "route_id": "d1a10507-ea15-4c61-9d8c-7f10ebc79ecb",
    "service_id": "da4dce88-4df3-4723-b544-b11b27184e97"
}
```

6、删除插件
```
curl -s -X DELETE --url http://192.168.0.184:8001/plugins/900aeaa3-0a47-49a1-9fea-649e6c90ab7f | python -m json.tool
```

7、查询已启用的插件
```
curl -s -X GET --url http://192.168.0.184:8001/plugins/enabled | python -m json.tool


{
    "enabled_plugins": [
        "response-transformer",
        "oauth2",
        "acl",
        "correlation-id",
        "pre-function",
        "jwt",
        "cors",
        "ip-restriction",
        "basic-auth",
        "key-auth",
        "rate-limiting",
        "request-transformer",
        "http-log",
        "file-log",
        "hmac-auth",
        "ldap-auth",
        "datadog",
        "tcp-log",
        "zipkin",
        "post-function",
        "request-size-limiting",
        "bot-detection",
        "syslog",
        "loggly",
        "azure-functions",
        "udp-log",
        "response-ratelimiting",
        "aws-lambda",
        "statsd",
        "prometheus",
        "request-termination"
    ]
}
```
- 只有已经启用的插件才能被应用在实体上，在kong集群中，插件启用的情况要一致。

8、检索插件架构
```
curl -s -X GET --url http://192.168.0.184:8001/plugins/schema/basic-auth | python -m json.tool

{
    "fields": {
        "anonymous": {
            "default": "",
            "func": "function",
            "type": "string"
        },
        "hide_credentials": {
            "default": false,
            "type": "boolean"
        }
    },
    "no_consumer": true
}
```
