# Nomad 术语



## Nomad 中的对象名词



### job

定义一个或多个task group 

### job specification

Nomad的job specification (jopspec 代表缩写)定义了Nomad的job 概要 （schema）。可以描述job的类型、具体tasks和运行必须的资源，以及一些额外的信息（像约束，传播，弹性策略，consul信息等等）。

### task group

一组必须一起执行的task的定义。例如，一个web服务要求日志传输服务，同时运行。

是必须运行在同一个client节点上的，不能分隔的调度单元

一个运行的task group实例就是一个`allocation`

### task driver

一个task driver代表还行一个task的基本手段和方式。Nomad提供了几种的基本内置的driver：docker，QEMU、Java 和可执行包。Nomad通过插件机制也支持三方的Driver。

### task

一个task 是Nomad中的最小工作单元。Task都是被Nomad中所支持的 task类型的task drviers 执行的。task 会指定需要的driver，driver的配置，常量，以及资源。



### allocation

allocation 是task group 和 client node之间的一个映射。一个job可能有成百上千个task group，这样的情况下，也会有相当数量的的allocation 映射到client机器。allocation 是Nomadserver在进行一个evaluation期间作为调度的一部分创建的。如果必要，一个evaluation的结果就是就是一个allocation的变更。

### evaluation

evaluation 是Nomad做调度决策的机制。不管是job的预期状态或者是client的真实状态的变更，nomad会创建一个evaluation 然后决定是否必须执行的动作。

参考：

https://learn.hashicorp.com/tutorials/nomad/get-started-vocab?in=nomad/get-started