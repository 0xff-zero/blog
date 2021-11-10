# Go中make和new的原理

Go语言中 new 和 make 是两个内置函数，主要用来创建并分配类型的内存。在我们定义变量的时候，可能会觉得有点迷惑，不知道应该使用哪个函数来声明变量，其实他们的规则很简单：

- new 只分配内存

- make 只能用于 slice、map 和 channel 的初始化

  

下面我们就来具体介绍一下。

## new



## make



## 实现原理





## 最后

简单总结一下Go语言中 make 和 new 关键字的实现原理。

- make 关键字的主要作用是创建 slice、map 和 Channel 等内置的数据结构
-  new 的主要作用是为类型申请一片内存空间，并返回指向这片内存的指针。

参考：

http://c.biancheng.net/view/5722.html