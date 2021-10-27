# Go 故障记录

## 使用 gopsutil 报错 `fatal error: unexpected signal during runtime execution`

环境：Mac 

GoVersion:1.17

```go
v,_ := mem.VirtualMemory()
	fmt.Printf("Total:%v,Avaliable:%v,UsedPercent:%f%% \n",v.Total,v.Available,v.UsedPercent)
	fmt.Print(v)
```

报错：

`fatal error: unexpected signal during runtime execution`



**解决办法：**

参考：https://github.com/golang/go/issues/46763

将go降为1.16即可解决

