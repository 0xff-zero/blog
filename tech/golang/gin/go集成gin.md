# go 集成 gin

## 添加依赖
```
go get github.com/gin-gonic/gin
```
## 初始化服务器
```
func main() {
	fmt.Println("hello go main")
	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})
	r.Run()

}
```