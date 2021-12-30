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





参考:

https://www.nomadproject.io/docs/job-specification

