# Nomad Schedulers

Nomad 有四个种类型的调度器，在创建不同类型的Job的时候使用:`service`/`batch`/`system`/`sysbatch`。接下来描述他们之间的差异。

## Service

service调度器是为长时间运行不挂掉的服务设计的。service调度器将大部分满足job约束的节点进行排名，然后选择最合适的节点将job部署上去。service使用的是google的borg的最佳拟合平均算法（best fit scoring algorithm）。对大量的候选节点进行排序，增加了调度时间，但是选择了最佳的job部署节点。



service类型的job的目标是一直运行，直到有明确的停止操作。如果一个service类型的task 失败退出，可以通过restart和reschedule机制处理。



## Batch

Batch 类型的job更多是对性能波动不敏感并且很短暂，几分钟或者几天完成。尽管batch 调度器和service非常类似，肯定对于batch的工作做了优化。主要区别是在找到符合job的节点后，它使用Berkeley Sparrow Scheduler 中描述的两个选型来限制排名的节点数。



Batch类型的job的目标是知道运行完成，成功退出。batch task异常突出，可以通过restart和reschedule进行处理。



## System

system 调度器会注册job到所有满足job条件的clients。当clients 加入集群或者状态变为ready的时候，都会调用system 调度器。这样所有已经注册的system jobs 会重新进行evaluation 然后task会放到新的满足job条件的可用的节点。

system 类型的调度器可以为部署和管理在集群中每个节点的job是非常高效的。这些任务都是Nomad管理的，可以很方便的进行更新、服务发现等等。



Nomad 0.9开始，如果没有足够容量防止系统job，system 调度器将会抢占在节点上运行符合条件的低优先级的job。如何抢占查看[文档详情](https://www.nomadproject.io/docs/internals/scheduling/preemption)

system job的目标是在没有操作或抢占明确停止就一直运行。如果system task 失败停止，可以通过restart 来处理；system job 是没有reschedule的。



## System batch

> system batch 调度器是Nomad 1.2 新加入的。

sysbatch 调度器会在所有的满足job条件的client节点上注册job，运行完成。sysbatch 调度器和system调度器的调度机制相似，但是batch job 在已经在成功存在，就不会在其他clients重新启动。



这个调度器可以用在集群的每个节点上执行“one off” 命令的场景。sysbatch job 也可以创建为 periodic 和parameterized 类型。这些task 都是用Nomad管理的，他们的升级、服务发现、监控等很方便。

sysbatch 调度器会抢占式的将低优先级的的task运行在容量不充足的节点上。抢占机制，看详细文章。

sysbatch job 的目标是一直运行到成功完成，操作人停止、抢占驱逐。sysbatch task 异常退出，可以通过重启处理。



