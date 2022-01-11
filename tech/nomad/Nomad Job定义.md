# Nomad Job定义

```shell
job "test_shell"{
	region="global"
	datacenters=["dc1"]
	# Specifies the Nomad scheduler to use. Nomad provides the service, system, batch, and sysbatch (new in Nomad 1.2) schedulers.
	type="service"
	group "echo" {
		count=1
		task "shell_log"{
		    #Specifies the task driver that should be used to run the task. See the driver documentation for what is available. Examples include docker, qemu, java and exec
			driver = "exec"
			config {
				command="/vagrant/hold.sh"
			}
		}
	}
}
```



## Job Specification

核心骨架结构：

job

  \

​     -group

​         \

​           -task

### job

| Placement | job  |
| --------- | ---- |

是job specification  配置的顶层节点。一个job就是生命一套描述文件，让Nomad可以运行。一个job有一个或多个task group，并且task group 自身包含一个或多个task。在每个region或者namespace 下必须是唯一的。示例如下：

```json
job "docs" {
  constraint {
    # ...
  }

  datacenters = ["us-east-1"]

  group "example" {
    # ...
  }

  meta {
    my-key = "my-value"
  }

  parameterized {
    # ...
  }

  periodic {
    # ...
  }

  priority = 100

  region = "north-america"

  task "docs" {
    # ...
  }

  update {
    # ...
  }
}
```

type (string:"servcie")   - 指定Nomad使用的调度器。Nomad提供了`service`/`system`/`batch`/`sysbatch(Nomad 1.2)`调度器。

detail:https://www.nomadproject.io/docs/job-specification/job

### group

| Placement | job -> group |
| --------- | ------------ |

定义一组需要在同一client节点上运行的task。所以的task都会在同一节点上运行。示例配置如：

```json
job "docs" {
  group "example" {
    # ...
  }
}

```





detail:

https://www.nomadproject.io/docs/job-specification/group

### task

>  detail:https://www.nomadproject.io/docs/job-specification/task

| Placement | job -> group -> task |
| --------- | -------------------- |

task 创建一个最小工作单元。如：一个docker container，一个web应用，或者几个进程。配置如下：

```json
job "docs" {
  group "example" {
    task "server" {
      # ...
    }
  }
}

```

driver - 指定运行所使用的task driver，详情可以查看[driver documentation](https://www.nomadproject.io/docs/drivers)哪些driver可用，如：docker，qemu,java 和 exec

env(Env:nil) - 指定环境变量会传入运行的进程中

config (map<string|string>:nil）- 指定直接传给driver的配置。配置会给每个driver，需要查看driver的文档详情。

leader（bool:false） - 指定task是否是taskgroup的lead任务。如果是true，当leader task 完成，分组内的其他task会优雅关闭。

### affinity[关联]

| Placement(位置) | job -> affinity<br>job -> group -> affinity<br>job -> group -> task -> affinity |
| --------------- | ------------------------------------------------------------ |

可以表达对node的选择偏好。也可能表达一些属性或者client的元数据。可以在上面的表格中东部同级别进行表达，例如：

```json
job "docs" {
  # Prefer nodes in the us-west1 datacenter
  affinity {
    attribute = "${node.datacenter}"
    value     = "us-west1"
    weight    = 100
  }

  group "example" {
    # Prefer the "r1" rack
    affinity {
      attribute  = "${meta.rack}"
      value     = "r1"
      weight    = 50
    }

    task "server" {
      # Prefer nodes where "my_custom_value" is greater than 5
      affinity {
        attribute = "${meta.my_custom_value}"
        operator  = ">"
        value     = "3"
        weight    = 50
      }
    }
  }
}
```



detail:https://www.nomadproject.io/docs/job-specification/affinity

### artifact

| Placement | job -> group -> task -> artifact |
| --------- | -------------------------------- |

主要是设置让Nomad从远端下载并加压源文件，像文件、tarball 或者 binary 。如果有权限，Nomad会通过`go-getter`从指定URL下载指定的不同的包。示例如：

```json
job "docs" {
  group "example" {
    task "server" {
      artifact {
        source      = "https://example.com/file.tar.gz"
        destination = "local/some-directory"
        options {
          checksum = "md5:df6a4178aec9fbdc1d6d7e3634d1bc33"
        }
      }
    }
  }
}
```

detail:https://www.nomadproject.io/docs/job-specification/artifact



### check_restart

| Placement | job -> group -> task -> service -> check_restart<br>**job -> group -> task -> service ->** check -> check_restart |
| --------- | ------------------------------------------------------------ |

在Nomad 0.7 `check_restart` 设置会在什么时候重启，不健康服务。如果一个服务的健康检测处暑超过`check_restart`中的`limit`的值，就会通过`restart policy`进行重启。`check_restart`中的设置会在checks中生效，但也可能出现在service中，在service范围内的 所有checks成效。如果在service和check中同时设置了，将会合并生效，并且check的中的优先级高。示例配置：

```json

job "mysql" {
  group "mysqld" {

    restart {
      attempts = 3
      delay    = "10s"
      interval = "10m"
      mode     = "fail"
    }

    task "server" {
      service {
        tags = ["leader", "mysql"]

        port = "db"

        check {
          type     = "tcp"
          port     = "db"
          interval = "10s"
          timeout  = "2s"
        }

        check {
          type     = "script"
          name     = "check_table"
          command  = "/usr/local/bin/check_mysql_table_status"
          args     = ["--verbose"]
          interval = "60s"
          timeout  = "5s"

          check_restart {
            limit = 3
            grace = "90s"
            ignore_warnings = false
          }
        }
      }
    }
  }
}

```

detail:

https://www.nomadproject.io/docs/job-specification/check_restart

### connect

| Placement | job -> group -> service -> connect |
| --------- | ---------------------------------- |





detail:

https://www.nomadproject.io/docs/job-specification/connect













参考:

https://www.nomadproject.io/docs/job-specification

