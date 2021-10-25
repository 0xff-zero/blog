# Golang 中的Context

## 参考列表：

https://zhuanlan.zhihu.com/p/68792989

http://c.biancheng.net/view/5714.html

https://segmentfault.com/a/1190000022887010



在Go1.7之后，进入Go语言标准库中，准确的说是Goroutine的上下文，包含Goroutine的运行状态、环境、现场等信息。

## 什么是Context

"上下文"？很直接的一个表达，但是也很抽象。对于有开发经验的小伙伴可能能理出来其实是**一种状态**信息 的持有。比较术语的解释：程序单元的一个运行状态、现场、快照。其中上下是指存在上下层的传递，上会把内容传递给下，程序单元指的是Goroutine。



每个Goroutine在执行之前，都要先知道程序当前的执行状态，通常将这些执行状态封装在一个Context变量中，传递给要执行的Goroutine中；



## 源码



