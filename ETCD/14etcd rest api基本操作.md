
向该集群的 discovery 发送一个 GET 请求, 查看 member 组成。
```
curl -X GET http://192.168.99.101:2379/e77afb997af5a84983baa98fd42cf12f
返回
    {
        "action": "get", 
        "node": {
            "key": "/_etcd/registry/e77afb997af5a84983baa98fd42cf12f", 
            "dir": true, 
            "nodes": [
                {
                    "key": "/_etcd/registry/e77afb997af5a84983baa98fd42cf12f/4eb2dcba58da982f", 
                    "value": "etcd0=http://192.168.99.101:2380", 
                    "modifiedIndex": 1113260929, 
                    "createdIndex": 1113260929
                }, 
                {
                    "key": "/_etcd/registry/e77afb997af5a84983baa98fd42cf12f/aa5569b385caf33b", 
                    "value": "etcd2=http://192.168.99.103:2380", 
                    "modifiedIndex": 1113261715, 
                    "createdIndex": 1113261715
                }, 
                {
                    "key": "/_etcd/registry/e77afb997af5a84983baa98fd42cf12f/f84fe4a4e816e778", 
                    "value": "etcd1=http://192.168.99.102:2380", 
                    "modifiedIndex": 1113261726, 
                    "createdIndex": 1113261726
                }
            ], 
            "modifiedIndex": 1113260647, 
            "createdIndex": 1113260647
        }
    }
```
- 从结果中可以发现，etcd1 的节点的 key 为 f84fe4a4e816e778。

2、向 discovery 发送一个 DELETE 请求, 删除该节点 member
```
curl -X DELETE http://10.127.3.110:8087/e77afb997af5a84983baa98fd42cf12f/f84fe4a4e816e778
```


# 操作

## 查看版本
```
curl http://192.168.99.101:2379/version

返回
{"etcdserver":"2.3.6","etcdcluster":"2.3.0"}
```

## 查看键
```
curl http://192.168.99.101:2379/v2/keys

返回
{"action":"get","node":{"dir":true}}
```

## 创建键值

put方法如果key之前存在，则默认会先删除，再新建一个key。如果想要直接update，则追加 -d prevExist=true，但是加了这个参数，如果key之前不存在会报错。
```
curl http://192.168.99.101:2379/v2/keys/hello -XPUT -d value="world"

返回
    {
        "action": "set", 
        "node": {
            "key": "/hello", 
            "value": "world", 
            "modifiedIndex": 8, 
            "createdIndex": 8
        }
    }
```

## 创建目录
```
curl http://192.168.99.101:2379/v2/keys/dir -XPUT -d dir=true

返回
    {
        "action": "set", 
        "node": {
            "key": "/dir", 
            "dir": true, 
            "modifiedIndex": 9, 
            "createdIndex": 9
        }
    }
```

## 查看键
```
curl http://192.168.99.101:2379/v2/keys

返回
    {
        "action": "get", 
        "node": {
            "dir": true, 
            "nodes": [
                {
                    "key": "/hello", 
                    "value": "world", 
                    "modifiedIndex": 8, 
                    "createdIndex": 8
                }, 
                {
                    "key": "/dir", 
                    "dir": true, 
                    "modifiedIndex": 9, 
                    "createdIndex": 9
                }
            ]
        }
    }
```

## 创建带ttl的键值

- 单位为秒
```
curl http://192.168.99.101:2379/v2/keys/ttlvar -XPUT -d value="ttl_value" -d ttl=10

返回
    {
        "action": "set", 
        "node": {
            "key": "/ttlvar", 
            "value": "ttl_value", 
            "expiration": "2016-06-04T13:11:00.406180341Z", 
            "ttl": 10, 
            "modifiedIndex": 10, 
            "createdIndex": 10
        }
    }
```

## 创建有序键值
```
curl http://192.168.99.101:2379/v2/keys/seqvar -XPOST -d value="seq1"
curl http://192.168.99.101:2379/v2/keys/seqvar -XPOST -d value="seq2"
curl http://192.168.99.101:2379/v2/keys/seqvar -XPOST -d value="seq3"

curl http://192.168.99.101:2379/v2/keys/seqvar

返回
    {
        "action": "get", 
        "node": {
            "key": "/seqvar", 
            "dir": true, 
            "nodes": [
                {
                    "key": "/seqvar/00000000000000000012", 
                    "value": "seq1", 
                    "modifiedIndex": 12, 
                    "createdIndex": 12
                }, 
                {
                    "key": "/seqvar/00000000000000000013", 
                    "value": "seq2", 
                    "modifiedIndex": 13, 
                    "createdIndex": 13
                }, 
                {
                    "key": "/seqvar/00000000000000000014", 
                    "value": "seq3", 
                    "modifiedIndex": 14, 
                    "createdIndex": 14
                }
            ], 
            "modifiedIndex": 12, 
            "createdIndex": 12
        }
    }
```

## 删除指定的键
```
curl http://192.168.99.101:2379/v2/keys/for_delete -XPUT -d value="fordelete"
curl http://192.168.99.101:2379/v2/keys/
curl http://192.168.99.101:2379/v2/keys/for_delete -XDELETE
curl http://192.168.99.101:2379/v2/keys/

返回
    {
        "action": "delete", 
        "node": {
            "key": "/for_delete", 
            "modifiedIndex": 16, 
            "createdIndex": 15
        }, 
        "prevNode": {
            "key": "/for_delete", 
            "value": "fordelete", 
            "modifiedIndex": 15, 
            "createdIndex": 15
        }
    }
```

## 成员管理

列出所有集群成员
```
curl http://192.168.99.101:2379/v2/members

返回
    {
        "members": [
            {
                "id": "4eb2dcba58da982f", 
                "name": "etcd0", 
                "peerURLs": [
                    "http://192.168.99.101:2380"
                ], 
                "clientURLs": [
                    "http://192.168.99.101:2379", 
                    "http://192.168.99.101:4001"
                ]
            }, 
            {
                "id": "aa5569b385caf33b", 
                "name": "etcd2", 
                "peerURLs": [
                    "http://192.168.99.103:2380"
                ], 
                "clientURLs": [
                    "http://192.168.99.103:2379", 
                    "http://192.168.99.103:4001"
                ]
            }, 
            {
                "id": "f84fe4a4e816e778", 
                "name": "etcd1", 
                "peerURLs": [
                    "http://192.168.99.102:2380"
                ], 
                "clientURLs": [
                    "http://192.168.99.102:2379", 
                    "http://192.168.99.102:4001"
                ]
            }
        ]
    }
```

## 统计信息

查看leader
```
curl http://192.168.99.101:2379/v2/stats/leader

返回
    {
        "leader": "4eb2dcba58da982f", 
        "followers": {
            "aa5569b385caf33b": {
                "latency": {
                    "current": 0.001687, 
                    "average": 0.0026333315088053265, 
                    "standardDeviation": 0.0082522530707236, 
                    "minimum": 0.000508, 
                    "maximum": 0.184366
                }, 
                "counts": {
                    "fail": 0, 
                    "success": 8404
                }
            }, 
            "f84fe4a4e816e778": {
                "latency": {
                    "current": 0.001158, 
                    "average": 0.017216567181926247, 
                    "standardDeviation": 1.236027691414708, 
                    "minimum": 0.000493, 
                    "maximum": 113.333953
                }, 
                "counts": {
                    "fail": 0, 
                    "success": 8410
                }
            }
        }
    }
```

## 节点自身信息
```
curl http://192.168.99.101:2379/v2/stats/self

返回
    {
        "name": "etcd0", 
        "id": "4eb2dcba58da982f", 
        "state": "StateLeader", 
        "startTime": "2016-06-04T12:51:22.901345036Z", 
        "leaderInfo": {
            "leader": "4eb2dcba58da982f", 
            "uptime": "28m29.401994375s", 
            "startTime": "2016-06-04T12:51:23.406751734Z"
        }, 
        "recvAppendRequestCnt": 0, 
        "sendAppendRequestCnt": 17544, 
        "sendPkgRate": 10.52589669646476, 
        "sendBandwidthRate": 746.7071116472099
    }
```

## 查看集群运行状态
```
curl http://192.168.99.101:2379/v2/stats/store

返回
    {
        "getsSuccess": 7, 
        "getsFail": 16, 
        "setsSuccess": 8, 
        "setsFail": 0, 
        "deleteSuccess": 1, 
        "deleteFail": 0, 
        "updateSuccess": 0, 
        "updateFail": 0, 
        "createSuccess": 6, 
        "createFail": 0, 
        "compareAndSwapSuccess": 0, 
        "compareAndSwapFail": 0, 
        "compareAndDeleteSuccess": 0, 
        "compareAndDeleteFail": 0, 
        "expireCount": 1, 
        "watchers": 0
    }
```


# V3版本，注意在V3版本中所有的key和value都必须转换为base64编码然后才可以存储
```
# foo is 'Zm9v' in Base64
# bar is 'YmFy' in Base64

# 创建键值对 foo:bar
# curl -L http://127.0.0.1:2379/v3beta/kv/put -X POST -d '{"key": "Zm9v", "value": "YmFy"}'

# 查看键值对 foo
# curl -L http://127.0.0.1:2379/v3beta/kv/range -X POST -d '{"key": "Zm9v"}' 
```

```
{
  "consumes": [
    "application/json"
  ],
  "produces": [
    "application/json"
  ],
  "schemes": [
    "http",
    "https"
  ],
  "swagger": "2.0",
  "info": {
    "title": "etcdserver/etcdserverpb/rpc.proto",
    "version": "version not set"
  },
  "paths": {
    "/v3/auth/authenticate": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "Authenticate processes an authenticate request.",
        "operationId": "Authenticate",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthenticateRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthenticateResponse"
            }
          }
        }
      }
    },
    "/v3/auth/disable": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "AuthDisable disables authentication.",
        "operationId": "AuthDisable",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthDisableRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthDisableResponse"
            }
          }
        }
      }
    },
    "/v3/auth/enable": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "AuthEnable enables authentication.",
        "operationId": "AuthEnable",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthEnableRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthEnableResponse"
            }
          }
        }
      }
    },
    "/v3/auth/role/add": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "RoleAdd adds a new role. Role name cannot be empty.",
        "operationId": "RoleAdd",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthRoleAddRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthRoleAddResponse"
            }
          }
        }
      }
    },
    "/v3/auth/role/delete": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "RoleDelete deletes a specified role.",
        "operationId": "RoleDelete",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthRoleDeleteRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthRoleDeleteResponse"
            }
          }
        }
      }
    },
    "/v3/auth/role/get": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "RoleGet gets detailed role information.",
        "operationId": "RoleGet",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthRoleGetRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthRoleGetResponse"
            }
          }
        }
      }
    },
    "/v3/auth/role/grant": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "RoleGrantPermission grants a permission of a specified key or range to a specified role.",
        "operationId": "RoleGrantPermission",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthRoleGrantPermissionRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthRoleGrantPermissionResponse"
            }
          }
        }
      }
    },
    "/v3/auth/role/list": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "RoleList gets lists of all roles.",
        "operationId": "RoleList",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthRoleListRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthRoleListResponse"
            }
          }
        }
      }
    },
    "/v3/auth/role/revoke": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "RoleRevokePermission revokes a key or range permission of a specified role.",
        "operationId": "RoleRevokePermission",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthRoleRevokePermissionRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthRoleRevokePermissionResponse"
            }
          }
        }
      }
    },
    "/v3/auth/user/add": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "UserAdd adds a new user. User name cannot be empty.",
        "operationId": "UserAdd",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserAddRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserAddResponse"
            }
          }
        }
      }
    },
    "/v3/auth/user/changepw": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "UserChangePassword changes the password of a specified user.",
        "operationId": "UserChangePassword",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserChangePasswordRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserChangePasswordResponse"
            }
          }
        }
      }
    },
    "/v3/auth/user/delete": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "UserDelete deletes a specified user.",
        "operationId": "UserDelete",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserDeleteRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserDeleteResponse"
            }
          }
        }
      }
    },
    "/v3/auth/user/get": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "UserGet gets detailed user information.",
        "operationId": "UserGet",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserGetRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserGetResponse"
            }
          }
        }
      }
    },
    "/v3/auth/user/grant": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "UserGrant grants a role to a specified user.",
        "operationId": "UserGrantRole",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserGrantRoleRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserGrantRoleResponse"
            }
          }
        }
      }
    },
    "/v3/auth/user/list": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "UserList gets a list of all users.",
        "operationId": "UserList",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserListRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserListResponse"
            }
          }
        }
      }
    },
    "/v3/auth/user/revoke": {
      "post": {
        "tags": [
          "Auth"
        ],
        "summary": "UserRevokeRole revokes a role of specified user.",
        "operationId": "UserRevokeRole",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserRevokeRoleRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAuthUserRevokeRoleResponse"
            }
          }
        }
      }
    },
    "/v3/cluster/member/add": {
      "post": {
        "tags": [
          "Cluster"
        ],
        "summary": "MemberAdd adds a member into the cluster.",
        "operationId": "MemberAdd",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbMemberAddRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbMemberAddResponse"
            }
          }
        }
      }
    },
    "/v3/cluster/member/list": {
      "post": {
        "tags": [
          "Cluster"
        ],
        "summary": "MemberList lists all the members in the cluster.",
        "operationId": "MemberList",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbMemberListRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbMemberListResponse"
            }
          }
        }
      }
    },
    "/v3/cluster/member/promote": {
      "post": {
        "tags": [
          "Cluster"
        ],
        "summary": "MemberPromote promotes a member from raft learner (non-voting) to raft voting member.",
        "operationId": "MemberPromote",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbMemberPromoteRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbMemberPromoteResponse"
            }
          }
        }
      }
    },
    "/v3/cluster/member/remove": {
      "post": {
        "tags": [
          "Cluster"
        ],
        "summary": "MemberRemove removes an existing member from the cluster.",
        "operationId": "MemberRemove",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbMemberRemoveRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbMemberRemoveResponse"
            }
          }
        }
      }
    },
    "/v3/cluster/member/update": {
      "post": {
        "tags": [
          "Cluster"
        ],
        "summary": "MemberUpdate updates the member configuration.",
        "operationId": "MemberUpdate",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbMemberUpdateRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbMemberUpdateResponse"
            }
          }
        }
      }
    },
    "/v3/kv/compaction": {
      "post": {
        "tags": [
          "KV"
        ],
        "summary": "Compact compacts the event history in the etcd key-value store. The key-value\nstore should be periodically compacted or the event history will continue to grow\nindefinitely.",
        "operationId": "Compact",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbCompactionRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbCompactionResponse"
            }
          }
        }
      }
    },
    "/v3/kv/deleterange": {
      "post": {
        "tags": [
          "KV"
        ],
        "summary": "DeleteRange deletes the given range from the key-value store.\nA delete request increments the revision of the key-value store\nand generates a delete event in the event history for every deleted key.",
        "operationId": "DeleteRange",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbDeleteRangeRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbDeleteRangeResponse"
            }
          }
        }
      }
    },
    "/v3/kv/lease/leases": {
      "post": {
        "tags": [
          "Lease"
        ],
        "summary": "LeaseLeases lists all existing leases.",
        "operationId": "LeaseLeases2",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseLeasesRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseLeasesResponse"
            }
          }
        }
      }
    },
    "/v3/kv/lease/revoke": {
      "post": {
        "tags": [
          "Lease"
        ],
        "summary": "LeaseRevoke revokes a lease. All keys attached to the lease will expire and be deleted.",
        "operationId": "LeaseRevoke2",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseRevokeRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseRevokeResponse"
            }
          }
        }
      }
    },
    "/v3/kv/lease/timetolive": {
      "post": {
        "tags": [
          "Lease"
        ],
        "summary": "LeaseTimeToLive retrieves lease information.",
        "operationId": "LeaseTimeToLive2",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseTimeToLiveRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseTimeToLiveResponse"
            }
          }
        }
      }
    },
    "/v3/kv/put": {
      "post": {
        "tags": [
          "KV"
        ],
        "summary": "Put puts the given key into the key-value store.\nA put request increments the revision of the key-value store\nand generates one event in the event history.",
        "operationId": "Put",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbPutRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbPutResponse"
            }
          }
        }
      }
    },
    "/v3/kv/range": {
      "post": {
        "tags": [
          "KV"
        ],
        "summary": "Range gets the keys in the range from the key-value store.",
        "operationId": "Range",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbRangeRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbRangeResponse"
            }
          }
        }
      }
    },
    "/v3/kv/txn": {
      "post": {
        "tags": [
          "KV"
        ],
        "summary": "Txn processes multiple requests in a single transaction.\nA txn request increments the revision of the key-value store\nand generates events with the same revision for every completed request.\nIt is not allowed to modify the same key several times within one txn.",
        "operationId": "Txn",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbTxnRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbTxnResponse"
            }
          }
        }
      }
    },
    "/v3/lease/grant": {
      "post": {
        "tags": [
          "Lease"
        ],
        "summary": "LeaseGrant creates a lease which expires if the server does not receive a keepAlive\nwithin a given time to live period. All keys attached to the lease will be expired and\ndeleted if the lease expires. Each expired key generates a delete event in the event history.",
        "operationId": "LeaseGrant",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseGrantRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseGrantResponse"
            }
          }
        }
      }
    },
    "/v3/lease/keepalive": {
      "post": {
        "tags": [
          "Lease"
        ],
        "summary": "LeaseKeepAlive keeps the lease alive by streaming keep alive requests from the client\nto the server and streaming keep alive responses from the server to the client.",
        "operationId": "LeaseKeepAlive",
        "parameters": [
          {
            "description": " (streaming inputs)",
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseKeepAliveRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.(streaming responses)",
            "schema": {
              "$ref": "#/x-stream-definitions/etcdserverpbLeaseKeepAliveResponse"
            }
          }
        }
      }
    },
    "/v3/lease/leases": {
      "post": {
        "tags": [
          "Lease"
        ],
        "summary": "LeaseLeases lists all existing leases.",
        "operationId": "LeaseLeases",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseLeasesRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseLeasesResponse"
            }
          }
        }
      }
    },
    "/v3/lease/revoke": {
      "post": {
        "tags": [
          "Lease"
        ],
        "summary": "LeaseRevoke revokes a lease. All keys attached to the lease will expire and be deleted.",
        "operationId": "LeaseRevoke",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseRevokeRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseRevokeResponse"
            }
          }
        }
      }
    },
    "/v3/lease/timetolive": {
      "post": {
        "tags": [
          "Lease"
        ],
        "summary": "LeaseTimeToLive retrieves lease information.",
        "operationId": "LeaseTimeToLive",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseTimeToLiveRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbLeaseTimeToLiveResponse"
            }
          }
        }
      }
    },
    "/v3/maintenance/alarm": {
      "post": {
        "tags": [
          "Maintenance"
        ],
        "summary": "Alarm activates, deactivates, and queries alarms regarding cluster health.",
        "operationId": "Alarm",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbAlarmRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbAlarmResponse"
            }
          }
        }
      }
    },
    "/v3/maintenance/defragment": {
      "post": {
        "tags": [
          "Maintenance"
        ],
        "summary": "Defragment defragments a member's backend database to recover storage space.",
        "operationId": "Defragment",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbDefragmentRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbDefragmentResponse"
            }
          }
        }
      }
    },
    "/v3/maintenance/hash": {
      "post": {
        "tags": [
          "Maintenance"
        ],
        "summary": "HashKV computes the hash of all MVCC keys up to a given revision.\nIt only iterates \"key\" bucket in backend storage.",
        "operationId": "HashKV",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbHashKVRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbHashKVResponse"
            }
          }
        }
      }
    },
    "/v3/maintenance/snapshot": {
      "post": {
        "tags": [
          "Maintenance"
        ],
        "summary": "Snapshot sends a snapshot of the entire backend from a member over a stream to a client.",
        "operationId": "Snapshot",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbSnapshotRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.(streaming responses)",
            "schema": {
              "$ref": "#/x-stream-definitions/etcdserverpbSnapshotResponse"
            }
          }
        }
      }
    },
    "/v3/maintenance/status": {
      "post": {
        "tags": [
          "Maintenance"
        ],
        "summary": "Status gets the status of the member.",
        "operationId": "Status",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbStatusRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbStatusResponse"
            }
          }
        }
      }
    },
    "/v3/maintenance/transfer-leadership": {
      "post": {
        "tags": [
          "Maintenance"
        ],
        "summary": "MoveLeader requests current leader node to transfer its leadership to transferee.",
        "operationId": "MoveLeader",
        "parameters": [
          {
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbMoveLeaderRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.",
            "schema": {
              "$ref": "#/definitions/etcdserverpbMoveLeaderResponse"
            }
          }
        }
      }
    },
    "/v3/watch": {
      "post": {
        "tags": [
          "Watch"
        ],
        "summary": "Watch watches for events happening or that have happened. Both input and output\nare streams; the input stream is for creating and canceling watchers and the output\nstream sends events. One watch RPC can watch on multiple key ranges, streaming events\nfor several watches at once. The entire event history can be watched starting from the\nlast compaction revision.",
        "operationId": "Watch",
        "parameters": [
          {
            "description": " (streaming inputs)",
            "name": "body",
            "in": "body",
            "required": true,
            "schema": {
              "$ref": "#/definitions/etcdserverpbWatchRequest"
            }
          }
        ],
        "responses": {
          "200": {
            "description": "A successful response.(streaming responses)",
            "schema": {
              "$ref": "#/x-stream-definitions/etcdserverpbWatchResponse"
            }
          }
        }
      }
    }
  },
  "definitions": {
    "AlarmRequestAlarmAction": {
      "type": "string",
      "default": "GET",
      "enum": [
        "GET",
        "ACTIVATE",
        "DEACTIVATE"
      ]
    },
    "CompareCompareResult": {
      "type": "string",
      "default": "EQUAL",
      "enum": [
        "EQUAL",
        "GREATER",
        "LESS",
        "NOT_EQUAL"
      ]
    },
    "CompareCompareTarget": {
      "type": "string",
      "default": "VERSION",
      "enum": [
        "VERSION",
        "CREATE",
        "MOD",
        "VALUE",
        "LEASE"
      ]
    },
    "EventEventType": {
      "type": "string",
      "default": "PUT",
      "enum": [
        "PUT",
        "DELETE"
      ]
    },
    "RangeRequestSortOrder": {
      "type": "string",
      "default": "NONE",
      "enum": [
        "NONE",
        "ASCEND",
        "DESCEND"
      ]
    },
    "RangeRequestSortTarget": {
      "type": "string",
      "default": "KEY",
      "enum": [
        "KEY",
        "VERSION",
        "CREATE",
        "MOD",
        "VALUE"
      ]
    },
    "WatchCreateRequestFilterType": {
      "description": " - NOPUT: filter out put event.\n - NODELETE: filter out delete event.",
      "type": "string",
      "default": "NOPUT",
      "enum": [
        "NOPUT",
        "NODELETE"
      ]
    },
    "authpbPermission": {
      "type": "object",
      "title": "Permission is a single entity",
      "properties": {
        "key": {
          "type": "string",
          "format": "byte"
        },
        "permType": {
          "$ref": "#/definitions/authpbPermissionType"
        },
        "range_end": {
          "type": "string",
          "format": "byte"
        }
      }
    },
    "authpbPermissionType": {
      "type": "string",
      "default": "READ",
      "enum": [
        "READ",
        "WRITE",
        "READWRITE"
      ]
    },
    "authpbUserAddOptions": {
      "type": "object",
      "properties": {
        "no_password": {
          "type": "boolean",
          "format": "boolean"
        }
      }
    },
    "etcdserverpbAlarmMember": {
      "type": "object",
      "properties": {
        "alarm": {
          "description": "alarm is the type of alarm which has been raised.",
          "$ref": "#/definitions/etcdserverpbAlarmType"
        },
        "memberID": {
          "description": "memberID is the ID of the member associated with the raised alarm.",
          "type": "string",
          "format": "uint64"
        }
      }
    },
    "etcdserverpbAlarmRequest": {
      "type": "object",
      "properties": {
        "action": {
          "description": "action is the kind of alarm request to issue. The action\nmay GET alarm statuses, ACTIVATE an alarm, or DEACTIVATE a\nraised alarm.",
          "$ref": "#/definitions/AlarmRequestAlarmAction"
        },
        "alarm": {
          "description": "alarm is the type of alarm to consider for this request.",
          "$ref": "#/definitions/etcdserverpbAlarmType"
        },
        "memberID": {
          "description": "memberID is the ID of the member associated with the alarm. If memberID is 0, the\nalarm request covers all members.",
          "type": "string",
          "format": "uint64"
        }
      }
    },
    "etcdserverpbAlarmResponse": {
      "type": "object",
      "properties": {
        "alarms": {
          "description": "alarms is a list of alarms associated with the alarm request.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/etcdserverpbAlarmMember"
          }
        },
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbAlarmType": {
      "type": "string",
      "default": "NONE",
      "enum": [
        "NONE",
        "NOSPACE",
        "CORRUPT"
      ]
    },
    "etcdserverpbAuthDisableRequest": {
      "type": "object"
    },
    "etcdserverpbAuthDisableResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbAuthEnableRequest": {
      "type": "object"
    },
    "etcdserverpbAuthEnableResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbAuthRoleAddRequest": {
      "type": "object",
      "properties": {
        "name": {
          "description": "name is the name of the role to add to the authentication system.",
          "type": "string"
        }
      }
    },
    "etcdserverpbAuthRoleAddResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbAuthRoleDeleteRequest": {
      "type": "object",
      "properties": {
        "role": {
          "type": "string"
        }
      }
    },
    "etcdserverpbAuthRoleDeleteResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbAuthRoleGetRequest": {
      "type": "object",
      "properties": {
        "role": {
          "type": "string"
        }
      }
    },
    "etcdserverpbAuthRoleGetResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "perm": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/authpbPermission"
          }
        }
      }
    },
    "etcdserverpbAuthRoleGrantPermissionRequest": {
      "type": "object",
      "properties": {
        "name": {
          "description": "name is the name of the role which will be granted the permission.",
          "type": "string"
        },
        "perm": {
          "description": "perm is the permission to grant to the role.",
          "$ref": "#/definitions/authpbPermission"
        }
      }
    },
    "etcdserverpbAuthRoleGrantPermissionResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbAuthRoleListRequest": {
      "type": "object"
    },
    "etcdserverpbAuthRoleListResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "roles": {
          "type": "array",
          "items": {
            "type": "string"
          }
        }
      }
    },
    "etcdserverpbAuthRoleRevokePermissionRequest": {
      "type": "object",
      "properties": {
        "key": {
          "type": "string",
          "format": "byte"
        },
        "range_end": {
          "type": "string",
          "format": "byte"
        },
        "role": {
          "type": "string"
        }
      }
    },
    "etcdserverpbAuthRoleRevokePermissionResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbAuthUserAddRequest": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "options": {
          "$ref": "#/definitions/authpbUserAddOptions"
        },
        "password": {
          "type": "string"
        }
      }
    },
    "etcdserverpbAuthUserAddResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbAuthUserChangePasswordRequest": {
      "type": "object",
      "properties": {
        "name": {
          "description": "name is the name of the user whose password is being changed.",
          "type": "string"
        },
        "password": {
          "description": "password is the new password for the user.",
          "type": "string"
        }
      }
    },
    "etcdserverpbAuthUserChangePasswordResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbAuthUserDeleteRequest": {
      "type": "object",
      "properties": {
        "name": {
          "description": "name is the name of the user to delete.",
          "type": "string"
        }
      }
    },
    "etcdserverpbAuthUserDeleteResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbAuthUserGetRequest": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        }
      }
    },
    "etcdserverpbAuthUserGetResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "roles": {
          "type": "array",
          "items": {
            "type": "string"
          }
        }
      }
    },
    "etcdserverpbAuthUserGrantRoleRequest": {
      "type": "object",
      "properties": {
        "role": {
          "description": "role is the name of the role to grant to the user.",
          "type": "string"
        },
        "user": {
          "description": "user is the name of the user which should be granted a given role.",
          "type": "string"
        }
      }
    },
    "etcdserverpbAuthUserGrantRoleResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbAuthUserListRequest": {
      "type": "object"
    },
    "etcdserverpbAuthUserListResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "users": {
          "type": "array",
          "items": {
            "type": "string"
          }
        }
      }
    },
    "etcdserverpbAuthUserRevokeRoleRequest": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "role": {
          "type": "string"
        }
      }
    },
    "etcdserverpbAuthUserRevokeRoleResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbAuthenticateRequest": {
      "type": "object",
      "properties": {
        "name": {
          "type": "string"
        },
        "password": {
          "type": "string"
        }
      }
    },
    "etcdserverpbAuthenticateResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "token": {
          "type": "string",
          "title": "token is an authorized token that can be used in succeeding RPCs"
        }
      }
    },
    "etcdserverpbCompactionRequest": {
      "description": "CompactionRequest compacts the key-value store up to a given revision. All superseded keys\nwith a revision less than the compaction revision will be removed.",
      "type": "object",
      "properties": {
        "physical": {
          "description": "physical is set so the RPC will wait until the compaction is physically\napplied to the local database such that compacted entries are totally\nremoved from the backend database.",
          "type": "boolean",
          "format": "boolean"
        },
        "revision": {
          "description": "revision is the key-value store revision for the compaction operation.",
          "type": "string",
          "format": "int64"
        }
      }
    },
    "etcdserverpbCompactionResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbCompare": {
      "type": "object",
      "properties": {
        "create_revision": {
          "type": "string",
          "format": "int64",
          "title": "create_revision is the creation revision of the given key"
        },
        "key": {
          "description": "key is the subject key for the comparison operation.",
          "type": "string",
          "format": "byte"
        },
        "lease": {
          "description": "lease is the lease id of the given key.",
          "type": "string",
          "format": "int64"
        },
        "mod_revision": {
          "description": "mod_revision is the last modified revision of the given key.",
          "type": "string",
          "format": "int64"
        },
        "range_end": {
          "description": "range_end compares the given target to all keys in the range [key, range_end).\nSee RangeRequest for more details on key ranges.",
          "type": "string",
          "format": "byte"
        },
        "result": {
          "description": "result is logical comparison operation for this comparison.",
          "$ref": "#/definitions/CompareCompareResult"
        },
        "target": {
          "description": "target is the key-value field to inspect for the comparison.",
          "$ref": "#/definitions/CompareCompareTarget"
        },
        "value": {
          "description": "value is the value of the given key, in bytes.",
          "type": "string",
          "format": "byte"
        },
        "version": {
          "type": "string",
          "format": "int64",
          "title": "version is the version of the given key"
        }
      }
    },
    "etcdserverpbDefragmentRequest": {
      "type": "object"
    },
    "etcdserverpbDefragmentResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbDeleteRangeRequest": {
      "type": "object",
      "properties": {
        "key": {
          "description": "key is the first key to delete in the range.",
          "type": "string",
          "format": "byte"
        },
        "prev_kv": {
          "description": "If prev_kv is set, etcd gets the previous key-value pairs before deleting it.\nThe previous key-value pairs will be returned in the delete response.",
          "type": "boolean",
          "format": "boolean"
        },
        "range_end": {
          "description": "range_end is the key following the last key to delete for the range [key, range_end).\nIf range_end is not given, the range is defined to contain only the key argument.\nIf range_end is one bit larger than the given key, then the range is all the keys\nwith the prefix (the given key).\nIf range_end is '\\0', the range is all keys greater than or equal to the key argument.",
          "type": "string",
          "format": "byte"
        }
      }
    },
    "etcdserverpbDeleteRangeResponse": {
      "type": "object",
      "properties": {
        "deleted": {
          "description": "deleted is the number of keys deleted by the delete range request.",
          "type": "string",
          "format": "int64"
        },
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "prev_kvs": {
          "description": "if prev_kv is set in the request, the previous key-value pairs will be returned.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/mvccpbKeyValue"
          }
        }
      }
    },
    "etcdserverpbHashKVRequest": {
      "type": "object",
      "properties": {
        "revision": {
          "description": "revision is the key-value store revision for the hash operation.",
          "type": "string",
          "format": "int64"
        }
      }
    },
    "etcdserverpbHashKVResponse": {
      "type": "object",
      "properties": {
        "compact_revision": {
          "description": "compact_revision is the compacted revision of key-value store when hash begins.",
          "type": "string",
          "format": "int64"
        },
        "hash": {
          "description": "hash is the hash value computed from the responding member's MVCC keys up to a given revision.",
          "type": "integer",
          "format": "int64"
        },
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbHashRequest": {
      "type": "object"
    },
    "etcdserverpbHashResponse": {
      "type": "object",
      "properties": {
        "hash": {
          "description": "hash is the hash value computed from the responding member's KV's backend.",
          "type": "integer",
          "format": "int64"
        },
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbLeaseGrantRequest": {
      "type": "object",
      "properties": {
        "ID": {
          "description": "ID is the requested ID for the lease. If ID is set to 0, the lessor chooses an ID.",
          "type": "string",
          "format": "int64"
        },
        "TTL": {
          "description": "TTL is the advisory time-to-live in seconds. Expired lease will return -1.",
          "type": "string",
          "format": "int64"
        }
      }
    },
    "etcdserverpbLeaseGrantResponse": {
      "type": "object",
      "properties": {
        "ID": {
          "description": "ID is the lease ID for the granted lease.",
          "type": "string",
          "format": "int64"
        },
        "TTL": {
          "description": "TTL is the server chosen lease time-to-live in seconds.",
          "type": "string",
          "format": "int64"
        },
        "error": {
          "type": "string"
        },
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbLeaseKeepAliveRequest": {
      "type": "object",
      "properties": {
        "ID": {
          "description": "ID is the lease ID for the lease to keep alive.",
          "type": "string",
          "format": "int64"
        }
      }
    },
    "etcdserverpbLeaseKeepAliveResponse": {
      "type": "object",
      "properties": {
        "ID": {
          "description": "ID is the lease ID from the keep alive request.",
          "type": "string",
          "format": "int64"
        },
        "TTL": {
          "description": "TTL is the new time-to-live for the lease.",
          "type": "string",
          "format": "int64"
        },
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbLeaseLeasesRequest": {
      "type": "object"
    },
    "etcdserverpbLeaseLeasesResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "leases": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/etcdserverpbLeaseStatus"
          }
        }
      }
    },
    "etcdserverpbLeaseRevokeRequest": {
      "type": "object",
      "properties": {
        "ID": {
          "description": "ID is the lease ID to revoke. When the ID is revoked, all associated keys will be deleted.",
          "type": "string",
          "format": "int64"
        }
      }
    },
    "etcdserverpbLeaseRevokeResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbLeaseStatus": {
      "type": "object",
      "properties": {
        "ID": {
          "type": "string",
          "format": "int64"
        }
      }
    },
    "etcdserverpbLeaseTimeToLiveRequest": {
      "type": "object",
      "properties": {
        "ID": {
          "description": "ID is the lease ID for the lease.",
          "type": "string",
          "format": "int64"
        },
        "keys": {
          "description": "keys is true to query all the keys attached to this lease.",
          "type": "boolean",
          "format": "boolean"
        }
      }
    },
    "etcdserverpbLeaseTimeToLiveResponse": {
      "type": "object",
      "properties": {
        "ID": {
          "description": "ID is the lease ID from the keep alive request.",
          "type": "string",
          "format": "int64"
        },
        "TTL": {
          "description": "TTL is the remaining TTL in seconds for the lease; the lease will expire in under TTL+1 seconds.",
          "type": "string",
          "format": "int64"
        },
        "grantedTTL": {
          "description": "GrantedTTL is the initial granted time in seconds upon lease creation/renewal.",
          "type": "string",
          "format": "int64"
        },
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "keys": {
          "description": "Keys is the list of keys attached to this lease.",
          "type": "array",
          "items": {
            "type": "string",
            "format": "byte"
          }
        }
      }
    },
    "etcdserverpbMember": {
      "type": "object",
      "properties": {
        "ID": {
          "description": "ID is the member ID for this member.",
          "type": "string",
          "format": "uint64"
        },
        "clientURLs": {
          "description": "clientURLs is the list of URLs the member exposes to clients for communication. If the member is not started, clientURLs will be empty.",
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "isLearner": {
          "description": "isLearner indicates if the member is raft learner.",
          "type": "boolean",
          "format": "boolean"
        },
        "name": {
          "description": "name is the human-readable name of the member. If the member is not started, the name will be an empty string.",
          "type": "string"
        },
        "peerURLs": {
          "description": "peerURLs is the list of URLs the member exposes to the cluster for communication.",
          "type": "array",
          "items": {
            "type": "string"
          }
        }
      }
    },
    "etcdserverpbMemberAddRequest": {
      "type": "object",
      "properties": {
        "isLearner": {
          "description": "isLearner indicates if the added member is raft learner.",
          "type": "boolean",
          "format": "boolean"
        },
        "peerURLs": {
          "description": "peerURLs is the list of URLs the added member will use to communicate with the cluster.",
          "type": "array",
          "items": {
            "type": "string"
          }
        }
      }
    },
    "etcdserverpbMemberAddResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "member": {
          "description": "member is the member information for the added member.",
          "$ref": "#/definitions/etcdserverpbMember"
        },
        "members": {
          "description": "members is a list of all members after adding the new member.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/etcdserverpbMember"
          }
        }
      }
    },
    "etcdserverpbMemberListRequest": {
      "type": "object"
    },
    "etcdserverpbMemberListResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "members": {
          "description": "members is a list of all members associated with the cluster.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/etcdserverpbMember"
          }
        }
      }
    },
    "etcdserverpbMemberPromoteRequest": {
      "type": "object",
      "properties": {
        "ID": {
          "description": "ID is the member ID of the member to promote.",
          "type": "string",
          "format": "uint64"
        }
      }
    },
    "etcdserverpbMemberPromoteResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "members": {
          "description": "members is a list of all members after promoting the member.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/etcdserverpbMember"
          }
        }
      }
    },
    "etcdserverpbMemberRemoveRequest": {
      "type": "object",
      "properties": {
        "ID": {
          "description": "ID is the member ID of the member to remove.",
          "type": "string",
          "format": "uint64"
        }
      }
    },
    "etcdserverpbMemberRemoveResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "members": {
          "description": "members is a list of all members after removing the member.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/etcdserverpbMember"
          }
        }
      }
    },
    "etcdserverpbMemberUpdateRequest": {
      "type": "object",
      "properties": {
        "ID": {
          "description": "ID is the member ID of the member to update.",
          "type": "string",
          "format": "uint64"
        },
        "peerURLs": {
          "description": "peerURLs is the new list of URLs the member will use to communicate with the cluster.",
          "type": "array",
          "items": {
            "type": "string"
          }
        }
      }
    },
    "etcdserverpbMemberUpdateResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "members": {
          "description": "members is a list of all members after updating the member.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/etcdserverpbMember"
          }
        }
      }
    },
    "etcdserverpbMoveLeaderRequest": {
      "type": "object",
      "properties": {
        "targetID": {
          "description": "targetID is the node ID for the new leader.",
          "type": "string",
          "format": "uint64"
        }
      }
    },
    "etcdserverpbMoveLeaderResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        }
      }
    },
    "etcdserverpbPutRequest": {
      "type": "object",
      "properties": {
        "ignore_lease": {
          "description": "If ignore_lease is set, etcd updates the key using its current lease.\nReturns an error if the key does not exist.",
          "type": "boolean",
          "format": "boolean"
        },
        "ignore_value": {
          "description": "If ignore_value is set, etcd updates the key using its current value.\nReturns an error if the key does not exist.",
          "type": "boolean",
          "format": "boolean"
        },
        "key": {
          "description": "key is the key, in bytes, to put into the key-value store.",
          "type": "string",
          "format": "byte"
        },
        "lease": {
          "description": "lease is the lease ID to associate with the key in the key-value store. A lease\nvalue of 0 indicates no lease.",
          "type": "string",
          "format": "int64"
        },
        "prev_kv": {
          "description": "If prev_kv is set, etcd gets the previous key-value pair before changing it.\nThe previous key-value pair will be returned in the put response.",
          "type": "boolean",
          "format": "boolean"
        },
        "value": {
          "description": "value is the value, in bytes, to associate with the key in the key-value store.",
          "type": "string",
          "format": "byte"
        }
      }
    },
    "etcdserverpbPutResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "prev_kv": {
          "description": "if prev_kv is set in the request, the previous key-value pair will be returned.",
          "$ref": "#/definitions/mvccpbKeyValue"
        }
      }
    },
    "etcdserverpbRangeRequest": {
      "type": "object",
      "properties": {
        "count_only": {
          "description": "count_only when set returns only the count of the keys in the range.",
          "type": "boolean",
          "format": "boolean"
        },
        "key": {
          "description": "key is the first key for the range. If range_end is not given, the request only looks up key.",
          "type": "string",
          "format": "byte"
        },
        "keys_only": {
          "description": "keys_only when set returns only the keys and not the values.",
          "type": "boolean",
          "format": "boolean"
        },
        "limit": {
          "description": "limit is a limit on the number of keys returned for the request. When limit is set to 0,\nit is treated as no limit.",
          "type": "string",
          "format": "int64"
        },
        "max_create_revision": {
          "description": "max_create_revision is the upper bound for returned key create revisions; all keys with\ngreater create revisions will be filtered away.",
          "type": "string",
          "format": "int64"
        },
        "max_mod_revision": {
          "description": "max_mod_revision is the upper bound for returned key mod revisions; all keys with\ngreater mod revisions will be filtered away.",
          "type": "string",
          "format": "int64"
        },
        "min_create_revision": {
          "description": "min_create_revision is the lower bound for returned key create revisions; all keys with\nlesser create revisions will be filtered away.",
          "type": "string",
          "format": "int64"
        },
        "min_mod_revision": {
          "description": "min_mod_revision is the lower bound for returned key mod revisions; all keys with\nlesser mod revisions will be filtered away.",
          "type": "string",
          "format": "int64"
        },
        "range_end": {
          "description": "range_end is the upper bound on the requested range [key, range_end).\nIf range_end is '\\0', the range is all keys \u003e= key.\nIf range_end is key plus one (e.g., \"aa\"+1 == \"ab\", \"a\\xff\"+1 == \"b\"),\nthen the range request gets all keys prefixed with key.\nIf both key and range_end are '\\0', then the range request returns all keys.",
          "type": "string",
          "format": "byte"
        },
        "revision": {
          "description": "revision is the point-in-time of the key-value store to use for the range.\nIf revision is less or equal to zero, the range is over the newest key-value store.\nIf the revision has been compacted, ErrCompacted is returned as a response.",
          "type": "string",
          "format": "int64"
        },
        "serializable": {
          "description": "serializable sets the range request to use serializable member-local reads.\nRange requests are linearizable by default; linearizable requests have higher\nlatency and lower throughput than serializable requests but reflect the current\nconsensus of the cluster. For better performance, in exchange for possible stale reads,\na serializable range request is served locally without needing to reach consensus\nwith other nodes in the cluster.",
          "type": "boolean",
          "format": "boolean"
        },
        "sort_order": {
          "description": "sort_order is the order for returned sorted results.",
          "$ref": "#/definitions/RangeRequestSortOrder"
        },
        "sort_target": {
          "description": "sort_target is the key-value field to use for sorting.",
          "$ref": "#/definitions/RangeRequestSortTarget"
        }
      }
    },
    "etcdserverpbRangeResponse": {
      "type": "object",
      "properties": {
        "count": {
          "description": "count is set to the number of keys within the range when requested.",
          "type": "string",
          "format": "int64"
        },
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "kvs": {
          "description": "kvs is the list of key-value pairs matched by the range request.\nkvs is empty when count is requested.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/mvccpbKeyValue"
          }
        },
        "more": {
          "description": "more indicates if there are more keys to return in the requested range.",
          "type": "boolean",
          "format": "boolean"
        }
      }
    },
    "etcdserverpbRequestOp": {
      "type": "object",
      "properties": {
        "request_delete_range": {
          "$ref": "#/definitions/etcdserverpbDeleteRangeRequest"
        },
        "request_put": {
          "$ref": "#/definitions/etcdserverpbPutRequest"
        },
        "request_range": {
          "$ref": "#/definitions/etcdserverpbRangeRequest"
        },
        "request_txn": {
          "$ref": "#/definitions/etcdserverpbTxnRequest"
        }
      }
    },
    "etcdserverpbResponseHeader": {
      "type": "object",
      "properties": {
        "cluster_id": {
          "description": "cluster_id is the ID of the cluster which sent the response.",
          "type": "string",
          "format": "uint64"
        },
        "member_id": {
          "description": "member_id is the ID of the member which sent the response.",
          "type": "string",
          "format": "uint64"
        },
        "raft_term": {
          "description": "raft_term is the raft term when the request was applied.",
          "type": "string",
          "format": "uint64"
        },
        "revision": {
          "description": "revision is the key-value store revision when the request was applied.\nFor watch progress responses, the header.revision indicates progress. All future events\nrecieved in this stream are guaranteed to have a higher revision number than the\nheader.revision number.",
          "type": "string",
          "format": "int64"
        }
      }
    },
    "etcdserverpbResponseOp": {
      "type": "object",
      "properties": {
        "response_delete_range": {
          "$ref": "#/definitions/etcdserverpbDeleteRangeResponse"
        },
        "response_put": {
          "$ref": "#/definitions/etcdserverpbPutResponse"
        },
        "response_range": {
          "$ref": "#/definitions/etcdserverpbRangeResponse"
        },
        "response_txn": {
          "$ref": "#/definitions/etcdserverpbTxnResponse"
        }
      }
    },
    "etcdserverpbSnapshotRequest": {
      "type": "object"
    },
    "etcdserverpbSnapshotResponse": {
      "type": "object",
      "properties": {
        "blob": {
          "description": "blob contains the next chunk of the snapshot in the snapshot stream.",
          "type": "string",
          "format": "byte"
        },
        "header": {
          "description": "header has the current key-value store information. The first header in the snapshot\nstream indicates the point in time of the snapshot.",
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "remaining_bytes": {
          "type": "string",
          "format": "uint64",
          "title": "remaining_bytes is the number of blob bytes to be sent after this message"
        }
      }
    },
    "etcdserverpbStatusRequest": {
      "type": "object"
    },
    "etcdserverpbStatusResponse": {
      "type": "object",
      "properties": {
        "dbSize": {
          "description": "dbSize is the size of the backend database physically allocated, in bytes, of the responding member.",
          "type": "string",
          "format": "int64"
        },
        "dbSizeInUse": {
          "description": "dbSizeInUse is the size of the backend database logically in use, in bytes, of the responding member.",
          "type": "string",
          "format": "int64"
        },
        "errors": {
          "description": "errors contains alarm/health information and status.",
          "type": "array",
          "items": {
            "type": "string"
          }
        },
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "isLearner": {
          "description": "isLearner indicates if the member is raft learner.",
          "type": "boolean",
          "format": "boolean"
        },
        "leader": {
          "description": "leader is the member ID which the responding member believes is the current leader.",
          "type": "string",
          "format": "uint64"
        },
        "raftAppliedIndex": {
          "description": "raftAppliedIndex is the current raft applied index of the responding member.",
          "type": "string",
          "format": "uint64"
        },
        "raftIndex": {
          "description": "raftIndex is the current raft committed index of the responding member.",
          "type": "string",
          "format": "uint64"
        },
        "raftTerm": {
          "description": "raftTerm is the current raft term of the responding member.",
          "type": "string",
          "format": "uint64"
        },
        "version": {
          "description": "version is the cluster protocol version used by the responding member.",
          "type": "string"
        }
      }
    },
    "etcdserverpbTxnRequest": {
      "description": "From google paxosdb paper:\nOur implementation hinges around a powerful primitive which we call MultiOp. All other database\noperations except for iteration are implemented as a single call to MultiOp. A MultiOp is applied atomically\nand consists of three components:\n1. A list of tests called guard. Each test in guard checks a single entry in the database. It may check\nfor the absence or presence of a value, or compare with a given value. Two different tests in the guard\nmay apply to the same or different entries in the database. All tests in the guard are applied and\nMultiOp returns the results. If all tests are true, MultiOp executes t op (see item 2 below), otherwise\nit executes f op (see item 3 below).\n2. A list of database operations called t op. Each operation in the list is either an insert, delete, or\nlookup operation, and applies to a single database entry. Two different operations in the list may apply\nto the same or different entries in the database. These operations are executed\nif guard evaluates to\ntrue.\n3. A list of database operations called f op. Like t op, but executed if guard evaluates to false.",
      "type": "object",
      "properties": {
        "compare": {
          "description": "compare is a list of predicates representing a conjunction of terms.\nIf the comparisons succeed, then the success requests will be processed in order,\nand the response will contain their respective responses in order.\nIf the comparisons fail, then the failure requests will be processed in order,\nand the response will contain their respective responses in order.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/etcdserverpbCompare"
          }
        },
        "failure": {
          "description": "failure is a list of requests which will be applied when compare evaluates to false.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/etcdserverpbRequestOp"
          }
        },
        "success": {
          "description": "success is a list of requests which will be applied when compare evaluates to true.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/etcdserverpbRequestOp"
          }
        }
      }
    },
    "etcdserverpbTxnResponse": {
      "type": "object",
      "properties": {
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "responses": {
          "description": "responses is a list of responses corresponding to the results from applying\nsuccess if succeeded is true or failure if succeeded is false.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/etcdserverpbResponseOp"
          }
        },
        "succeeded": {
          "description": "succeeded is set to true if the compare evaluated to true or false otherwise.",
          "type": "boolean",
          "format": "boolean"
        }
      }
    },
    "etcdserverpbWatchCancelRequest": {
      "type": "object",
      "properties": {
        "watch_id": {
          "description": "watch_id is the watcher id to cancel so that no more events are transmitted.",
          "type": "string",
          "format": "int64"
        }
      }
    },
    "etcdserverpbWatchCreateRequest": {
      "type": "object",
      "properties": {
        "filters": {
          "description": "filters filter the events at server side before it sends back to the watcher.",
          "type": "array",
          "items": {
            "$ref": "#/definitions/WatchCreateRequestFilterType"
          }
        },
        "fragment": {
          "description": "fragment enables splitting large revisions into multiple watch responses.",
          "type": "boolean",
          "format": "boolean"
        },
        "key": {
          "description": "key is the key to register for watching.",
          "type": "string",
          "format": "byte"
        },
        "prev_kv": {
          "description": "If prev_kv is set, created watcher gets the previous KV before the event happens.\nIf the previous KV is already compacted, nothing will be returned.",
          "type": "boolean",
          "format": "boolean"
        },
        "progress_notify": {
          "description": "progress_notify is set so that the etcd server will periodically send a WatchResponse with\nno events to the new watcher if there are no recent events. It is useful when clients\nwish to recover a disconnected watcher starting from a recent known revision.\nThe etcd server may decide how often it will send notifications based on current load.",
          "type": "boolean",
          "format": "boolean"
        },
        "range_end": {
          "description": "range_end is the end of the range [key, range_end) to watch. If range_end is not given,\nonly the key argument is watched. If range_end is equal to '\\0', all keys greater than\nor equal to the key argument are watched.\nIf the range_end is one bit larger than the given key,\nthen all keys with the prefix (the given key) will be watched.",
          "type": "string",
          "format": "byte"
        },
        "start_revision": {
          "description": "start_revision is an optional revision to watch from (inclusive). No start_revision is \"now\".",
          "type": "string",
          "format": "int64"
        },
        "watch_id": {
          "description": "If watch_id is provided and non-zero, it will be assigned to this watcher.\nSince creating a watcher in etcd is not a synchronous operation,\nthis can be used ensure that ordering is correct when creating multiple\nwatchers on the same stream. Creating a watcher with an ID already in\nuse on the stream will cause an error to be returned.",
          "type": "string",
          "format": "int64"
        }
      }
    },
    "etcdserverpbWatchProgressRequest": {
      "description": "Requests the a watch stream progress status be sent in the watch response stream as soon as\npossible.",
      "type": "object"
    },
    "etcdserverpbWatchRequest": {
      "type": "object",
      "properties": {
        "cancel_request": {
          "$ref": "#/definitions/etcdserverpbWatchCancelRequest"
        },
        "create_request": {
          "$ref": "#/definitions/etcdserverpbWatchCreateRequest"
        },
        "progress_request": {
          "$ref": "#/definitions/etcdserverpbWatchProgressRequest"
        }
      }
    },
    "etcdserverpbWatchResponse": {
      "type": "object",
      "properties": {
        "cancel_reason": {
          "description": "cancel_reason indicates the reason for canceling the watcher.",
          "type": "string"
        },
        "canceled": {
          "description": "canceled is set to true if the response is for a cancel watch request.\nNo further events will be sent to the canceled watcher.",
          "type": "boolean",
          "format": "boolean"
        },
        "compact_revision": {
          "description": "compact_revision is set to the minimum index if a watcher tries to watch\nat a compacted index.\n\nThis happens when creating a watcher at a compacted revision or the watcher cannot\ncatch up with the progress of the key-value store.\n\nThe client should treat the watcher as canceled and should not try to create any\nwatcher with the same start_revision again.",
          "type": "string",
          "format": "int64"
        },
        "created": {
          "description": "created is set to true if the response is for a create watch request.\nThe client should record the watch_id and expect to receive events for\nthe created watcher from the same stream.\nAll events sent to the created watcher will attach with the same watch_id.",
          "type": "boolean",
          "format": "boolean"
        },
        "events": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/mvccpbEvent"
          }
        },
        "fragment": {
          "description": "framgment is true if large watch response was split over multiple responses.",
          "type": "boolean",
          "format": "boolean"
        },
        "header": {
          "$ref": "#/definitions/etcdserverpbResponseHeader"
        },
        "watch_id": {
          "description": "watch_id is the ID of the watcher that corresponds to the response.",
          "type": "string",
          "format": "int64"
        }
      }
    },
    "mvccpbEvent": {
      "type": "object",
      "properties": {
        "kv": {
          "description": "kv holds the KeyValue for the event.\nA PUT event contains current kv pair.\nA PUT event with kv.Version=1 indicates the creation of a key.\nA DELETE/EXPIRE event contains the deleted key with\nits modification revision set to the revision of deletion.",
          "$ref": "#/definitions/mvccpbKeyValue"
        },
        "prev_kv": {
          "description": "prev_kv holds the key-value pair before the event happens.",
          "$ref": "#/definitions/mvccpbKeyValue"
        },
        "type": {
          "description": "type is the kind of event. If type is a PUT, it indicates\nnew data has been stored to the key. If type is a DELETE,\nit indicates the key was deleted.",
          "$ref": "#/definitions/EventEventType"
        }
      }
    },
    "mvccpbKeyValue": {
      "type": "object",
      "properties": {
        "create_revision": {
          "description": "create_revision is the revision of last creation on this key.",
          "type": "string",
          "format": "int64"
        },
        "key": {
          "description": "key is the key in bytes. An empty key is not allowed.",
          "type": "string",
          "format": "byte"
        },
        "lease": {
          "description": "lease is the ID of the lease that attached to key.\nWhen the attached lease expires, the key will be deleted.\nIf lease is 0, then no lease is attached to the key.",
          "type": "string",
          "format": "int64"
        },
        "mod_revision": {
          "description": "mod_revision is the revision of last modification on this key.",
          "type": "string",
          "format": "int64"
        },
        "value": {
          "description": "value is the value held by the key, in bytes.",
          "type": "string",
          "format": "byte"
        },
        "version": {
          "description": "version is the version of the key. A deletion resets\nthe version to zero and any modification of the key\nincreases its version.",
          "type": "string",
          "format": "int64"
        }
      }
    },
    "protobufAny": {
      "type": "object",
      "properties": {
        "type_url": {
          "type": "string"
        },
        "value": {
          "type": "string",
          "format": "byte"
        }
      }
    },
    "runtimeStreamError": {
      "type": "object",
      "properties": {
        "details": {
          "type": "array",
          "items": {
            "$ref": "#/definitions/protobufAny"
          }
        },
        "grpc_code": {
          "type": "integer",
          "format": "int32"
        },
        "http_code": {
          "type": "integer",
          "format": "int32"
        },
        "http_status": {
          "type": "string"
        },
        "message": {
          "type": "string"
        }
      }
    }
  },
  "securityDefinitions": {
    "ApiKey": {
      "type": "apiKey",
      "name": "Authorization",
      "in": "header"
    }
  },
  "security": [
    {
      "ApiKey": []
    }
  ],
  "x-stream-definitions": {
    "etcdserverpbLeaseKeepAliveResponse": {
      "properties": {
        "error": {
          "$ref": "#/definitions/runtimeStreamError"
        },
        "result": {
          "$ref": "#/definitions/etcdserverpbLeaseKeepAliveResponse"
        }
      },
      "title": "Stream result of etcdserverpbLeaseKeepAliveResponse",
      "type": "object"
    },
    "etcdserverpbSnapshotResponse": {
      "properties": {
        "error": {
          "$ref": "#/definitions/runtimeStreamError"
        },
        "result": {
          "$ref": "#/definitions/etcdserverpbSnapshotResponse"
        }
      },
      "title": "Stream result of etcdserverpbSnapshotResponse",
      "type": "object"
    },
    "etcdserverpbWatchResponse": {
      "properties": {
        "error": {
          "$ref": "#/definitions/runtimeStreamError"
        },
        "result": {
          "$ref": "#/definitions/etcdserverpbWatchResponse"
        }
      },
      "title": "Stream result of etcdserverpbWatchResponse",
      "type": "object"
    }
  }
}
```
