# Nomad 的体系结构

> 原文地址：https://learn.hashicorp.com/tutorials/nomad/production-reference-architecture-vm-with-consul

This document provides recommended practices and a reference architecture for HashiCorp Nomad production deployments. This reference architecture conveys a general architecture that should be adapted to accommodate the specific needs of each implementation.

本文章为HashiCorp Nomad  在生产环境的部署提供了最佳实践和参考架构。这个通用架构应该可以满足不同的需求。

The following topics are addressed:

- [Reference Architecture](https://learn.hashicorp.com/tutorials/nomad/production-reference-architecture-vm-with-consul#ra)
- [Deployment Topology within a Single Region](https://learn.hashicorp.com/tutorials/nomad/production-reference-architecture-vm-with-consul#one-region)
- [Deployment Topology across Multiple Regions](https://learn.hashicorp.com/tutorials/nomad/production-reference-architecture-vm-with-consul#multi-region)
- [Network Connectivity Details](https://learn.hashicorp.com/tutorials/nomad/production-reference-architecture-vm-with-consul#net)
- [Deployment System Requirements](https://learn.hashicorp.com/tutorials/nomad/production-reference-architecture-vm-with-consul#system-reqs)
- [High Availability](https://learn.hashicorp.com/tutorials/nomad/production-reference-architecture-vm-with-consul#high-availability)
- [Failure Scenarios](https://learn.hashicorp.com/tutorials/nomad/production-reference-architecture-vm-with-consul#failure-scenarios)

文章主要从以下几个方面展开介绍：

- 参考架构
- 单区域部署拓扑
- 多区域部署拓扑
- 网络连接的详情
- 部署环境要求
- 高可用方案
- 失败场景

This document describes deploying a Nomad cluster in combination with, or with access to, a [Consul cluster](https://www.nomadproject.io/docs/integrations/consul-integration). We recommend the use of Consul with Nomad to provide automatic clustering, service discovery, health checking and dynamic configuration.



本文章的架构是Nomad集群是依赖Consul 集群进行部署的。可以依赖Consul 实现自动化，服务发现，健康检查和配置动态变更。



## Reference Architecture 参考架构

A Nomad cluster typically comprises three or five servers (but no more than seven) and a number of client agents. Nomad differs slightly from Consul in that it divides infrastructure into [regions](https://www.nomadproject.io/docs/internals/architecture#regions) which are served by one Nomad server cluster, but can manage multiple [datacenters](https://www.nomadproject.io/docs/internals/architecture#datacenters) or availability zones. For example, a *US Region* can include datacenters *us-east-1* and *us-west-2*.



Nomad集群通常包含3到5个节点（通常不超过7个）和许多客户端。Nomad集群和Consul 在进行基础设施分区管理上是有略微的不同，Nomad一个集群就可以管理多个数据中心或可用分区。比如：一个每个分区，可以包括一个美国东1区和美国西2区数据中心。

In a Nomad multi-region architecture, communication happens via [WAN gossip](https://www.nomadproject.io/docs/internals/gossip). Additionally, Nomad can integrate easily with Consul to provide features such as automatic clustering, service discovery, and dynamic configurations. Thus we recommend you use Consul in your Nomad deployment to simplify the deployment.

Nomad的多分区架构下，是通过 WAN gossip协议进行通信。另外Nomad可以通过Consul的自动化集群，服务发现和动态配置能力，实现一体化。因此我们建议在部署Nomad的时候通过Consul来简化部署。

In cloud environments, a single cluster may be deployed across multiple availability zones. For example, in AWS each Nomad server can be deployed to an associated EC2 instance, and those EC2 instances distributed across multiple AZs. Similarly, Nomad server clusters can be deployed to multiple cloud regions to allow for region level HA scenarios.

在云环境下，一个单独的集群可能是跨区部署的。比如，在AWS上每个Nomad 节点都是部署在相关的EC2实例上，这些实例可能是分布在不同的AZs中。类似，Nomad集群的节点可以部署在多个云上，实现HA的场景。

For more information on Nomad server cluster design, see the [cluster requirements documentation](https://www.nomadproject.io/docs/install/production/requirements).

更多Namod 集群的设计，可以参考[cluster requirements documentation](https://www.nomadproject.io/docs/install/production/requirements)

The design shared in this document is the recommended architecture for production environments, as it provides flexibility and resilience. Nomad utilizes an existing Consul server cluster; however, the deployment design of the Consul server cluster is outside the scope of this document.

在Nomad集群设计的文章中要求生产环境的部署架构，需要可以满足灵活和弹性。Nomad依赖了Consul 集群；但是文章并没有介绍Consul的部署。

Nomad to Consul connectivity is over HTTP and should be secured with TLS as well as a Consul token to provide encryption of all traffic. This is done using Nomad's [Automatic Clustering with Consul](https://learn.hashicorp.com/tutorials/nomad/clustering).

Nomad到Consul是通过HTTP进行连接的，所有的网络传输都是通过TLS加密的,和Consul 的token加密机制是一样的。这些都已经支持了[Automatic Clustering with Consul](https://learn.hashicorp.com/tutorials/nomad/clustering)。

## Deployment topology within a single region 单区域部署拓扑

A single Nomad cluster is recommended for applications deployed in the same region.

这种场景下，只有一个单独的Nomad集群，在同一区域内进行应用部署。

Each cluster is expected to have either three or five servers. This strikes a balance between availability in the case of failure and performance, as [Raft](https://raft.github.io/) consensus gets progressively slower as more servers are added.

每个集群都希望有3或5个服务节点。这是在失败和性能之前平衡的一个选择，就像Raft协议在达成共识的过程中，节点越多越慢是一样的。

**参考图**

![](https://gitee.com/lidaming/assets/raw/master/nomad/nomad_reference_diagram.png)

## Deployment topology across multiple regions 跨区域部署

By deploying Nomad server clusters in multiple regions, the user is able to interact with the Nomad servers by targeting any region from any Nomad server even if that server resides in a separate region. However, most data is not replicated between regions as they are fully independent clusters. The exceptions which *are* replicated between regions are:

- [ACL policies and global tokens](https://learn.hashicorp.com/tutorials/nomad/access-control-bootstrap)
- [Sentinel policies in Nomad Enterprise](https://learn.hashicorp.com/tutorials/nomad/sentinel)

通过在多个区域中部署Nomad集群，即使某个服务器主流在单独的区域中，用户也能够通过针对来自任何区域的任何Nomad服务器与Nomad服务器进行交互。

- [ACL policies and global tokens](https://learn.hashicorp.com/tutorials/nomad/access-control-bootstrap) 
- [Sentinel policies in Nomad Enterprise](https://learn.hashicorp.com/tutorials/nomad/sentinel)

Nomad server clusters in different datacenters can be federated using WAN links. The server clusters can be joined to communicate over the WAN on port `4648`. This same port is used for single datacenter deployments over LAN as well.

在不同数据中心的Nomad服务器可以通过广域网相互连接。服务器通过加入 广域网4648端口进行通信。一个数据中心的局域网（本地网）也可以通过4648端口进行通信。

Additional documentation is available to learn more about Nomad cluster [federation](https://learn.hashicorp.com/tutorials/nomad/federation).

需要了解[Nomad集群联盟](https://learn.hashicorp.com/tutorials/nomad/federation)的可以看另外的文档

## Network connectivity details 网络链接详情

![](https://gitee.com/lidaming/assets/raw/master/nomad/nomad_network_arch_0-1x.png)

Nomad servers are expected to be able to communicate in high bandwidth, low latency network environments and have below 10 millisecond latencies between cluster members. Nomad servers can be spread across cloud regions or datacenters if they satisfy these latency requirements.

Nomad服务器集群节点内需要高带宽、低延迟网络的环境，在集群内的节点应该保证延迟在10ms以内。在网络延迟能满足要求的话，Nomad集群也是可以部署在跨云分区或数据中心环境下的。

Nomad client clusters require the ability to receive traffic as noted in the Network Connectivity Details; however, clients can be separated into any type of infrastructure (multi-cloud, on-prem, virtual, bare metal, etc.) as long as they are reachable and can receive job requests from the Nomad servers.

Nomad客户端集群需要能够接收网络链接细节描述的流量。但是，只要他们到达，客户端可以分离为任何类型的基础架构（多云、可覆盖、虚拟、裸机等等），并且可以从Nomad服务器接收作业请求。

Additional documentation is available to learn more about [Nomad networking](https://www.nomadproject.io/docs/install/production/requirements/#network-topology).

需要了解更多信息，可以阅读[Nomad网络](https://www.nomadproject.io/docs/install/production/requirements/#network-topology)

## Deployment system requirements 环境要求

Nomad server agents are responsible for maintaining the cluster state, responding to RPC queries (read operations), and for processing all write operations. Given that Nomad server agents do most of the heavy lifting, server sizing is critical for the overall performance efficiency and health of the Nomad cluster.

Nomad agent 的主要职责：维护集群状态、支持RPC查询（读取操作）和处理所有的写操作。鉴于Nomad 代理执行了大部分繁重的读写操作，服务器的性能对于Nomad集群的整体性能效率和集群健康至关重要。

**Nomad Servers 服务器**

---

| Type  | CPU       | Memory       | Disk   | Typical Cloud Instance Types               |
| :---- | :-------- | :----------- | :----- | :----------------------------------------- |
| Small | 2-4 core  | 8-16 GB RAM  | 50 GB  | **AWS**: m5.large, m5.xlarge               |
|       |           |              |        | **Azure**: Standard_D2_v3, Standard_D4_v3  |
|       |           |              |        | **GCP**: n2-standard-2, n2-standard-4      |
| Large | 8-16 core | 32-64 GB RAM | 100 GB | **AWS**: m5.2xlarge, m5.4xlarge            |
|       |           |              |        | **Azure**: Standard_D8_v3, Standard_D16_v3 |
|       |           |              |        | **GCP**: n2-standard-8, n2-standard-16     |

**Hardware sizing considerations 硬件大小的考量 **

- The small size would be appropriate for most initial production deployments, or for development/testing environments. 对于较小的服务器可以用在新的生产环境、或者开发/测试环境。
- The large size is for production environments where there is a consistently high workload. 大服务器应该用在一般负载比较高的生产环境。

> **NOTE:** For large workloads, ensure that the disks support a high number of IOPS to keep up with the rapid Raft log update rate.
>
> 对于很高负载的环境，应该保证磁盘支持高 IOPS 支持Raft log的高频更新。

Nomad clients can be setup with specialized workloads as well. For example, if workloads require GPU processing, a Nomad datacenter can be created to serve those GPU specific jobs and joined to a Nomad server cluster. For more information on specialized workloads, see the documentation on [job constraints](https://www.nomadproject.io/docs/job-specification/constraint) to target specific client nodes.

Nomad客户端也可以设置专门的工作负载。例如，如果某些工作需要GPU处理，则可以创建一个Nomad数据中心，提供GPU处理能力，并加入到Nomad集群。了解更多关于约束性Job指定特定的客户端节点的信息，可以查看[Job 约束](https://www.nomadproject.io/docs/job-specification/constraint)

## High availability 高可用

A Nomad server cluster is the highly available unit of deployment within a single datacenter. A recommended approach is to deploy a three or five node Nomad server cluster. With this configuration, during a Nomad server outage, failover is handled immediately without human intervention.

部署在一个数据中心的Nomad集群是一个高可用单元。推荐一个Nomad 集群部署3或5个节点。这样的话，如果一个Nomad服务宕机，在没有人为干预的情况可以可以迅速回复。



When setting up high availability across regions, multiple Nomad server clusters are deployed and connected via WAN gossip. Nomad clusters in regions are fully independent from each other and do not share jobs, clients, or state. Data residing in a single region-specific cluster is not replicated to other clusters in other regions.

当进行跨区高可用部署的时候，多个Nomad集群通过gossip协议在广域网进行联通。区域中的Nomad集群彼此完全独立，不同享工作、客户端和状态。数据留存在一个单独固定的分区集群中，不会在其他分区的集群中产生副本。



## Failure scenarios 失败场景

Typical distribution in a cloud environment is to spread Nomad server nodes into separate Availability Zones (AZs) within a high bandwidth, low latency network, such as an AWS Region. The diagram below shows Nomad servers deployed in multiple AZs promoting a single voting member per AZ and providing both AZ-level and node-level failure protection.

云环境中的典型分布是将Named 节点部署在高带宽、低延迟网络（如AWS区域）内的单独可用性区域（AZ）。下图展示了分区部署的Nomad集群，每个AZ中的单独投票成员，在AZ级别和节点级别的失败保护。

![](https://gitee.com/lidaming/assets/raw/master/nomad/nomad_fault_tolerance.png)

Additional documentation is available to learn more about [cluster sizing and failure tolerances](https://www.nomadproject.io/docs/internals/consensus#deployment_table) as well as [outage recovery](https://learn.hashicorp.com/tutorials/nomad/outage-recovery).

需要了解更多可以阅读[集群大小和失败保护](https://www.nomadproject.io/docs/internals/consensus#deployment_table) 和 [断电保护](https://learn.hashicorp.com/tutorials/nomad/outage-recovery)



### Availability zone failure 可用分区失败

In the event of a single AZ failure, only a single Nomad server is affected which would not impact job scheduling as long as there is still a Raft quorum (that is, 2 available servers in a 3 server cluster, 3 available servers in a 5 server cluster, more generally:

quorum = floor( count(members) / 2) + 1

在单个分区失败的情况下，如果只有一个节点受影响，只要仍然满足 Raft 可用成员 (3个节点还有两个节点存活，5个几点还有三个几点存活)是不会影响到作业调度的，通用计算公式：

quorum = floor( count(members) / 2) + 1

There are two scenarios that could occur should an AZ fail in a multiple AZ setup: leader loss or follower loss.

在多AZ下，一个AZ失败有两种场景：leader 丢失、follower 丢失

**Leader server loss 主server丢失**

If the AZ containing the Nomad leader server fails, the remaining quorum members would elect a new leader. The new leader then begins to accept new log entries and replicates these entries to the remaining followers.

如果AZ中没有了Nomad主服务器，剩下的节点会选举一个新的主节点。新的主节点就会开始接收请求，并且复制日志到其他从节点。

**Follower server loss 从节点丢失**

If the AZ containing a Nomad follower server fails, there is no immediate impact to the Nomad leader server or cluster operations. However, there still must be a Raft quorum in order to properly manage a future failure of the Nomad leader server.

如果AZ中的的从节点失败，不会对Nomad主节点产生影响，也不会影响集群操作。但是，仍然需要保障Raft成员，以确保在未来集群主节点失败的情况。

### Region failure 分区失败

In the event of a region-level failure (which would contain an entire Nomad server cluster), clients are still be able to submit jobs to another region that is properly federated. However, data loss is likely as Nomad server clusters do not replicate their data to other region clusters. See [Multi-region Federation](https://learn.hashicorp.com/tutorials/nomad/federation) for more setup information.

在整个分区级别是失败的情况下（整个Nomad集群都失败），联盟没问题的情况下，客户端是可以正常提交作业的。但是，因为Nomad集群不会向联盟的其他分区进行数据副本，所以会丢失数据。了解更多信息可以阅读[多分区联盟](https://learn.hashicorp.com/tutorials/nomad/federation)



## 单词积累

### maintain

**v.**维护；保持；坚持；维持…关系

### be appropriate for 

**na.**适于



### consistently

**adv.**一向

### constraints

**n.**约束；强迫；强制力；紧张感[状态]

### recommend

**v.**推荐；劝；托；(行为,性质)使人欢喜

### approach

**n.**方法；接近；路径；道路

**v.**接近；建议；接洽；着手处理



recommended approach 推荐方法



### intervention

**n.**干预；介入；调解



### reside

**v.**住；(官吏)留驻；(性质)存在；(权力,权利等)属于

### typical

**adj.**典型的；有代表性的；一贯的；平常的

### spread

- **n.**传播；蔓延；扩展；散布
- **v.**传播；扩散；展开；散布
- **adj.**广大的；大幅的；(宝石)薄而无光泽的

### promote

**v.**促进；提升；振兴；宣传



### tolerance

**n.**忍受；容忍；宽容；耐性



### quorum

**n.**（会议的）法定人数

