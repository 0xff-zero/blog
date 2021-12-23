# Consul 安装及入门

## 安装

### 下载二进制包

官网地址：https://www.consul.io/downloads

下载`wget https://releases.hashicorp.com/consul/1.11.1/consul_1.11.1_linux_amd64.zip`

等待下载完成

### 解压到bin目录

```shell
unzip consul_1.11.1_linux_amd64.zip -d /usr/local/bin
```

> 方便直接在命令行访问

### 添加环境变量

```shell
# vim /etc/profile
export CONSUL_HOME=/usr/local/bin/consul
export PATH=$PATH:CONSUL_HOME


```



生效新的环境变量

`source /etc/profile`

### 验证

`consul --version`



## 入门

> 官方文档 https://www.consul.io/docs/agent/options.html

| 参数名称          | 用途                                                         |
| ----------------- | ------------------------------------------------------------ |
| -server           | 此标志用于控制代理是运行于服务器/客户端模式，每个 Consul 集群至少有一个服务器，正常情况下不超过5个，使用此标记的服务器参与 Raft一致性算法、选举等事务性工作 |
| -client           | 表示 Consul 绑定客户端接口的IP地址，默认值为：127.0.0.1，当你有多块网卡的时候，最好指定IP地址，不要使用默认值 |
| -bootstrap-expect | 预期的服务器集群的数量，整数，如 -bootstrap-expect=3，表示集群服务器数量为3台，设置该参数后，Consul将等待指定数量的服务器全部加入集群可用后，才开始引导集群正式开始工作，此参数必须与 -server 一起使用 |
| -data-dir         | 存储数据的目录，该目录在 Consul 程序重启后数据不会丢失，指定此目录时，应确保运行 Consul 程序的用户对该目录具有读写权限 |
| -node             | 当前服务器在集群中的名称，该值在整个 Consul 集群中必须唯一，默认值为当前主机名称 |
| -bind             | Consul 在当前服务器侦听的地址，如果您有多块网卡，请务必指定一个IP地址（IPv4/IPv6)，默认值为：0.0.0.0，也可用使用[::] |
| -datacenter       | 代理服务器运行的数据中心的名称，同一个数据中心中的 Consul 节点必须位于同一个 LAN 网络上 |
| -ui               | 启用当前服务器内部的 WebUI 服务器和控制台界面                |
| -join             | 该参数指定当前服务器启动时，加入另外一个代理服务器的地址，在默认情况下，如果不指定该参数，则当前代理服务器不会加入任何节点。可以多次指定该参数，以加入多个代理服务器， |
| -retry-join       | 用途和 -join 一致，当第一次加入失败后进行重试，每次加入失败后等待时间为 30秒 |
| -syslog           | 指定此标志意味着将记录 syslog，该参数在 Windows 平台不支持   |



## 启动

> 参考文档中启动的是三台，本文档只启动一台，伪集群

```shell
consul agent -server -ui -bootstrap-expect=3 -data-dir=/data/consul -node=agent-1 -client=0.0.0.0 -bind=172.16.1.218 -datacenter=dc1
```

上面的命令几乎无法再精简，简单来说，就是

指定了 consul（-server）

 集群有3台（-bootstrap-expect=3 ）

服务器（-node），

指定当前主机客户端侦听地址为（ -client=0.0.0.0 ），因为我有多块网卡，如果不指定，无法运行127.0.0.1。

绑定了当前主机的IP地址（-bind），

指定了一个数据中心的名称（-datacenter=dc1），

定了启用每台服务器的内置 WebUI 服务器组件（-ui）

> 后两台服务器在启动的时候加入第一台代理服务器（-join 172.16.1.218），同时指，当三台服务器都正确运行起来以后，Consul 集群将自动选举 leader，自动进行集群事务，无需干预

### 访问UI

http://10.12.220.51:8500/



参考：

https://www.cnblogs.com/viter/p/11018953.html



