# Go 基础-渣渣

## go 多main函数编译

https://www.sunzhongwei.com/how-to-organize-golang-project-directory-make-a-project-contains-multiple-main-entrance-to-program

## go 是如何启动

https://www.cnblogs.com/qcrao-2018/p/11124360.html

https://blog.csdn.net/xz_studying/article/details/103107320

## go中的线程数量管理

https://colobu.com/2020/12/20/threads-in-go-runtime/

https://blog.csdn.net/u012807459/article/details/39754973

https://zhuanlan.zhihu.com/p/239817357

https://developer.51cto.com/art/202110/687260.htm

## go 协程的资源消耗

https://blog.csdn.net/u012279631/article/details/80486114

https://www.cnblogs.com/liang1101/p/7285955.html

## go 协程的退出

https://geektutu.com/post/hpg-exit-goroutine.html

## go 中的Condition

https://segmentfault.com/a/1190000039881684

https://geektutu.com/post/hpg-sync-cond.html

https://ieevee.com/tech/2019/06/15/cond.html

## go中的&和*

1. & 是取地址符号 , 即取得某个变量的地址 , 如 ; &a
2. *是指针运算符 , 可以表示一个变量是指针类型 , 也可以表示一个指针变量所指向的存储单元 , 也就是这个地址所存储的值 .

## go:nosplit 是什么

https://maiyang.me/post/2020-07-21-go-nosplit/

## Go test指定文件测试的时候无法加载包

https://www.cnblogs.com/Detector/p/10010292.html

## Go test执行指定文件指定方法

指定文件

```shell
go test -v hello_test.go
```



指定文件指定方法

```shell
$ go test -v hello_test.go -test.run TestHello
```

https://blog.csdn.net/cup_chenyubo/article/details/79231313

## Go 语言 goto、break、continue 三个语法

https://blog.csdn.net/u012265809/article/details/114874112

## 循环打印map

```go
scene := make(map[string]int)
scene["route"] = 66
scene["brazil"] = 4
scene["china"] = 960
for k, v := range scene {
    fmt.Println(k, v)
}
```

http://c.biancheng.net/view/32.html

## 命名循环

```go
func TestFor(t *testing.T){
	O:
		for i := 0; i < 10; i++ {
			fmt.Printf("outer:%d \n",i)
			INNER:
				for j := 0; j < 20; j++ {
					fmt.Printf("INNER : %d\n",j)
				if j>10{
					break O
				}else if j > 5 {
					break INNER
				}
			}
		}
}
```

为每个循环指定名称，可以跳出固定的循环

## 遍历map

```go
for key, value := range mapVar{
    //
}
```

```go
for key := range scene {
    
}
```



## 遍历切片

```go
for index, value := range slice {
    fmt.Printf("Index: %d Value: %d\n", index, value)
}
```



## GO RUNTIME.GOSCHED() 和 TIME.SLEEP(） 做协程切换

https://www.cnblogs.com/edenpans/p/5893451.html



## Go 通过反射读取类型

http://c.biancheng.net/view/109.html



## select 在for中

https://blog.csdn.net/u013474436/article/details/108583344



## select 的实现机制

https://blog.csdn.net/pengpengzhou/article/details/107036700

https://segmentfault.com/a/1190000022520711



## Go中select导致cpu 100%问题分析

https://blog.haohtml.com/archives/20017

https://jingwei.link/2019/05/26/golang-routine-scheduler.html

## select 的阻塞会占用CPU资源吗

不会消耗资源，具体分析见：https://jingwei.link/2019/05/26/golang-routine-scheduler.html





## 如何等待多个goroutine完成

https://www.bilibili.com/read/cv12238773





## Go项目脚手架

极度简单：https://github.com/soolaugust/go-toolkit



## Go 中的指针数组和数组指针

https://learnku.com/articles/44096





## Go定义枚举类型

https://cyent.github.io/golang/other/enum/

https://youwu.today/skill/backend/using-enum-in-golang/
