# nginx- 渣渣

## location配置

```python
location ^~ / {
    root /xx/xx/; # 配置根路径
    index aa.html;# 配置启动文件
}
```



## nginx的默认配置文件路径

使用命令`nginx -t`可以查看主配置文件路径

