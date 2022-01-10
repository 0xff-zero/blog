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

一个task driver代表还行一个task的基本手段和方式。Nomad提供了几种的基本内置的driver



参考：

https://learn.hashicorp.com/tutorials/nomad/get-started-vocab?in=nomad/get-started