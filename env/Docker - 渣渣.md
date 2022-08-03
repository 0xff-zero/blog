# Docker - 渣渣

## 基础命令

启动一个镜像：

```shell
docker run -d {image}:{tag} -p{hostport}:{containerport} --name {containername}
```



## docker mysql 官方镜像的使用

https://itbilu.com/linux/docker/EyP7QP86M.html

## docker run 和exec差别

https://www.cnblogs.com/sddai/p/11032879.html

run 新启动一个容器

exec 可以在一个运行中的容器执行命令

## 镜像加速

在进行crd开发的时候，可能需要配置本地镜像仓库

 "insecure-registries": [
    "mock.com:5000"
  ]

国内加速

https://yeasy.gitbook.io/docker_practice/install/mirror
在/etc/docker/daemon.json增加
"registry-mirrors": [

"https://ung2thfc.mirror.aliyuncs.com",

"https://registry.docker-cn.com",

"http://hub-mirror.c.163.com",

"https://docker.mirrors.ustc.edu.cn"

]



## 容器中启动dbus

https://georgik.rocks/how-to-start-d-bus-in-docker-container/

https://www.coder.work/article/6895552