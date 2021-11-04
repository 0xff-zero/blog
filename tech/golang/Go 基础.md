# Go 基础

展示Go的基本使用

## Channel

> https://blog.csdn.net/winter_wu_1998/article/details/106657502

- 通道可以传输 int, string, 结构体，甚至是**接口类型变量，函数和另一个channel**
- 通道默认值是`nil`,需要通过make来初始化
- 通道传递是**拷贝值**
  -  对于大数据类型，可以**传递指针**以避免大量拷贝
    - 注意此时的并发安全，即**多个goroutine通过指针对原始值的并发操作**
    - 此时需要额外的同步操作（例如锁）来避免竞争

### 缓冲通道和无缓冲通道

- `ch := make(chan bool)`
  - **无缓存**的channel是**同步**的，阻塞式的
    - 必须等待两边都准备好才开始传递数据，否则堵塞
    - 一般用来**同步各个的goroutine**
  - 使用不当容易引发死锁
- `ch := make(chan int, 10)`
  - **有缓存**的channel是**异步**的，只有当缓冲区写满或读空时才堵塞
  - 等待的、所有接收操作所在的 goroutine，都会按照先后顺序被放入通道内部的接收等待队列
  - 可以发送或读取后，通道会**优先通知最早**因此而等待的goroutine

### 通道的关闭

- **channel 使用完后不关闭也没有关系**
  - 因为channel **没有被任何协程用到后会被自动回收**
  - **显式关闭** channel 一般是用来通知其他协程某个任务已经完成了
- **应该是生产者关闭通道，而不是消费者**
  - 否则生产者可能在channel关闭后写入，导致panic
  - 消费者在超时后应该通过channel向生产者发送完成消息，让生产者关闭channel并返回
- **关闭一个已经关闭的channel，或者往一个已经关闭的channel写入，都会panic**
  - 读取一个已经关闭**且没有数据**的通道会**立刻**返回一个**零值**
  - 读取时通过判断第二个返回值也可以判读收到的值**是否有效**
- **已经被关闭的通道不能往里面写入，但可以接受数据**

### 单向通道



- 多用于**函数的参数**, 提高安全性

  > 这种约束一般会出现在接口类型生命和函数生命汇总

  - 只能写入：`var send chan<- int`
  - 只能读取：`var recv <-chan int`

- 使用**for-range**循环读取channel

  - 从指定通道中读取数据**直到通道关闭(close)**

  - 如果生产者忘记关闭通道，则消费者会一直堵塞在for-range循环中

  - 如果`ch`值为`nil`,则会那么这条for语句就会被**永远地阻塞**在有for关键字的那一行

    

### 示例



### 原理

channel 本质是一个结构体。所谓的发送数据到channel 或者从channel消费数据，说白就是对这个结构体的操作

![](https://img-blog.csdnimg.cn/20210305162845924.png)

channel 可以用来无所编程，但是channel本身底层还是通过加锁实现的：

- 单词传递更多数据，可以改善因为频繁加锁造成的性能问题
- 例如把make(chan int , bufsize) 改为make（chan [blocksize]int,bufsize）,blocksize 是常量

![](https://img-blog.csdnimg.cn/2021030516293441.png)

### 例子

#### channel 作为函数的返回值

- 一般作为生产者，另起一个goroutine 并发生产，返回channel 用于消费

- 应该通过必报提供给消费者关闭该协程的函数

  > 使用defer把goroutine 的生命周期封装在生产函数中；
  >
  > 目的在于避免写入nil或者多次关闭channel

- 消费者只需要处理阻塞和零值，生产者负责在生产完毕后关闭channel

![](https://img-blog.csdnimg.cn/20200626094645325.png)

```go
func producer(gen func() int)(<-chan int,func()){
	ch:=make(chan int)
	done :=make(chan struct{})
	go func(){
		defer close(ch)
		for{
			select {
			case <- done:
				return
			default:
				ch <- gen()
			}
		}
	}()
	return ch,func(){close(done)}
}
```

#### 用`channel`进行同步

```go
type Stream struct{
cc chan struct{}	
}

func (s *Stream) Wait() error {
	<- s.cc
	// TODO
	return nil
}

func (s *Stream) Close() {
	close(s.cc)
}

func (s *Stream) IsClosed() bool{
	select {
	case <-s.cc:
		return true
	default:
		return false
	}
}
```

#### 实现信号量

```go
var wg sync.WaitGroup
sem := make(chan struct{}, 5) // 最多并发5个
for i := 0; i < 100; i++ {
    wg.Add(1)
    go func(id int) {
        defer wg.Done()
        sem <- struct{}{} // 获取信号量
        defer func() {
            <-sem // 释放信号量
        }()
    }(i)
}
wg.Wait()
```

#### 用channel 限制速度

```go
limiter:=time.Tick(time.Millisecond*200)
// 每200毫秒执行一次请求
for req:=range requests{
    <- limiter
    // req
}
```

#### 流水线函数写法

```go
func pipeline(in <- chan *Data,out chan<- *Data){
	for data :=range in{
		out <- process(data)
	}
}
// 使用
go pipeline(in,tmp)
go pipeline(tmp,out)

```

#### 并发安全队列

由于channel本身是一个并发安全队列，因此可以用作Pool

```go

type pool chan []int

func newPool(cap int) pool {
	return make(chan []int,cap)
}
func(p pool) get() []int{
	var v []int
	select {
	case v = <-p:
	default:
		v=make([]int,10)
		
	}
	return v
}
func(p pool) put(in []int){
	select {
	case p<-in:// 成功放回
	default:
		
	}
}
```



## Select

select 语句是转为为通道而设计的，所以每个case表达式中，都只能包含操作通道的表达式

select 默认阻塞，只有监听的cannel中有发送或者接受数据是才运行

> 设置default则不阻塞，通道内没有待接受的数据则执行default
>
> 如果不加default，则会有死锁的风险

多个channel准备好时，会随机选一个执行

![](https://img-blog.csdnimg.cn/20210222195943256.png)

select语句包含的候选分支中的case表达式都会在select语句执行开始时先被求值

- 所以time.After可以使用在select中
- 求值的顺序是依从代码编写的顺序从上到下
- 仅当select语句中的所有case表达式都被求值完毕后，它才会开始选择候选分支

如果我们想连续或定时地操作其中的通道的话，就需要通过在for语句中嵌入select语句的方式实现

> 简单的在select语句的分支中使用break语句，只能结束当前的select语句执行，而并不会对外层的for语句产生作用

select{} 永远阻塞

### 例子

#### 利用channel + select 来广播退出信息

- 每个子goroutine 利用select监听done通道
- 当主程序想要关闭子goroutine时，可以关闭done通道
- 此事select会立刻家你听到nil消息，子goroutine可以一次退出

```go
func Generate(done chan bool) chan int{
	ch:=make(chan int)
	go func() {
		defer close(ch)
		for {
			select {
			case ch<- rand.Int() :
				// ...
				case <- done: // 接受到通知并退出
					return
			}
		}
	}()
	return ch
}
done:=make(chan bool)
ch :=Generate(done)
fmt.Println(<-ch)//消费
close(done)
```

如果在select语句中发现某个分支的通道已关闭，那么这个分支会一直被执行

为了防止在此进入这个分支，可以把这个channel 重新赋值nil，这样这个calse就一直被阻塞

```go
for  {
		select {
		case x,open:=<-inCh1:
			if !open {
				inCh1=nil
				break
			}
			out <- x
		}
		if inCh1==nil {
			break
		}
	}
```

单个case的化简写法

```go
// bad
select {
case <- ch:
}
// good
<- ch

// bad
for {
    select {
    case x:= <-ch:
        _=x
    }
}
// good
for x:= range ch {
    // todo sth
}
```



