https://www.fanfan.show/2020/06/15/gin%E5%AD%A6%E4%B9%A0-%E4%BA%94-gin%E9%9B%86%E6%88%90swagger%E6%96%87%E6%A1%A3/
https://www.cnblogs.com/haima/p/14377191.html

## 注释说明
```
// IssueDetail function
// @Summary issue详情
// @version 1.0
// @Tags issue
// @Accept  json
// @Produce  json
// @Param id query int true "issue id"
// @Success 200  {object} models.Result{data=models.Issue} "成功后返回"
// @Router /issue/detail [get]
func IssueDetail(c *gin.Context) {
```
## 生成文档
swag init
## 默认地址
/swagger/index.html
## 问题记录
### Failed to load API definition.
> https://github.com/swaggo/gin-swagger/issues/146

### package ~ is not in GOROOT
GO111MODULE 

