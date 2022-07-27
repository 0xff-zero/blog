# Nomad 接口

# 界面plan
## jobs/parse
```
curl 'http://localhost:4646/v1/jobs/parse' \
  -H 'Connection: keep-alive' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'content-type: application/json; charset=UTF-8' \
  -H 'Accept: */*' \
  -H 'Origin: http://localhost:4646' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost:4646/ui/jobs/run' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  --data-raw '{"JobHCL":"job \"recognize_redis_example\" {\n  datacenters = [\"dc1\"]\n  type        = \"service\"\n  group \"recognize_redis\" {\n    task \"redis\" {\n      driver = \"recognize\"\n      config {\n        meta {\n          cluster = \"redis_dc1\"\n          region  = \"sg\"\n        }\n        recognize {\n          filter_type = \"net\"\n          target      = \"redis\"\n          identify    = \"127.0.0.1:6379\"\n        }\n        takeover {\n          enable            = false\n          succession_driver = \"docker\"\n            docker {\n              image = \"redis:3.2\"\n              labels {\n                group=\"test\"\n              }\n            }\n        }\n      }\n    }\n  }\n}","Canonicalize":true}' \
  --compressed
```
响应结果
``` 
{
    "Affinities":null,
    "AllAtOnce":false,
    "Constraints":null,
    "ConsulNamespace":"",
    "ConsulToken":"",
    "CreateIndex":0,
    "Datacenters":[
        "dc1"
    ],
    "DispatchIdempotencyToken":null,
    "Dispatched":false,
    "ID":"recognize_redis_example",
    "JobModifyIndex":0,
    "Meta":null,
    "Migrate":null,
    "ModifyIndex":0,
    "Multiregion":null,
    "Name":"recognize_redis_example",
    "Namespace":"default",
    "NomadTokenID":"",
    "ParameterizedJob":null,
    "ParentID":"",
    "Payload":null,
    "Periodic":null,
    "Priority":50,
    "Region":"global",
    "Reschedule":null,
    "Spreads":null,
    "Stable":false,
    "Status":"",
    "StatusDescription":"",
    "Stop":false,
    "SubmitTime":null,
    "TaskGroups":[
        {
            "Affinities":null,
            "Constraints":null,
            "Consul":{
                "Namespace":""
            },
            "Count":1,
            "EphemeralDisk":{
                "Migrate":false,
                "SizeMB":300,
                "Sticky":false
            },
            "Meta":null,
            "Migrate":{
                "HealthCheck":"checks",
                "HealthyDeadline":300000000000,
                "MaxParallel":1,
                "MinHealthyTime":10000000000
            },
            "Name":"recognize_redis",
            "Networks":null,
            "ReschedulePolicy":{
                "Attempts":0,
                "Delay":30000000000,
                "DelayFunction":"exponential",
                "Interval":0,
                "MaxDelay":3600000000000,
                "Unlimited":true
            },
            "RestartPolicy":{
                "Attempts":2,
                "Delay":15000000000,
                "Interval":1800000000000,
                "Mode":"fail"
            },
            "Scaling":null,
            "Services":null,
            "ShutdownDelay":null,
            "Spreads":null,
            "StopAfterClientDisconnect":null,
            "Tasks":[
                {
                    "Affinities":null,
                    "Artifacts":null,
                    "Config":{
                        "recognize":[
                            {
                                "target":"redis",
                                "identify":"127.0.0.1:6379",
                                "filter_type":"net"
                            }
                        ],
                        "takeover":[
                            {
                                "enable":false,
                                "succession_driver":"docker",
                                "docker":[
                                    {
                                        "image":"redis:3.2",
                                        "labels":[
                                            {
                                                "group":"test"
                                            }
                                        ]
                                    }
                                ]
                            }
                        ],
                        "meta":[
                            {
                                "cluster":"redis_dc1",
                                "region":"sg"
                            }
                        ]
                    },
                    "Constraints":null,
                    "DispatchPayload":null,
                    "Driver":"recognize",
                    "Env":null,
                    "KillSignal":"",
                    "KillTimeout":5000000000,
                    "Kind":"",
                    "Leader":false,
                    "Lifecycle":null,
                    "LogConfig":{
                        "MaxFileSizeMB":10,
                        "MaxFiles":10
                    },
                    "Meta":null,
                    "Name":"redis",
                    "Resources":{
                        "CPU":100,
                        "Cores":0,
                        "Devices":null,
                        "DiskMB":null,
                        "IOPS":null,
                        "MemoryMB":300,
                        "MemoryMaxMB":null,
                        "Networks":null
                    },
                    "RestartPolicy":{
                        "Attempts":2,
                        "Delay":15000000000,
                        "Interval":1800000000000,
                        "Mode":"fail"
                    },
                    "ScalingPolicies":null,
                    "Services":null,
                    "ShutdownDelay":0,
                    "Templates":null,
                    "User":"",
                    "Vault":null,
                    "VolumeMounts":null
                }
            ],
            "Update":{
                "AutoPromote":false,
                "AutoRevert":false,
                "Canary":0,
                "HealthCheck":"checks",
                "HealthyDeadline":300000000000,
                "MaxParallel":1,
                "MinHealthyTime":10000000000,
                "ProgressDeadline":600000000000,
                "Stagger":30000000000
            },
            "Volumes":null
        }
    ],
    "Type":"service",
    "Update":{
        "AutoPromote":false,
        "AutoRevert":false,
        "Canary":0,
        "HealthCheck":"checks",
        "HealthyDeadline":300000000000,
        "MaxParallel":1,
        "MinHealthyTime":10000000000,
        "ProgressDeadline":600000000000,
        "Stagger":30000000000
    },
    "VaultNamespace":"",
    "VaultToken":"",
    "Version":0
}
```
## job/{jobname}/plan
```
curl 'http://localhost:4646/v1/job/recognize_redis_example/plan' \
  -H 'Connection: keep-alive' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'content-type: application/json; charset=UTF-8' \
  -H 'Accept: */*' \
  -H 'Origin: http://localhost:4646' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost:4646/ui/jobs/run' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  --data-raw '{"Job":{"Affinities":null,"AllAtOnce":false,"Constraints":null,"ConsulNamespace":"","ConsulToken":"","CreateIndex":0,"Datacenters":["dc1"],"DispatchIdempotencyToken":null,"Dispatched":false,"ID":"recognize_redis_example","JobModifyIndex":0,"Meta":null,"Migrate":null,"ModifyIndex":0,"Multiregion":null,"Name":"recognize_redis_example","Namespace":"default","NomadTokenID":"","ParameterizedJob":null,"ParentID":"","Payload":null,"Periodic":null,"Priority":50,"Region":"global","Reschedule":null,"Spreads":null,"Stable":false,"Status":"","StatusDescription":"","Stop":false,"SubmitTime":null,"TaskGroups":[{"Affinities":null,"Constraints":null,"Consul":{"Namespace":""},"Count":1,"EphemeralDisk":{"Migrate":false,"SizeMB":300,"Sticky":false},"Meta":null,"Migrate":{"HealthCheck":"checks","HealthyDeadline":300000000000,"MaxParallel":1,"MinHealthyTime":10000000000},"Name":"recognize_redis","Networks":null,"ReschedulePolicy":{"Attempts":0,"Delay":30000000000,"DelayFunction":"exponential","Interval":0,"MaxDelay":3600000000000,"Unlimited":true},"RestartPolicy":{"Attempts":2,"Delay":15000000000,"Interval":1800000000000,"Mode":"fail"},"Scaling":null,"Services":null,"ShutdownDelay":null,"Spreads":null,"StopAfterClientDisconnect":null,"Tasks":[{"Affinities":null,"Artifacts":null,"Config":{"recognize":[{"target":"redis","identify":"127.0.0.1:6379","filter_type":"net"}],"takeover":[{"enable":false,"succession_driver":"docker","docker":[{"image":"redis:3.2","labels":[{"group":"test"}]}]}],"meta":[{"cluster":"redis_dc1","region":"sg"}]},"Constraints":null,"DispatchPayload":null,"Driver":"recognize","Env":null,"KillSignal":"","KillTimeout":5000000000,"Kind":"","Leader":false,"Lifecycle":null,"LogConfig":{"MaxFileSizeMB":10,"MaxFiles":10},"Meta":null,"Name":"redis","Resources":{"CPU":100,"Cores":0,"Devices":null,"DiskMB":null,"IOPS":null,"MemoryMB":300,"MemoryMaxMB":null,"Networks":null},"RestartPolicy":{"Attempts":2,"Delay":15000000000,"Interval":1800000000000,"Mode":"fail"},"ScalingPolicies":null,"Services":null,"ShutdownDelay":0,"Templates":null,"User":"","Vault":null,"VolumeMounts":null}],"Update":{"AutoPromote":false,"AutoRevert":false,"Canary":0,"HealthCheck":"checks","HealthyDeadline":300000000000,"MaxParallel":1,"MinHealthyTime":10000000000,"ProgressDeadline":600000000000,"Stagger":30000000000},"Volumes":null}],"Type":"service","Update":{"AutoPromote":false,"AutoRevert":false,"Canary":0,"HealthCheck":"checks","HealthyDeadline":300000000000,"MaxParallel":1,"MinHealthyTime":10000000000,"ProgressDeadline":600000000000,"Stagger":30000000000},"VaultNamespace":"","VaultToken":"","Version":0},"Diff":true}' \
  --compressed
```
响应
``` 
{
    "Annotations":{
        "DesiredTGUpdates":{
            "recognize_redis":{
                "Canary":0,
                "DestructiveUpdate":0,
                "Ignore":0,
                "InPlaceUpdate":0,
                "Migrate":0,
                "Place":1,
                "Preemptions":0,
                "Stop":0
            }
        },
        "PreemptedAllocs":null
    },
    "CreatedEvals":null,
    "Diff":{
        "Fields":[
            {
                "Annotations":null,
                "Name":"AllAtOnce",
                "New":"false",
                "Old":"",
                "Type":"Added"
            },
            {
                "Annotations":null,
                "Name":"Dispatched",
                "New":"false",
                "Old":"",
                "Type":"Added"
            },
            {
                "Annotations":null,
                "Name":"Name",
                "New":"recognize_redis_example",
                "Old":"",
                "Type":"Added"
            },
            {
                "Annotations":null,
                "Name":"Namespace",
                "New":"default",
                "Old":"",
                "Type":"Added"
            },
            {
                "Annotations":null,
                "Name":"Priority",
                "New":"50",
                "Old":"",
                "Type":"Added"
            },
            {
                "Annotations":null,
                "Name":"Region",
                "New":"global",
                "Old":"",
                "Type":"Added"
            },
            {
                "Annotations":null,
                "Name":"Stop",
                "New":"false",
                "Old":"",
                "Type":"Added"
            },
            {
                "Annotations":null,
                "Name":"Type",
                "New":"service",
                "Old":"",
                "Type":"Added"
            }
        ],
        "ID":"recognize_redis_example",
        "Objects":[
            {
                "Fields":[
                    {
                        "Annotations":null,
                        "Name":"Datacenters",
                        "New":"dc1",
                        "Old":"",
                        "Type":"Added"
                    }
                ],
                "Name":"Datacenters",
                "Objects":null,
                "Type":"Added"
            }
        ],
        "TaskGroups":[
            {
                "Fields":[
                    {
                        "Annotations":[
                            "forces create"
                        ],
                        "Name":"Count",
                        "New":"1",
                        "Old":"",
                        "Type":"Added"
                    }
                ],
                "Name":"recognize_redis",
                "Objects":[
                    {
                        "Fields":[
                            {
                                "Annotations":null,
                                "Name":"Attempts",
                                "New":"2",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"Delay",
                                "New":"15000000000",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"Interval",
                                "New":"1800000000000",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"Mode",
                                "New":"fail",
                                "Old":"",
                                "Type":"Added"
                            }
                        ],
                        "Name":"RestartPolicy",
                        "Objects":null,
                        "Type":"Added"
                    },
                    {
                        "Fields":[
                            {
                                "Annotations":null,
                                "Name":"Attempts",
                                "New":"0",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"Delay",
                                "New":"30000000000",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"DelayFunction",
                                "New":"exponential",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"Interval",
                                "New":"0",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"MaxDelay",
                                "New":"3600000000000",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"Unlimited",
                                "New":"true",
                                "Old":"",
                                "Type":"Added"
                            }
                        ],
                        "Name":"ReschedulePolicy",
                        "Objects":null,
                        "Type":"Added"
                    },
                    {
                        "Fields":[
                            {
                                "Annotations":null,
                                "Name":"Migrate",
                                "New":"false",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"SizeMB",
                                "New":"300",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"Sticky",
                                "New":"false",
                                "Old":"",
                                "Type":"Added"
                            }
                        ],
                        "Name":"EphemeralDisk",
                        "Objects":null,
                        "Type":"Added"
                    },
                    {
                        "Fields":[
                            {
                                "Annotations":null,
                                "Name":"AutoPromote",
                                "New":"false",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"AutoRevert",
                                "New":"false",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"Canary",
                                "New":"0",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"HealthCheck",
                                "New":"checks",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"HealthyDeadline",
                                "New":"300000000000",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"MaxParallel",
                                "New":"1",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"MinHealthyTime",
                                "New":"10000000000",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"ProgressDeadline",
                                "New":"600000000000",
                                "Old":"",
                                "Type":"Added"
                            }
                        ],
                        "Name":"Update",
                        "Objects":null,
                        "Type":"Added"
                    }
                ],
                "Tasks":[
                    {
                        "Annotations":[
                            "forces create"
                        ],
                        "Fields":[
                            {
                                "Annotations":null,
                                "Name":"Driver",
                                "New":"recognize",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"KillTimeout",
                                "New":"5000000000",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"Leader",
                                "New":"false",
                                "Old":"",
                                "Type":"Added"
                            },
                            {
                                "Annotations":null,
                                "Name":"ShutdownDelay",
                                "New":"0",
                                "Old":"",
                                "Type":"Added"
                            }
                        ],
                        "Name":"redis",
                        "Objects":[
                            {
                                "Fields":[
                                    {
                                        "Annotations":null,
                                        "Name":"meta[0][cluster]",
                                        "New":"redis_dc1",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"meta[0][region]",
                                        "New":"sg",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"recognize[0][filter_type]",
                                        "New":"net",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"recognize[0][identify]",
                                        "New":"127.0.0.1:6379",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"recognize[0][target]",
                                        "New":"redis",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"takeover[0][docker][0][image]",
                                        "New":"redis:3.2",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"takeover[0][docker][0][labels][0][group]",
                                        "New":"test",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"takeover[0][enable]",
                                        "New":"false",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"takeover[0][succession_driver]",
                                        "New":"docker",
                                        "Old":"",
                                        "Type":"Added"
                                    }
                                ],
                                "Name":"Config",
                                "Objects":null,
                                "Type":"Added"
                            },
                            {
                                "Fields":[
                                    {
                                        "Annotations":null,
                                        "Name":"CPU",
                                        "New":"100",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"Cores",
                                        "New":"0",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"DiskMB",
                                        "New":"0",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"IOPS",
                                        "New":"0",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"MemoryMB",
                                        "New":"300",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"MemoryMaxMB",
                                        "New":"0",
                                        "Old":"",
                                        "Type":"Added"
                                    }
                                ],
                                "Name":"Resources",
                                "Objects":null,
                                "Type":"Added"
                            },
                            {
                                "Fields":[
                                    {
                                        "Annotations":null,
                                        "Name":"MaxFileSizeMB",
                                        "New":"10",
                                        "Old":"",
                                        "Type":"Added"
                                    },
                                    {
                                        "Annotations":null,
                                        "Name":"MaxFiles",
                                        "New":"10",
                                        "Old":"",
                                        "Type":"Added"
                                    }
                                ],
                                "Name":"LogConfig",
                                "Objects":null,
                                "Type":"Added"
                            }
                        ],
                        "Type":"Added"
                    }
                ],
                "Type":"Added",
                "Updates":{
                    "create":1
                }
            }
        ],
        "Type":"Added"
    },
    "FailedTGAllocs":null,
    "Index":0,
    "JobModifyIndex":0,
    "NextPeriodicLaunch":null,
    "Warnings":""
}
```
# ui-run
## /v1/jobs

```
curl 'http://localhost:4646/v1/jobs' \
  -H 'Connection: keep-alive' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'content-type: application/json; charset=UTF-8' \
  -H 'Accept: */*' \
  -H 'Origin: http://localhost:4646' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost:4646/ui/jobs/run' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  --data-raw '{"Job":{"Affinities":null,"AllAtOnce":false,"Constraints":null,"ConsulNamespace":"","ConsulToken":"","CreateIndex":0,"Datacenters":["dc1"],"DispatchIdempotencyToken":null,"Dispatched":false,"ID":"recognize_redis_example","JobModifyIndex":0,"Meta":null,"Migrate":null,"ModifyIndex":0,"Multiregion":null,"Name":"recognize_redis_example","Namespace":"default","NomadTokenID":"","ParameterizedJob":null,"ParentID":"","Payload":null,"Periodic":null,"Priority":50,"Region":"global","Reschedule":null,"Spreads":null,"Stable":false,"Status":"","StatusDescription":"","Stop":false,"SubmitTime":null,"TaskGroups":[{"Affinities":null,"Constraints":null,"Consul":{"Namespace":""},"Count":1,"EphemeralDisk":{"Migrate":false,"SizeMB":300,"Sticky":false},"Meta":null,"Migrate":{"HealthCheck":"checks","HealthyDeadline":300000000000,"MaxParallel":1,"MinHealthyTime":10000000000},"Name":"recognize_redis","Networks":null,"ReschedulePolicy":{"Attempts":0,"Delay":30000000000,"DelayFunction":"exponential","Interval":0,"MaxDelay":3600000000000,"Unlimited":true},"RestartPolicy":{"Attempts":2,"Delay":15000000000,"Interval":1800000000000,"Mode":"fail"},"Scaling":null,"Services":null,"ShutdownDelay":null,"Spreads":null,"StopAfterClientDisconnect":null,"Tasks":[{"Affinities":null,"Artifacts":null,"Config":{"recognize":[{"target":"redis","identify":"127.0.0.1:6379","filter_type":"net"}],"takeover":[{"enable":false,"succession_driver":"docker","docker":[{"image":"redis:3.2","labels":[{"group":"test"}]}]}],"meta":[{"cluster":"redis_dc1","region":"sg"}]},"Constraints":null,"DispatchPayload":null,"Driver":"recognize","Env":null,"KillSignal":"","KillTimeout":5000000000,"Kind":"","Leader":false,"Lifecycle":null,"LogConfig":{"MaxFileSizeMB":10,"MaxFiles":10},"Meta":null,"Name":"redis","Resources":{"CPU":100,"Cores":0,"Devices":null,"DiskMB":null,"IOPS":null,"MemoryMB":300,"MemoryMaxMB":null,"Networks":null},"RestartPolicy":{"Attempts":2,"Delay":15000000000,"Interval":1800000000000,"Mode":"fail"},"ScalingPolicies":null,"Services":null,"ShutdownDelay":0,"Templates":null,"User":"","Vault":null,"VolumeMounts":null}],"Update":{"AutoPromote":false,"AutoRevert":false,"Canary":0,"HealthCheck":"checks","HealthyDeadline":300000000000,"MaxParallel":1,"MinHealthyTime":10000000000,"ProgressDeadline":600000000000,"Stagger":30000000000},"Volumes":null}],"Type":"service","Update":{"AutoPromote":false,"AutoRevert":false,"Canary":0,"HealthCheck":"checks","HealthyDeadline":300000000000,"MaxParallel":1,"MinHealthyTime":10000000000,"ProgressDeadline":600000000000,"Stagger":30000000000},"VaultNamespace":"","VaultToken":"","Version":0}}' \
  --compressed
```
响应
```json
{"EvalCreateIndex":14,"EvalID":"0af80e99-edfc-152d-ba25-360dbec37277","Index":14,"JobModifyIndex":14,"KnownLeader":false,"LastContact":0,"Warnings":""}
```

## v1/job/{job name}
```
curl 'http://localhost:4646/v1/job/recognize_redis_example' \
  -H 'Connection: keep-alive' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'Accept: */*' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost:4646/ui/jobs/run' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  --compressed

```
响应
``` 
{
    "Affinities":null,
    "AllAtOnce":false,
    "Constraints":null,
    "ConsulNamespace":"",
    "ConsulToken":"",
    "CreateIndex":14,
    "Datacenters":[
        "dc1"
    ],
    "DispatchIdempotencyToken":"",
    "Dispatched":false,
    "ID":"recognize_redis_example",
    "JobModifyIndex":14,
    "Meta":null,
    "ModifyIndex":15,
    "Multiregion":null,
    "Name":"recognize_redis_example",
    "Namespace":"default",
    "NomadTokenID":"",
    "ParameterizedJob":null,
    "ParentID":"",
    "Payload":null,
    "Periodic":null,
    "Priority":50,
    "Region":"global",
    "Spreads":null,
    "Stable":false,
    "Status":"running",
    "StatusDescription":"",
    "Stop":false,
    "SubmitTime":1645601194094486985,
    "TaskGroups":[
        {
            "Affinities":null,
            "Constraints":null,
            "Consul":{
                "Namespace":""
            },
            "Count":1,
            "EphemeralDisk":{
                "Migrate":false,
                "SizeMB":300,
                "Sticky":false
            },
            "Meta":null,
            "Migrate":{
                "HealthCheck":"checks",
                "HealthyDeadline":300000000000,
                "MaxParallel":1,
                "MinHealthyTime":10000000000
            },
            "Name":"recognize_redis",
            "Networks":null,
            "ReschedulePolicy":{
                "Attempts":0,
                "Delay":30000000000,
                "DelayFunction":"exponential",
                "Interval":0,
                "MaxDelay":3600000000000,
                "Unlimited":true
            },
            "RestartPolicy":{
                "Attempts":2,
                "Delay":15000000000,
                "Interval":1800000000000,
                "Mode":"fail"
            },
            "Scaling":null,
            "Services":null,
            "ShutdownDelay":null,
            "Spreads":null,
            "StopAfterClientDisconnect":null,
            "Tasks":[
                {
                    "Affinities":null,
                    "Artifacts":null,
                    "CSIPluginConfig":null,
                    "Config":{
                        "recognize":[
                            {
                                "filter_type":"net",
                                "target":"redis",
                                "identify":"127.0.0.1:6379"
                            }
                        ],
                        "takeover":[
                            {
                                "enable":false,
                                "succession_driver":"docker",
                                "docker":[
                                    {
                                        "image":"redis:3.2",
                                        "labels":[
                                            {
                                                "group":"test"
                                            }
                                        ]
                                    }
                                ]
                            }
                        ],
                        "meta":[
                            {
                                "cluster":"redis_dc1",
                                "region":"sg"
                            }
                        ]
                    },
                    "Constraints":null,
                    "DispatchPayload":null,
                    "Driver":"recognize",
                    "Env":null,
                    "KillSignal":"",
                    "KillTimeout":5000000000,
                    "Kind":"",
                    "Leader":false,
                    "Lifecycle":null,
                    "LogConfig":{
                        "MaxFileSizeMB":10,
                        "MaxFiles":10
                    },
                    "Meta":null,
                    "Name":"redis",
                    "Resources":{
                        "CPU":100,
                        "Cores":0,
                        "Devices":null,
                        "DiskMB":0,
                        "IOPS":0,
                        "MemoryMB":300,
                        "MemoryMaxMB":0,
                        "Networks":null
                    },
                    "RestartPolicy":{
                        "Attempts":2,
                        "Delay":15000000000,
                        "Interval":1800000000000,
                        "Mode":"fail"
                    },
                    "ScalingPolicies":null,
                    "Services":null,
                    "ShutdownDelay":0,
                    "Templates":null,
                    "User":"",
                    "Vault":null,
                    "VolumeMounts":null
                }
            ],
            "Update":{
                "AutoPromote":false,
                "AutoRevert":false,
                "Canary":0,
                "HealthCheck":"checks",
                "HealthyDeadline":300000000000,
                "MaxParallel":1,
                "MinHealthyTime":10000000000,
                "ProgressDeadline":600000000000,
                "Stagger":30000000000
            },
            "Volumes":null
        }
    ],
    "Type":"service",
    "Update":{
        "AutoPromote":false,
        "AutoRevert":false,
        "Canary":0,
        "HealthCheck":"",
        "HealthyDeadline":0,
        "MaxParallel":1,
        "MinHealthyTime":0,
        "ProgressDeadline":0,
        "Stagger":30000000000
    },
    "VaultNamespace":"",
    "VaultToken":"",
    "Version":0
}
```
## v1/job/{job name}/allocations
```
curl 'http://localhost:4646/v1/job/recognize_redis_example/allocations' \
  -H 'Connection: keep-alive' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'Accept: */*' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost:4646/ui/jobs/run' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  --compressed
```
**resp**
``` 
[
    {
        "ClientDescription":"",
        "ClientStatus":"pending",
        "CreateIndex":15,
        "CreateTime":1645601194102268758,
        "DeploymentStatus":null,
        "DesiredDescription":"",
        "DesiredStatus":"run",
        "DesiredTransition":{
            "ForceReschedule":null,
            "Migrate":null,
            "Reschedule":null
        },
        "EvalID":"0af80e99-edfc-152d-ba25-360dbec37277",
        "FollowupEvalID":"",
        "ID":"32b37f6e-d177-8f8e-2c55-490dc5e0cf9d",
        "JobID":"recognize_redis_example",
        "JobType":"service",
        "JobVersion":0,
        "ModifyIndex":15,
        "ModifyTime":1645601194102268758,
        "Name":"recognize_redis_example.recognize_redis[0]",
        "Namespace":"default",
        "NodeID":"f83444e5-35cc-c65d-6e2a-cd0b6c8bcc47",
        "NodeName":"nomad",
        "PreemptedAllocations":null,
        "PreemptedByAllocation":"",
        "RescheduleTracker":null,
        "TaskGroup":"recognize_redis",
        "TaskStates":null
    }
]
```
## v1/job/{job name}/evaluations
```
curl 'http://localhost:4646/v1/job/recognize_redis_example/evaluations' \
  -H 'Connection: keep-alive' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'Accept: */*' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost:4646/ui/jobs/run' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  --compressed
```
**resp**
``` 
[
    {
        "CreateIndex":14,
        "CreateTime":1645601194094486985,
        "DeploymentID":"7b028d4d-e756-d61a-ed15-3852a0491fbd",
        "ID":"0af80e99-edfc-152d-ba25-360dbec37277",
        "JobID":"recognize_redis_example",
        "JobModifyIndex":14,
        "ModifyIndex":16,
        "ModifyTime":1645601194103311001,
        "Namespace":"default",
        "Priority":50,
        "QueuedAllocations":{
            "recognize_redis":0
        },
        "SnapshotIndex":14,
        "Status":"complete",
        "TriggeredBy":"job-register",
        "Type":"service"
    }
]
```
## /v1/jobs?namespace=default
```
curl 'http://localhost:4646/v1/jobs?namespace=default' \
  -H 'Connection: keep-alive' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'Accept: */*' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost:4646/ui/jobs/run' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  --compressed
```
**resp**
``` 
[
    {
        "CreateIndex":14,
        "Datacenters":[
            "dc1"
        ],
        "ID":"recognize_redis_example",
        "JobModifyIndex":14,
        "JobSummary":{
            "Children":{
                "Dead":0,
                "Pending":0,
                "Running":0
            },
            "CreateIndex":14,
            "JobID":"recognize_redis_example",
            "ModifyIndex":15,
            "Namespace":"default",
            "Summary":{
                "recognize_redis":{
                    "Complete":0,
                    "Failed":0,
                    "Lost":0,
                    "Queued":0,
                    "Running":0,
                    "Starting":1
                }
            }
        },
        "ModifyIndex":15,
        "Multiregion":null,
        "Name":"recognize_redis_example",
        "Namespace":"default",
        "ParameterizedJob":false,
        "ParentID":"",
        "Periodic":false,
        "Priority":50,
        "Status":"running",
        "StatusDescription":"",
        "Stop":false,
        "SubmitTime":1645601194094486985,
        "Type":"service"
    }
]
```
## v1/job/{job name}/allocations?index=15
```
curl 'http://localhost:4646/v1/job/recognize_redis_example/allocations?index=15' \
  -H 'Connection: keep-alive' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'Accept: */*' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost:4646/ui/jobs/run' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  --compressed
```
**resp**
``` 
[
    {
        "ClientDescription":"Tasks are running",
        "ClientStatus":"running",
        "CreateIndex":15,
        "CreateTime":1645601194102268758,
        "DeploymentStatus":null,
        "DesiredDescription":"",
        "DesiredStatus":"run",
        "DesiredTransition":{
            "ForceReschedule":null,
            "Migrate":null,
            "Reschedule":null
        },
        "EvalID":"0af80e99-edfc-152d-ba25-360dbec37277",
        "FollowupEvalID":"",
        "ID":"32b37f6e-d177-8f8e-2c55-490dc5e0cf9d",
        "JobID":"recognize_redis_example",
        "JobType":"service",
        "JobVersion":0,
        "ModifyIndex":17,
        "ModifyTime":1645601194225538585,
        "Name":"recognize_redis_example.recognize_redis[0]",
        "Namespace":"default",
        "NodeID":"f83444e5-35cc-c65d-6e2a-cd0b6c8bcc47",
        "NodeName":"nomad",
        "PreemptedAllocations":null,
        "PreemptedByAllocation":"",
        "RescheduleTracker":null,
        "TaskGroup":"recognize_redis",
        "TaskStates":{
            "redis":{
                "Events":[
                    {
                        "Details":{

                        },
                        "DiskLimit":0,
                        "DisplayMessage":"Task received by client",
                        "DownloadError":"",
                        "DriverError":"",
                        "DriverMessage":"",
                        "ExitCode":0,
                        "FailedSibling":"",
                        "FailsTask":false,
                        "GenericSource":"",
                        "KillError":"",
                        "KillReason":"",
                        "KillTimeout":0,
                        "Message":"",
                        "RestartReason":"",
                        "SetupError":"",
                        "Signal":0,
                        "StartDelay":0,
                        "TaskSignal":"",
                        "TaskSignalReason":"",
                        "Time":1645601194105068907,
                        "Type":"Received",
                        "ValidationError":"",
                        "VaultError":""
                    },
                    {
                        "Details":{
                            "message":"Building Task Directory"
                        },
                        "DiskLimit":0,
                        "DisplayMessage":"Building Task Directory",
                        "DownloadError":"",
                        "DriverError":"",
                        "DriverMessage":"",
                        "ExitCode":0,
                        "FailedSibling":"",
                        "FailsTask":false,
                        "GenericSource":"",
                        "KillError":"",
                        "KillReason":"",
                        "KillTimeout":0,
                        "Message":"Building Task Directory",
                        "RestartReason":"",
                        "SetupError":"",
                        "Signal":0,
                        "StartDelay":0,
                        "TaskSignal":"",
                        "TaskSignalReason":"",
                        "Time":1645601194106482600,
                        "Type":"Task Setup",
                        "ValidationError":"",
                        "VaultError":""
                    },
                    {
                        "Details":null,
                        "DiskLimit":0,
                        "DisplayMessage":"stating recognize process by filter type [net] and identify [127.0.0.1:6379]",
                        "DownloadError":"",
                        "DriverError":"",
                        "DriverMessage":"stating recognize process by filter type [net] and identify [127.0.0.1:6379]",
                        "ExitCode":0,
                        "FailedSibling":"",
                        "FailsTask":false,
                        "GenericSource":"",
                        "KillError":"",
                        "KillReason":"",
                        "KillTimeout":0,
                        "Message":"",
                        "RestartReason":"",
                        "SetupError":"",
                        "Signal":0,
                        "StartDelay":0,
                        "TaskSignal":"",
                        "TaskSignalReason":"",
                        "Time":-6795364578871345152,
                        "Type":"Driver",
                        "ValidationError":"",
                        "VaultError":""
                    },
                    {
                        "Details":{
                            "spec":"{\"cmdline\":\"redis-server *:6379\",\"cmdlineSlice\":\"redis-server *:6379\",\"exe\":\"/usr/local/bin/redis-server\",\"name\":\"redis-server\"}"
                        },
                        "DiskLimit":0,
                        "DisplayMessage":"finish recognized,recognized success [15805]",
                        "DownloadError":"",
                        "DriverError":"",
                        "DriverMessage":"finish recognized,recognized success [15805]",
                        "ExitCode":0,
                        "FailedSibling":"",
                        "FailsTask":false,
                        "GenericSource":"",
                        "KillError":"",
                        "KillReason":"",
                        "KillTimeout":0,
                        "Message":"",
                        "RestartReason":"",
                        "SetupError":"",
                        "Signal":0,
                        "StartDelay":0,
                        "TaskSignal":"",
                        "TaskSignalReason":"",
                        "Time":-6795364578871345152,
                        "Type":"Driver",
                        "ValidationError":"",
                        "VaultError":""
                    },
                    {
                        "Details":{

                        },
                        "DiskLimit":0,
                        "DisplayMessage":"Task started by client",
                        "DownloadError":"",
                        "DriverError":"",
                        "DriverMessage":"",
                        "ExitCode":0,
                        "FailedSibling":"",
                        "FailsTask":false,
                        "GenericSource":"",
                        "KillError":"",
                        "KillReason":"",
                        "KillTimeout":0,
                        "Message":"",
                        "RestartReason":"",
                        "SetupError":"",
                        "Signal":0,
                        "StartDelay":0,
                        "TaskSignal":"",
                        "TaskSignalReason":"",
                        "Time":1645601194206513932,
                        "Type":"Started",
                        "ValidationError":"",
                        "VaultError":""
                    },
                    {
                        "Details":{
                            "TaskName":"redis"
                        },
                        "DiskLimit":0,
                        "DisplayMessage":"takeover is disabled, complete the task after identify",
                        "DownloadError":"",
                        "DriverError":"",
                        "DriverMessage":"takeover is disabled, complete the task after identify",
                        "ExitCode":0,
                        "FailedSibling":"",
                        "FailsTask":false,
                        "GenericSource":"",
                        "KillError":"",
                        "KillReason":"",
                        "KillTimeout":0,
                        "Message":"",
                        "RestartReason":"",
                        "SetupError":"",
                        "Signal":0,
                        "StartDelay":0,
                        "TaskSignal":"",
                        "TaskSignalReason":"",
                        "Time":-6795364578871345152,
                        "Type":"Driver",
                        "ValidationError":"",
                        "VaultError":""
                    }
                ],
                "Failed":false,
                "FinishedAt":null,
                "LastRestart":null,
                "Restarts":0,
                "StartedAt":"2022-02-23T07:26:34.206515784Z",
                "State":"running",
                "TaskHandle":null
            }
        }
    }
]
```
## /v1/job/{job name}/deployment?index=1
```
curl 'http://localhost:4646/v1/job/recognize_redis_example/deployment?index=1' \
  -H 'Connection: keep-alive' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'Accept: */*' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost:4646/ui/jobs/run' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  --compressed
```
**resp**
``` 
{
    "CreateIndex":15,
    "ID":"7b028d4d-e756-d61a-ed15-3852a0491fbd",
    "IsMultiregion":false,
    "JobCreateIndex":14,
    "JobID":"recognize_redis_example",
    "JobModifyIndex":14,
    "JobSpecModifyIndex":14,
    "JobVersion":0,
    "ModifyIndex":15,
    "Namespace":"default",
    "Status":"running",
    "StatusDescription":"Deployment is running",
    "TaskGroups":{
        "recognize_redis":{
            "AutoPromote":false,
            "AutoRevert":false,
            "DesiredCanaries":0,
            "DesiredTotal":1,
            "HealthyAllocs":0,
            "PlacedAllocs":1,
            "PlacedCanaries":null,
            "ProgressDeadline":600000000000,
            "Promoted":false,
            "RequireProgressBy":"2022-02-23T07:36:34.102268758Z",
            "UnhealthyAllocs":0
        }
    }
}
```
## v1/job/{job name}/summary?index=1
```
curl 'http://localhost:4646/v1/job/recognize_redis_example/summary?index=1' \
  -H 'Connection: keep-alive' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'Accept: */*' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost:4646/ui/jobs/recognize_redis_example' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  --compressed
```
**resp**
``` {
    "Children":{
        "Dead":0,
        "Pending":0,
        "Running":0
    },
    "CreateIndex":14,
    "JobID":"recognize_redis_example",
    "ModifyIndex":15,
    "Namespace":"default",
    "Summary":{
        "recognize_redis":{
            "Complete":0,
            "Failed":0,
            "Lost":0,
            "Queued":0,
            "Running":0,
            "Starting":1
        }
    }
}```
# 事件抓取
```
curl 'http://localhost:4646/v1/allocation/a7dcc52d-46b4-244e-5de1-df72e8e43e1a?index=1' \
  -H 'Connection: keep-alive' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="98", "Google Chrome";v="98"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'Accept: */*' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Referer: http://localhost:4646/ui/allocations/a7dcc52d-46b4-244e-5de1-df72e8e43e1a' \
  -H 'Accept-Language: zh-CN,zh;q=0.9' \
  --compressed
```
响应参数：
```
{
    "AllocModifyIndex":11,
    "AllocatedResources":{
        "Shared":{
            "DiskMB":300,
            "Networks":null,
            "Ports":null
        },
        "TaskLifecycles":{
            "testkafka":null
        },
        "Tasks":{
            "testkafka":{
                "Cpu":{
                    "CpuShares":100,
                    "ReservedCores":null
                },
                "Devices":null,
                "Memory":{
                    "MemoryMB":300,
                    "MemoryMaxMB":0
                },
                "Networks":null
            }
        }
    },
    "ClientDescription":"Tasks are running",
    "ClientStatus":"running",
    "CreateIndex":11,
    "CreateTime":1645506633742024444,
    "DeploymentID":"288de190-12a0-f6b0-f42b-2afc5c52f076",
    "DeploymentStatus":{
        "Canary":false,
        "Healthy":true,
        "ModifyIndex":14,
        "Timestamp":"2022-02-22T05:10:43.869986811Z"
    },
    "DesiredStatus":"run",
    "EvalID":"47396a00-a2ca-b579-49eb-e900c0dece44",
    "ID":"a7dcc52d-46b4-244e-5de1-df72e8e43e1a",
    "Job":{
        "Affinities":null,
        "AllAtOnce":false,
        "Constraints":null,
        "ConsulNamespace":"",
        "ConsulToken":"",
        "CreateIndex":10,
        "Datacenters":[
            "dc1"
        ],
        "DispatchIdempotencyToken":"",
        "Dispatched":false,
        "ID":"recognize_example",
        "JobModifyIndex":10,
        "Meta":null,
        "ModifyIndex":10,
        "Multiregion":null,
        "Name":"recognize_example",
        "Namespace":"default",
        "NomadTokenID":"",
        "ParameterizedJob":null,
        "ParentID":"",
        "Payload":null,
        "Periodic":null,
        "Priority":50,
        "Region":"global",
        "Spreads":null,
        "Stable":false,
        "Status":"pending",
        "StatusDescription":"",
        "Stop":false,
        "SubmitTime":1645506633740456747,
        "TaskGroups":[
            {
                "Affinities":null,
                "Constraints":null,
                "Consul":{
                    "Namespace":""
                },
                "Count":1,
                "EphemeralDisk":{
                    "Migrate":false,
                    "SizeMB":300,
                    "Sticky":false
                },
                "Meta":null,
                "Migrate":{
                    "HealthCheck":"checks",
                    "HealthyDeadline":300000000000,
                    "MaxParallel":1,
                    "MinHealthyTime":10000000000
                },
                "Name":"kafka_test",
                "Networks":null,
                "ReschedulePolicy":{
                    "Attempts":0,
                    "Delay":30000000000,
                    "DelayFunction":"exponential",
                    "Interval":0,
                    "MaxDelay":3600000000000,
                    "Unlimited":true
                },
                "RestartPolicy":{
                    "Attempts":2,
                    "Delay":15000000000,
                    "Interval":1800000000000,
                    "Mode":"fail"
                },
                "Scaling":null,
                "Services":null,
                "ShutdownDelay":null,
                "Spreads":null,
                "StopAfterClientDisconnect":null,
                "Tasks":[
                    {
                        "Affinities":null,
                        "Artifacts":null,
                        "CSIPluginConfig":null,
                        "Config":{
                            "meta":[
                                {
                                    "cluster":"kafka_dc1",
                                    "region":"sg"
                                }
                            ],
                            "recognize":[
                                {
                                    "filter_type":"net",
                                    "target":"kafka",
                                    "identify":"127.0.0.1:6379"
                                }
                            ],
                            "takeover":[
                                {
                                    "succession_driver":"docker",
                                    "docker":[
                                        {
                                            "image":"",
                                            "args":[
                                                1,
                                                2,
                                                3
                                            ],
                                            "command":"this is command"
                                        }
                                    ],
                                    "enable":false
                                }
                            ]
                        },
                        "Constraints":null,
                        "DispatchPayload":null,
                        "Driver":"recognize",
                        "Env":null,
                        "KillSignal":"",
                        "KillTimeout":5000000000,
                        "Kind":"",
                        "Leader":false,
                        "Lifecycle":null,
                        "LogConfig":{
                            "MaxFileSizeMB":10,
                            "MaxFiles":10
                        },
                        "Meta":null,
                        "Name":"testkafka",
                        "Resources":{
                            "CPU":100,
                            "Cores":0,
                            "Devices":null,
                            "DiskMB":0,
                            "IOPS":0,
                            "MemoryMB":300,
                            "MemoryMaxMB":0,
                            "Networks":null
                        },
                        "RestartPolicy":{
                            "Attempts":2,
                            "Delay":15000000000,
                            "Interval":1800000000000,
                            "Mode":"fail"
                        },
                        "ScalingPolicies":null,
                        "Services":null,
                        "ShutdownDelay":0,
                        "Templates":null,
                        "User":"",
                        "Vault":null,
                        "VolumeMounts":null
                    }
                ],
                "Update":{
                    "AutoPromote":false,
                    "AutoRevert":false,
                    "Canary":0,
                    "HealthCheck":"checks",
                    "HealthyDeadline":300000000000,
                    "MaxParallel":1,
                    "MinHealthyTime":10000000000,
                    "ProgressDeadline":600000000000,
                    "Stagger":30000000000
                },
                "Volumes":null
            }
        ],
        "Type":"service",
        "Update":{
            "AutoPromote":false,
            "AutoRevert":false,
            "Canary":0,
            "HealthCheck":"",
            "HealthyDeadline":0,
            "MaxParallel":1,
            "MinHealthyTime":0,
            "ProgressDeadline":0,
            "Stagger":30000000000
        },
        "VaultNamespace":"",
        "VaultToken":"",
        "Version":0
    },
    "JobID":"recognize_example",
    "Metrics":{
        "AllocationTime":66628,
        "ClassExhausted":null,
        "ClassFiltered":null,
        "CoalescedFailures":0,
        "ConstraintFiltered":null,
        "DimensionExhausted":null,
        "NodesAvailable":{
            "dc1":1
        },
        "NodesEvaluated":1,
        "NodesExhausted":0,
        "NodesFiltered":0,
        "QuotaExhausted":null,
        "ResourcesExhausted":null,
        "ScoreMetaData":[
            {
                "NodeID":"00c16477-b643-1563-a3f1-abfb4d17a0e9",
                "NormScore":0.3043643439073376,
                "Scores":{
                    "binpack":0.3043643439073376,
                    "job-anti-affinity":0,
                    "node-reschedule-penalty":0,
                    "node-affinity":0
                }
            }
        ],
        "Scores":null
    },
    "ModifyIndex":14,
    "ModifyTime":1645506643988281869,
    "Name":"recognize_example.kafka_test[0]",
    "Namespace":"default",
    "NetworkStatus":{
        "Address":"",
        "DNS":null,
        "InterfaceName":""
    },
    "NodeID":"00c16477-b643-1563-a3f1-abfb4d17a0e9",
    "NodeName":"nomad",
    "Resources":{
        "CPU":100,
        "Cores":0,
        "Devices":null,
        "DiskMB":300,
        "IOPS":0,
        "MemoryMB":300,
        "MemoryMaxMB":300,
        "Networks":null
    },
    "SharedResources":{
        "CPU":0,
        "Cores":0,
        "Devices":null,
        "DiskMB":300,
        "IOPS":0,
        "MemoryMB":0,
        "MemoryMaxMB":0,
        "Networks":null
    },
    "TaskGroup":"kafka_test",
    "TaskResources":{
        "testkafka":{
            "CPU":100,
            "Cores":0,
            "Devices":null,
            "DiskMB":0,
            "IOPS":0,
            "MemoryMB":300,
            "MemoryMaxMB":0,
            "Networks":null
        }
    },
    "TaskStates":{
        "testkafka":{
            "Events":[
                {
                    "Details":{

                    },
                    "DiskLimit":0,
                    "DisplayMessage":"Task received by client",
                    "DownloadError":"",
                    "DriverError":"",
                    "DriverMessage":"",
                    "ExitCode":0,
                    "FailedSibling":"",
                    "FailsTask":false,
                    "GenericSource":"",
                    "KillError":"",
                    "KillReason":"",
                    "KillTimeout":0,
                    "Message":"",
                    "RestartReason":"",
                    "SetupError":"",
                    "Signal":0,
                    "StartDelay":0,
                    "TaskSignal":"",
                    "TaskSignalReason":"",
                    "Time":1645506633745401091,
                    "Type":"Received",
                    "ValidationError":"",
                    "VaultError":""
                },
                {
                    "Details":{
                        "message":"Building Task Directory"
                    },
                    "DiskLimit":0,
                    "DisplayMessage":"Building Task Directory",
                    "DownloadError":"",
                    "DriverError":"",
                    "DriverMessage":"",
                    "ExitCode":0,
                    "FailedSibling":"",
                    "FailsTask":false,
                    "GenericSource":"",
                    "KillError":"",
                    "KillReason":"",
                    "KillTimeout":0,
                    "Message":"Building Task Directory",
                    "RestartReason":"",
                    "SetupError":"",
                    "Signal":0,
                    "StartDelay":0,
                    "TaskSignal":"",
                    "TaskSignalReason":"",
                    "Time":1645506633746952369,
                    "Type":"Task Setup",
                    "ValidationError":"",
                    "VaultError":""
                },
                {
                    "Details":null,
                    "DiskLimit":0,
                    "DisplayMessage":"stating recognize process by filter type [net] and identify [127.0.0.1:6379]",
                    "DownloadError":"",
                    "DriverError":"",
                    "DriverMessage":"stating recognize process by filter type [net] and identify [127.0.0.1:6379]",
                    "ExitCode":0,
                    "FailedSibling":"",
                    "FailsTask":false,
                    "GenericSource":"",
                    "KillError":"",
                    "KillReason":"",
                    "KillTimeout":0,
                    "Message":"",
                    "RestartReason":"",
                    "SetupError":"",
                    "Signal":0,
                    "StartDelay":0,
                    "TaskSignal":"",
                    "TaskSignalReason":"",
                    "Time":-6795364578871345152,
                    "Type":"Driver",
                    "ValidationError":"",
                    "VaultError":""
                },
                {
                    "Details":{
                        "spec":"{\"cmdline\":\"/usr/bin/redis-server 127.0.0.1:6379\",\"cmdlineSlice\":\"/usr/bin/redis-server 127.0.0.1:6379       \",\"exe\":\"/usr/bin/redis-check-rdb\",\"name\":\"redis-server\"}"
                    },
                    "DiskLimit":0,
                    "DisplayMessage":"finish recognized,recognized success [812]",
                    "DownloadError":"",
                    "DriverError":"",
                    "DriverMessage":"finish recognized,recognized success [812]",
                    "ExitCode":0,
                    "FailedSibling":"",
                    "FailsTask":false,
                    "GenericSource":"",
                    "KillError":"",
                    "KillReason":"",
                    "KillTimeout":0,
                    "Message":"",
                    "RestartReason":"",
                    "SetupError":"",
                    "Signal":0,
                    "StartDelay":0,
                    "TaskSignal":"",
                    "TaskSignalReason":"",
                    "Time":-6795364578871345152,
                    "Type":"Driver",
                    "ValidationError":"",
                    "VaultError":""
                },
                {
                    "Details":{
    
                    },
                    "DiskLimit":0,
                    "DisplayMessage":"Task started by client",
                    "DownloadError":"",
                    "DriverError":"",
                    "DriverMessage":"",
                    "ExitCode":0,
                    "FailedSibling":"",
                    "FailsTask":false,
                    "GenericSource":"",
                    "KillError":"",
                    "KillReason":"",
                    "KillTimeout":0,
                    "Message":"",
                    "RestartReason":"",
                    "SetupError":"",
                    "Signal":0,
                    "StartDelay":0,
                    "TaskSignal":"",
                    "TaskSignalReason":"",
                    "Time":1645506633822348745,
                    "Type":"Started",
                    "ValidationError":"",
                    "VaultError":""
                },
                {
                    "Details":null,
                    "DiskLimit":0,
                    "DisplayMessage":"takeover is disabled, complete the task after identify",
                    "DownloadError":"",
                    "DriverError":"",
                    "DriverMessage":"takeover is disabled, complete the task after identify",
                    "ExitCode":0,
                    "FailedSibling":"",
                    "FailsTask":false,
                    "GenericSource":"",
                    "KillError":"",
                    "KillReason":"",
                    "KillTimeout":0,
                    "Message":"",
                    "RestartReason":"",
                    "SetupError":"",
                    "Signal":0,
                    "StartDelay":0,
                    "TaskSignal":"",
                    "TaskSignalReason":"",
                    "Time":-6795364578871345152,
                    "Type":"Driver",
                    "ValidationError":"",
                    "VaultError":""
                }
            ],
            "Failed":false,
            "FinishedAt":null,
            "LastRestart":null,
            "Restarts":0,
            "StartedAt":"2022-02-22T05:10:33.822350277Z",
            "State":"running",
            "TaskHandle":null
        }
    }
}

```