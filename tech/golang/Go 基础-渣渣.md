# Go 基础-渣渣

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