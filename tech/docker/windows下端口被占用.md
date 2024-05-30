
# 异常提示
```shell
Error response from daemon: Ports are not available: exposing port TCP 0.0.0.0:9848 -> 0.0.0.0:0: listen tcp 0.0.0.0:9848: bind: An attempt was made to access a socket in a way forbidden by its access permissions.
```
# 解决办法
> 重启nat服务
```bat
net stop winnat
net start winnat
```