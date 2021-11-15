# Go 基础-渣渣

## Go 语言 goto、break、continue 三个语法

https://blog.csdn.net/u012265809/article/details/114874112

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
