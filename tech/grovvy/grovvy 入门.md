# 入门

## grovvy 中的闭包
什么是闭包？
闭包其实就是一段代码段。在gradle中主要当做参数来使用
### 无参数闭包
```
def b1={
    println 'hello b1'
}

def m(Closure closure){
    closure()
}

m(b1)
```

### 有参数示例
```
def b2={
    v->
        println "hello ${v}"
}
def m2(Closure c){
    c("xiaoma")
}

m2(b2)
```