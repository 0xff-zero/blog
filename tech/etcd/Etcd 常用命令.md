# Etcd 常用命令

## 启动命令：

```shell
/usr/local/bin/etcd-v3.4.3 \
  --name=infra-cephSdk-test-etcd-01 \
  --data-dir=/data/etcd/infra-cephSdk-test-infra-cephSdk-test-etcd-01 \
  --listen-peer-urls='http://10.129.100.199:2392' \
  --initial-advertise-peer-urls="http://10.129.100.199:2392" \
  --listen-client-urls='http://10.129.100.199:2391' \
  --advertise-client-urls="http://10.129.100.199:2391" \
  --initial-cluster="infra-cephSdk-test-etcd-01=http://10.129.100.199:2392,infra-cephSdk-test-etcd-02=http://10.129.100.231:2392,infra-cephSdk-test-etcd-03=http://10.129.100.232:2392" \
  --initial-cluster-token='infra-cephSdk-test' \
  --initial-cluster-state=new \
  --quota-backend-bytes=8589934592 \
  --enable-pprof \
  --metrics=extensive \
  --auto-compaction-mode=periodic \
  --auto-compaction-retention=24h
```

## 配置项说明：

--name：etcd集群中的节点名，这里可以随意，可区分且不重复就行

--listen-peer-urls：监听的用于节点之间通信的url，可监听多个，集群内部将通过这些url进行数据交互(如选举，数据同步等)

--initial-advertise-peer-urls：建议用于节点之间通信的url，节点间将以该值进行通信。

--listen-client-urls：监听的用于客户端通信的url，同样可以监听多个。

--advertise-client-urls：建议使用的客户端通信 url，该值用于 etcd 代理或 etcd 成员与 etcd 节点通信。

--initial-cluster-token： etcd-cluster-1，节点的 token 值，设置该值后集群将生成唯一 id，并为每个节点也生成唯一 id，当使用相同配置文件再启动一个集群时，只要该 token 值不一样，etcd 集群就不会相互影响。

--initial-cluster：也就是集群中所有的 initial-advertise-peer-urls 的合集。

--initial-cluster-state：new，新建集群的标志



## 常用操作命令

