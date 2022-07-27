# Nomad 启动和任务执行分析

依赖[consul](https://www.consul.io/)

## 架构分析

### 依赖架构

https://learn.hashicorp.com/tutorials/nomad/production-reference-architecture-vm-with-consul

#### 部署拓扑

![](https://gitee.com/lidaming/assets/raw/master/nomad/nomad_reference_diagram.png)

Nomad角色：Server(Leader,Follower),Client

> [官网介绍](https://learn.hashicorp.com/tutorials/nomad/get-started-vocab?in=nomad/get-started)

​	Server 和Client 是Nomad在不同的形式下运行,承担不同的职责：

Server：

1. 整个集群的大脑；管理所有的jobs和client，运行evaluations，创建task alloctions
2. 每个region至少有一个server
3. Server之间互相作为备份，并且选举出来Leader，保障集群的HA
4. 一个region的server是同一个组

Leader：负责集群中一台Server，负责集群的大部分管理工作

1. 执行plan
2. 派生Vault Tokens
3. 维护集群状态

Follower: 非Leader的Server

1. 创建调度计划（scheduling plans）,提交给Leader
2. 为集群提供更多的调度容量



Client:以client模式运行的agent

1. 注册服务信息到server
2. 监听派发给自身节点的任务
3. 执行任务



#### 网络链接详情



![](https://gitee.com/lidaming/assets/raw/master/nomad/nomad_network_arch_0-1x.png)

网络详情：https://www.nomadproject.io/docs/install/production/requirements#network-topology

Nomad 集群需要高带宽，低延迟网络环境，集群内的延迟10ms内，在跨云跨中心部署的时候，需要满足这些网络条件。

#### 多中心

![](https://gitee.com/lidaming/assets/raw/master/nomad/nomad_fault_tolerance.png)



### 软件架构

#### 模块依赖

client模式下，核心能力是接收来自Server端分发的任务，并在客户端执行，Client运行时的客户端大致结构如图：

![](https://gitee.com/lidaming/assets/raw/master/nomad/code_analyze/nomad%20class-pkg%20depend.drawio.png)



启动流程，在后续进行介绍。

**Alloctions 处理模块：**

AllocRunner 是在接收到Server分配的Alloctions后，根据Alloctions 具体内容进行AllocRunner创建的，会持有支持的插件的Manager、`TaskRunner`

TaskRunner 会在AllocRunner 创建的时候，被调用创建相应的TaskRunner, TaskerRunner 在创建的时候，会执行Driver的发现



**执行[插件]模块：**

整个模块分为内置和扩展，两个大类。

内置的有：exec/java/rawexec/docker/qemu

扩展的社区也提供了很多。

内置的实现直接进行插件注册。扩展的通过go-plugin机制进行加载，本地sock调用

#### 类依赖

类图展示了，Client模式下的核心依赖：



![](https://gitee.com/lidaming/assets/raw/master/nomad/code_analyze/nomad%20class-class%20diagram.drawio.png)



核心接口：

BasePlugin 抽象出来的所有插件必须支持的的接口，包含方法：`PluginInfo()(*PluginInfoResponse,error)`、`ConfigSchema()(*hclspec.Spec,error)`、`SetConfig(*Config)`

CSIPlugin 围绕CSI插件实现了一个轻量级的抽象层；继承了BasePlugin

DevicePlugin 可以将检测到的设备暴露给 Nomad 并通知它如何安装它们；继承了BasePlugin

**DriverPlugin** 所有driver都要实现的一个接口抽象,也由代理调用 go-plugin 的插件客户端实现；继承了BasePlugin

PluginManager 主要负责管理和编排一组插件的生命周期，包含方法：`Run()`、`Shutdown()`、`PluginType()`

PluginCatalog 主要抽象了获取接口的能力，包含方法：`Dispense(..)(PluginInstance,error)`、`Reattach(..)(PluginInstance,error)`、`Catalog()map[string]PluginInfoResponse`



#### 任务分发时序

![](https://gitee.com/lidaming/assets/raw/master/nomad/code_analyze/nomad%20class-alloc%20seqence.drawio.png)



## 核心流程

###  启动流程



Agent Client的启动整体流程如图：

![](https://gitee.com/lidaming/assets/raw/master/nomad/code_analyze/Nomad%20Code-Agent-client%20start%20flow.drawio.png)

启动命令使用的是：`nomad agent -c /etch/nomad.d`使用一级命令`agent`，且指定了配置文件目录参数，启动的核心流程里面包含：

1. 初始化Agent
   1. 初始化ConsulService
   2. 加载插件
   3. 初始化Server
   4. 初始化Client
2. 初始化HttpServer



初始化Client完成后，会根据配置注册自身到Consul。

在初始化Client的时候，会执行：

1. 加载客户端配置（证书、日志、Server地址、目录等）
2. 注册内置的动态CSI插件控制器
3. Client的RPC服务
4. 加载插件
5. 启动周期性的，心跳、gc、token保活等
6. 启动client，执行alloc监听等

### 任务执行流程

![](https://gitee.com/lidaming/assets/raw/master/nomad/code_analyze/Nomad%20Code-Agent-Alloc%20flow.drawio.png)

### 插件启动任务流程

#### 基础流程

![](https://gitee.com/lidaming/assets/raw/master/nomad/code_analyze/nomad%20class-driver%20flow.drawio.png)

#### docker流程

![](https://gitee.com/lidaming/assets/raw/master/nomad/code_analyze/nomad%20class-docker%20start%20task.drawio.png)

#### exec 流程

![](https://gitee.com/lidaming/assets/raw/master/nomad/code_analyze/nomad%20class-exec%20startTask.drawio.png)

exec 和raw_exec流程基本相同，差异点：

1. 启用配置不同
2. 对于cgroup逻辑处理有差异



## 代码分析

### 启动流程核心代码

#### 初始化：

```go
_ "github.com/hashicorp/nomad/client/logmon"
_ "github.com/hashicorp/nomad/drivers/docker/docklog"
_ "github.com/hashicorp/nomad/drivers/shared/executor"
```

#### Commands 构建

> 启动命令：`/usr/local/bin/nomad agent -config /etc/nomad.d`

```go
// Commands returns the mapping of CLI commands for Nomad. The meta
// parameter lets you set meta options for all commands.
func Commands(metaPtr *Meta, agentUi cli.Ui) map[string]cli.CommandFactory {
	if metaPtr == nil {
		metaPtr = new(Meta)
	}

	meta := *metaPtr
	if meta.Ui == nil {
		meta.Ui = &cli.BasicUi{
			Reader:      os.Stdin,
			Writer:      colorable.NewColorableStdout(),
			ErrorWriter: colorable.NewColorableStderr(),
		}
	}

	all := map[string]cli.CommandFactory{
		"acl": func() (cli.Command, error) {
			return &ACLCommand{
				Meta: meta,
			}, nil
		},
		"acl bootstrap": func() (cli.Command, error) {
			return &ACLBootstrapCommand{
				Meta: meta,
			}, nil
		},
		"acl policy": func() (cli.Command, error) {
			return &ACLPolicyCommand{
				Meta: meta,
			}, nil
		},
		"acl policy apply": func() (cli.Command, error) {
			return &ACLPolicyApplyCommand{
				Meta: meta,
			}, nil
		},
		"acl policy delete": func() (cli.Command, error) {
			return &ACLPolicyDeleteCommand{
				Meta: meta,
			}, nil
		},
		"acl policy info": func() (cli.Command, error) {
			return &ACLPolicyInfoCommand{
				Meta: meta,
			}, nil
		},
		"acl policy list": func() (cli.Command, error) {
			return &ACLPolicyListCommand{
				Meta: meta,
			}, nil
		},
		"acl token": func() (cli.Command, error) {
			return &ACLTokenCommand{
				Meta: meta,
			}, nil
		},
		"acl token create": func() (cli.Command, error) {
			return &ACLTokenCreateCommand{
				Meta: meta,
			}, nil
		},
		"acl token update": func() (cli.Command, error) {
			return &ACLTokenUpdateCommand{
				Meta: meta,
			}, nil
		},
		"acl token delete": func() (cli.Command, error) {
			return &ACLTokenDeleteCommand{
				Meta: meta,
			}, nil
		},
		"acl token info": func() (cli.Command, error) {
			return &ACLTokenInfoCommand{
				Meta: meta,
			}, nil
		},
		"acl token list": func() (cli.Command, error) {
			return &ACLTokenListCommand{
				Meta: meta,
			}, nil
		},
		"acl token self": func() (cli.Command, error) {
			return &ACLTokenSelfCommand{
				Meta: meta,
			}, nil
		},
		"alloc": func() (cli.Command, error) {
			return &AllocCommand{
				Meta: meta,
			}, nil
		},
		"alloc exec": func() (cli.Command, error) {
			return &AllocExecCommand{
				Meta: meta,
			}, nil
		},
		"alloc signal": func() (cli.Command, error) {
			return &AllocSignalCommand{
				Meta: meta,
			}, nil
		},
		"alloc stop": func() (cli.Command, error) {
			return &AllocStopCommand{
				Meta: meta,
			}, nil
		},
		"alloc fs": func() (cli.Command, error) {
			return &AllocFSCommand{
				Meta: meta,
			}, nil
		},
		"alloc logs": func() (cli.Command, error) {
			return &AllocLogsCommand{
				Meta: meta,
			}, nil
		},
		"alloc restart": func() (cli.Command, error) {
			return &AllocRestartCommand{
				Meta: meta,
			}, nil
		},
		"alloc status": func() (cli.Command, error) {
			return &AllocStatusCommand{
				Meta: meta,
			}, nil
		},
		"alloc-status": func() (cli.Command, error) {
			return &AllocStatusCommand{
				Meta: meta,
			}, nil
		},
		"agent": func() (cli.Command, error) {
			return &agent.Command{
				Version:    version.GetVersion(),
				Ui:         agentUi,
				ShutdownCh: make(chan struct{}),
			}, nil
		},
		"agent-info": func() (cli.Command, error) {
			return &AgentInfoCommand{
				Meta: meta,
			}, nil
		},
		"check": func() (cli.Command, error) {
			return &AgentCheckCommand{
				Meta: meta,
			}, nil
		},
		// operator debug was released in 0.12 as debug. This top-level alias preserves compatibility
		"debug": func() (cli.Command, error) {
			return &OperatorDebugCommand{
				Meta: meta,
			}, nil
		},
		"deployment": func() (cli.Command, error) {
			return &DeploymentCommand{
				Meta: meta,
			}, nil
		},
		"deployment fail": func() (cli.Command, error) {
			return &DeploymentFailCommand{
				Meta: meta,
			}, nil
		},
		"deployment list": func() (cli.Command, error) {
			return &DeploymentListCommand{
				Meta: meta,
			}, nil
		},
		"deployment pause": func() (cli.Command, error) {
			return &DeploymentPauseCommand{
				Meta: meta,
			}, nil
		},
		"deployment promote": func() (cli.Command, error) {
			return &DeploymentPromoteCommand{
				Meta: meta,
			}, nil
		},
		"deployment resume": func() (cli.Command, error) {
			return &DeploymentResumeCommand{
				Meta: meta,
			}, nil
		},
		"deployment status": func() (cli.Command, error) {
			return &DeploymentStatusCommand{
				Meta: meta,
			}, nil
		},
		"deployment unblock": func() (cli.Command, error) {
			return &DeploymentUnblockCommand{
				Meta: meta,
			}, nil
		},
		"eval": func() (cli.Command, error) {
			return &EvalCommand{
				Meta: meta,
			}, nil
		},
		"eval status": func() (cli.Command, error) {
			return &EvalStatusCommand{
				Meta: meta,
			}, nil
		},
		"eval-status": func() (cli.Command, error) {
			return &EvalStatusCommand{
				Meta: meta,
			}, nil
		},
		"exec": func() (cli.Command, error) {
			return &AllocExecCommand{
				Meta: meta,
			}, nil
		},
		"fs": func() (cli.Command, error) {
			return &AllocFSCommand{
				Meta: meta,
			}, nil
		},
		"init": func() (cli.Command, error) {
			return &JobInitCommand{
				Meta: meta,
			}, nil
		},
		"inspect": func() (cli.Command, error) {
			return &JobInspectCommand{
				Meta: meta,
			}, nil
		},
		"keygen": func() (cli.Command, error) {
			return &OperatorKeygenCommand{
				Meta: meta,
			}, nil
		},
		"keyring": func() (cli.Command, error) {
			return &OperatorKeyringCommand{
				Meta: meta,
			}, nil
		},
		"job": func() (cli.Command, error) {
			return &JobCommand{
				Meta: meta,
			}, nil
		},
		"job allocs": func() (cli.Command, error) {
			return &JobAllocsCommand{
				Meta: meta,
			}, nil
		},
		"job deployments": func() (cli.Command, error) {
			return &JobDeploymentsCommand{
				Meta: meta,
			}, nil
		},
		"job dispatch": func() (cli.Command, error) {
			return &JobDispatchCommand{
				Meta: meta,
			}, nil
		},
		"job eval": func() (cli.Command, error) {
			return &JobEvalCommand{
				Meta: meta,
			}, nil
		},
		"job history": func() (cli.Command, error) {
			return &JobHistoryCommand{
				Meta: meta,
			}, nil
		},
		"job init": func() (cli.Command, error) {
			return &JobInitCommand{
				Meta: meta,
			}, nil
		},
		"job inspect": func() (cli.Command, error) {
			return &JobInspectCommand{
				Meta: meta,
			}, nil
		},
		"job periodic": func() (cli.Command, error) {
			return &JobPeriodicCommand{
				Meta: meta,
			}, nil
		},
		"job periodic force": func() (cli.Command, error) {
			return &JobPeriodicForceCommand{
				Meta: meta,
			}, nil
		},
		"job plan": func() (cli.Command, error) {
			return &JobPlanCommand{
				Meta: meta,
			}, nil
		},
		"job promote": func() (cli.Command, error) {
			return &JobPromoteCommand{
				Meta: meta,
			}, nil
		},
		"job revert": func() (cli.Command, error) {
			return &JobRevertCommand{
				Meta: meta,
			}, nil
		},
		"job run": func() (cli.Command, error) {
			return &JobRunCommand{
				Meta: meta,
			}, nil
		},
		"job scale": func() (cli.Command, error) {
			return &JobScaleCommand{
				Meta: meta,
			}, nil
		},
		"job scaling-events": func() (cli.Command, error) {
			return &JobScalingEventsCommand{
				Meta: meta,
			}, nil
		},
		"job status": func() (cli.Command, error) {
			return &JobStatusCommand{
				Meta: meta,
			}, nil
		},
		"job stop": func() (cli.Command, error) {
			return &JobStopCommand{
				Meta: meta,
			}, nil
		},
		"job validate": func() (cli.Command, error) {
			return &JobValidateCommand{
				Meta: meta,
			}, nil
		},
		"license": func() (cli.Command, error) {
			return &LicenseCommand{
				Meta: meta,
			}, nil
		},
		"license get": func() (cli.Command, error) {
			return &LicenseGetCommand{
				Meta: meta,
			}, nil
		},
		"logs": func() (cli.Command, error) {
			return &AllocLogsCommand{
				Meta: meta,
			}, nil
		},
		"monitor": func() (cli.Command, error) {
			return &MonitorCommand{
				Meta: meta,
			}, nil
		},
		"namespace": func() (cli.Command, error) {
			return &NamespaceCommand{
				Meta: meta,
			}, nil
		},
		"namespace apply": func() (cli.Command, error) {
			return &NamespaceApplyCommand{
				Meta: meta,
			}, nil
		},
		"namespace delete": func() (cli.Command, error) {
			return &NamespaceDeleteCommand{
				Meta: meta,
			}, nil
		},
		"namespace inspect": func() (cli.Command, error) {
			return &NamespaceInspectCommand{
				Meta: meta,
			}, nil
		},
		"namespace list": func() (cli.Command, error) {
			return &NamespaceListCommand{
				Meta: meta,
			}, nil
		},
		"namespace status": func() (cli.Command, error) {
			return &NamespaceStatusCommand{
				Meta: meta,
			}, nil
		},
		"node": func() (cli.Command, error) {
			return &NodeCommand{
				Meta: meta,
			}, nil
		},
		"node config": func() (cli.Command, error) {
			return &NodeConfigCommand{
				Meta: meta,
			}, nil
		},
		"node-drain": func() (cli.Command, error) {
			return &NodeDrainCommand{
				Meta: meta,
			}, nil
		},
		"node drain": func() (cli.Command, error) {
			return &NodeDrainCommand{
				Meta: meta,
			}, nil
		},
		"node eligibility": func() (cli.Command, error) {
			return &NodeEligibilityCommand{
				Meta: meta,
			}, nil
		},
		"node-status": func() (cli.Command, error) {
			return &NodeStatusCommand{
				Meta: meta,
			}, nil
		},
		"node status": func() (cli.Command, error) {
			return &NodeStatusCommand{
				Meta: meta,
			}, nil
		},
		"operator": func() (cli.Command, error) {
			return &OperatorCommand{
				Meta: meta,
			}, nil
		},

		"operator autopilot": func() (cli.Command, error) {
			return &OperatorAutopilotCommand{
				Meta: meta,
			}, nil
		},

		"operator autopilot get-config": func() (cli.Command, error) {
			return &OperatorAutopilotGetCommand{
				Meta: meta,
			}, nil
		},

		"operator autopilot set-config": func() (cli.Command, error) {
			return &OperatorAutopilotSetCommand{
				Meta: meta,
			}, nil
		},
		"operator debug": func() (cli.Command, error) {
			return &OperatorDebugCommand{
				Meta: meta,
			}, nil
		},
		"operator keygen": func() (cli.Command, error) {
			return &OperatorKeygenCommand{
				Meta: meta,
			}, nil
		},
		"operator keyring": func() (cli.Command, error) {
			return &OperatorKeyringCommand{
				Meta: meta,
			}, nil
		},
		"operator metrics": func() (cli.Command, error) {
			return &OperatorMetricsCommand{
				Meta: meta,
			}, nil
		},
		"operator raft": func() (cli.Command, error) {
			return &OperatorRaftCommand{
				Meta: meta,
			}, nil
		},

		"operator raft list-peers": func() (cli.Command, error) {
			return &OperatorRaftListCommand{
				Meta: meta,
			}, nil
		},

		"operator raft remove-peer": func() (cli.Command, error) {
			return &OperatorRaftRemoveCommand{
				Meta: meta,
			}, nil
		},
		"operator raft _info": func() (cli.Command, error) {
			return &OperatorRaftInfoCommand{
				Meta: meta,
			}, nil
		},
		"operator raft _logs": func() (cli.Command, error) {
			return &OperatorRaftLogsCommand{
				Meta: meta,
			}, nil
		},
		"operator raft _state": func() (cli.Command, error) {
			return &OperatorRaftStateCommand{
				Meta: meta,
			}, nil
		},

		"operator snapshot": func() (cli.Command, error) {
			return &OperatorSnapshotCommand{
				Meta: meta,
			}, nil
		},
		"operator snapshot save": func() (cli.Command, error) {
			return &OperatorSnapshotSaveCommand{
				Meta: meta,
			}, nil
		},
		"operator snapshot inspect": func() (cli.Command, error) {
			return &OperatorSnapshotInspectCommand{
				Meta: meta,
			}, nil
		},
		"operator snapshot _state": func() (cli.Command, error) {
			return &OperatorSnapshotStateCommand{
				Meta: meta,
			}, nil
		},
		"operator snapshot restore": func() (cli.Command, error) {
			return &OperatorSnapshotRestoreCommand{
				Meta: meta,
			}, nil
		},

		"plan": func() (cli.Command, error) {
			return &JobPlanCommand{
				Meta: meta,
			}, nil
		},

		"plugin": func() (cli.Command, error) {
			return &PluginCommand{
				Meta: meta,
			}, nil
		},
		"plugin status": func() (cli.Command, error) {
			return &PluginStatusCommand{
				Meta: meta,
			}, nil
		},

		"quota": func() (cli.Command, error) {
			return &QuotaCommand{
				Meta: meta,
			}, nil
		},

		"quota apply": func() (cli.Command, error) {
			return &QuotaApplyCommand{
				Meta: meta,
			}, nil
		},

		"quota delete": func() (cli.Command, error) {
			return &QuotaDeleteCommand{
				Meta: meta,
			}, nil
		},

		"quota init": func() (cli.Command, error) {
			return &QuotaInitCommand{
				Meta: meta,
			}, nil
		},

		"quota inspect": func() (cli.Command, error) {
			return &QuotaInspectCommand{
				Meta: meta,
			}, nil
		},

		"quota list": func() (cli.Command, error) {
			return &QuotaListCommand{
				Meta: meta,
			}, nil
		},

		"quota status": func() (cli.Command, error) {
			return &QuotaStatusCommand{
				Meta: meta,
			}, nil
		},

		"recommendation": func() (cli.Command, error) {
			return &RecommendationCommand{
				Meta: meta,
			}, nil
		},
		"recommendation apply": func() (cli.Command, error) {
			return &RecommendationApplyCommand{
				RecommendationAutocompleteCommand: RecommendationAutocompleteCommand{
					Meta: meta,
				},
			}, nil
		},
		"recommendation dismiss": func() (cli.Command, error) {
			return &RecommendationDismissCommand{
				RecommendationAutocompleteCommand: RecommendationAutocompleteCommand{
					Meta: meta,
				},
			}, nil
		},
		"recommendation info": func() (cli.Command, error) {
			return &RecommendationInfoCommand{
				RecommendationAutocompleteCommand: RecommendationAutocompleteCommand{
					Meta: meta,
				},
			}, nil
		},
		"recommendation list": func() (cli.Command, error) {
			return &RecommendationListCommand{
				Meta: meta,
			}, nil
		},

		"run": func() (cli.Command, error) {
			return &JobRunCommand{
				Meta: meta,
			}, nil
		},
		"scaling": func() (cli.Command, error) {
			return &ScalingCommand{
				Meta: meta,
			}, nil
		},
		"scaling policy": func() (cli.Command, error) {
			return &ScalingPolicyCommand{
				Meta: meta,
			}, nil
		},
		"scaling policy info": func() (cli.Command, error) {
			return &ScalingPolicyInfoCommand{
				Meta: meta,
			}, nil
		},
		"scaling policy list": func() (cli.Command, error) {
			return &ScalingPolicyListCommand{
				Meta: meta,
			}, nil
		},
		"sentinel": func() (cli.Command, error) {
			return &SentinelCommand{
				Meta: meta,
			}, nil
		},
		"sentinel list": func() (cli.Command, error) {
			return &SentinelListCommand{
				Meta: meta,
			}, nil
		},
		"sentinel apply": func() (cli.Command, error) {
			return &SentinelApplyCommand{
				Meta: meta,
			}, nil
		},
		"sentinel delete": func() (cli.Command, error) {
			return &SentinelDeleteCommand{
				Meta: meta,
			}, nil
		},
		"sentinel read": func() (cli.Command, error) {
			return &SentinelReadCommand{
				Meta: meta,
			}, nil
		},
		"server": func() (cli.Command, error) {
			return &ServerCommand{
				Meta: meta,
			}, nil
		},
		"server force-leave": func() (cli.Command, error) {
			return &ServerForceLeaveCommand{
				Meta: meta,
			}, nil
		},
		"server join": func() (cli.Command, error) {
			return &ServerJoinCommand{
				Meta: meta,
			}, nil
		},
		"server members": func() (cli.Command, error) {
			return &ServerMembersCommand{
				Meta: meta,
			}, nil
		},
		"server-force-leave": func() (cli.Command, error) {
			return &ServerForceLeaveCommand{
				Meta: meta,
			}, nil
		},
		"server-join": func() (cli.Command, error) {
			return &ServerJoinCommand{
				Meta: meta,
			}, nil
		},
		"server-members": func() (cli.Command, error) {
			return &ServerMembersCommand{
				Meta: meta,
			}, nil
		},
		"status": func() (cli.Command, error) {
			return &StatusCommand{
				Meta: meta,
			}, nil
		},
		"stop": func() (cli.Command, error) {
			return &JobStopCommand{
				Meta: meta,
			}, nil
		},
		"system": func() (cli.Command, error) {
			return &SystemCommand{
				Meta: meta,
			}, nil
		},
		"system gc": func() (cli.Command, error) {
			return &SystemGCCommand{
				Meta: meta,
			}, nil
		},
		"system reconcile": func() (cli.Command, error) {
			return &SystemReconcileCommand{
				Meta: meta,
			}, nil
		},
		"system reconcile summaries": func() (cli.Command, error) {
			return &SystemReconcileSummariesCommand{
				Meta: meta,
			}, nil
		},
		"ui": func() (cli.Command, error) {
			return &UiCommand{
				Meta: meta,
			}, nil
		},
		"validate": func() (cli.Command, error) {
			return &JobValidateCommand{
				Meta: meta,
			}, nil
		},
		"version": func() (cli.Command, error) {
			return &VersionCommand{
				Version: version.GetVersion(),
				Ui:      meta.Ui,
			}, nil
		},
		"volume": func() (cli.Command, error) {
			return &VolumeCommand{
				Meta: meta,
			}, nil
		},
		"volume init": func() (cli.Command, error) {
			return &VolumeInitCommand{
				Meta: meta,
			}, nil
		},
		"volume status": func() (cli.Command, error) {
			return &VolumeStatusCommand{
				Meta: meta,
			}, nil
		},
		"volume register": func() (cli.Command, error) {
			return &VolumeRegisterCommand{
				Meta: meta,
			}, nil
		},
		"volume deregister": func() (cli.Command, error) {
			return &VolumeDeregisterCommand{
				Meta: meta,
			}, nil
		},
		"volume detach": func() (cli.Command, error) {
			return &VolumeDetachCommand{
				Meta: meta,
			}, nil
		},
		"volume create": func() (cli.Command, error) {
			return &VolumeCreateCommand{
				Meta: meta,
			}, nil
		},
		"volume delete": func() (cli.Command, error) {
			return &VolumeDeleteCommand{
				Meta: meta,
			}, nil
		},
		"volume snapshot create": func() (cli.Command, error) {
			return &VolumeSnapshotCreateCommand{
				Meta: meta,
			}, nil
		},
		"volume snapshot delete": func() (cli.Command, error) {
			return &VolumeSnapshotDeleteCommand{
				Meta: meta,
			}, nil
		},
		"volume snapshot list": func() (cli.Command, error) {
			return &VolumeSnapshotListCommand{
				Meta: meta,
			}, nil
		},
	}

	deprecated := map[string]cli.CommandFactory{
		"client-config": func() (cli.Command, error) {
			return &DeprecatedCommand{
				Old:  "client-config",
				New:  "node config",
				Meta: meta,
				Command: &NodeConfigCommand{
					Meta: meta,
				},
			}, nil
		},

		"keygen": func() (cli.Command, error) {
			return &DeprecatedCommand{
				Old:  "keygen",
				New:  "operator keygen",
				Meta: meta,
				Command: &OperatorKeygenCommand{
					Meta: meta,
				},
			}, nil
		},

		"keyring": func() (cli.Command, error) {
			return &DeprecatedCommand{
				Old:  "keyring",
				New:  "operator keyring",
				Meta: meta,
				Command: &OperatorKeyringCommand{
					Meta: meta,
				},
			}, nil
		},

		"server-force-leave": func() (cli.Command, error) {
			return &DeprecatedCommand{
				Old:  "server-force-leave",
				New:  "server force-leave",
				Meta: meta,
				Command: &ServerForceLeaveCommand{
					Meta: meta,
				},
			}, nil
		},

		"server-join": func() (cli.Command, error) {
			return &DeprecatedCommand{
				Old:  "server-join",
				New:  "server join",
				Meta: meta,
				Command: &ServerJoinCommand{
					Meta: meta,
				},
			}, nil
		},

		"server-members": func() (cli.Command, error) {
			return &DeprecatedCommand{
				Old:  "server-members",
				New:  "server members",
				Meta: meta,
				Command: &ServerMembersCommand{
					Meta: meta,
				},
			}, nil
		},
	}

	for k, v := range deprecated {
		all[k] = v
	}

	for k, v := range EntCommands(metaPtr, agentUi) {
		all[k] = v
	}

	return all
}
```

这里面可以看到在手动执行的`job/server/status`等命令，都是在这里进行定义的

#### command 启动代码

```go

func (c *Command) Run(args []string) int {
	c.Ui = &cli.PrefixedUi{
		OutputPrefix: "==> ",
		InfoPrefix:   "    ",
		ErrorPrefix:  "==> ",
		Ui:           c.Ui,
	}

	// Parse our configs
	c.args = args
	config := c.readConfig()
	if config == nil {
		return 1
	}

	// reset UI to prevent prefixed json output
	if config.LogJson {
		c.Ui = &cli.BasicUi{
			Reader:      os.Stdin,
			Writer:      os.Stdout,
			ErrorWriter: os.Stderr,
		}
	}

	// Setup the log outputs
	logFilter, logGate, logOutput := SetupLoggers(c.Ui, config)
	c.logFilter = logFilter
	c.logOutput = logOutput
	if logGate == nil {
		return 1
	}

	// Create logger
	logger := hclog.NewInterceptLogger(&hclog.LoggerOptions{
		Name:       "agent",
		Level:      hclog.LevelFromString(config.LogLevel),
		Output:     logOutput,
		JSONFormat: config.LogJson,
	})

	// Wrap log messages emitted with the 'log' package.
	// These usually come from external dependencies.
	log.SetOutput(logger.StandardWriter(&hclog.StandardLoggerOptions{InferLevels: true}))
	log.SetPrefix("")
	log.SetFlags(0)

	// Swap out UI implementation if json logging is enabled
	if config.LogJson {
		c.Ui = &logging.HcLogUI{Log: logger}
	}

	// Log config files
	if len(config.Files) > 0 {
		c.Ui.Output(fmt.Sprintf("Loaded configuration from %s", strings.Join(config.Files, ", ")))
	} else {
		c.Ui.Output("No configuration files loaded")
	}

	// Initialize the telemetry
	inmem, err := c.setupTelemetry(config)
	if err != nil {
		c.Ui.Error(fmt.Sprintf("Error initializing telemetry: %s", err))
		return 1
	}

	// Create the agent
	if err := c.setupAgent(config, logger, logOutput, inmem); err != nil {
		logGate.Flush()
		return 1
	}

	defer func() {
		c.agent.Shutdown()

		// Shutdown the http server at the end, to ease debugging if
		// the agent takes long to shutdown
		if c.httpServer != nil {
			c.httpServer.Shutdown()
		}
	}()

	// Join startup nodes if specified
	if err := c.startupJoin(config); err != nil {
		c.Ui.Error(err.Error())
		return 1
	}

	// Compile agent information for output later
	info := make(map[string]string)
	info["version"] = config.Version.VersionNumber()
	info["client"] = strconv.FormatBool(config.Client.Enabled)
	info["log level"] = config.LogLevel
	info["server"] = strconv.FormatBool(config.Server.Enabled)
	info["region"] = fmt.Sprintf("%s (DC: %s)", config.Region, config.Datacenter)
	info["bind addrs"] = c.getBindAddrSynopsis()
	info["advertise addrs"] = c.getAdvertiseAddrSynopsis()

	// Sort the keys for output
	infoKeys := make([]string, 0, len(info))
	for key := range info {
		infoKeys = append(infoKeys, key)
	}
	sort.Strings(infoKeys)

	// Agent configuration output
	padding := 18
	c.Ui.Output("Nomad agent configuration:\n")
	for _, k := range infoKeys {
		c.Ui.Info(fmt.Sprintf(
			"%s%s: %s",
			strings.Repeat(" ", padding-len(k)),
			strings.Title(k),
			info[k]))
	}
	c.Ui.Output("")

	// Output the header that the server has started
	c.Ui.Output("Nomad agent started! Log data will stream in below:\n")

	// Enable log streaming
	logGate.Flush()

	// Start retry join process
	if err := c.handleRetryJoin(config); err != nil {
		c.Ui.Error(err.Error())
		return 1
	}

	// Wait for exit
	return c.handleSignals()
}
```



#### 配置文件处理代码片段

> nomad/command/agent/command.go@Command.readConfig()

```go
for _, path := range configPath {
		current, err := LoadConfig(path)
		if err != nil {
			c.Ui.Error(fmt.Sprintf(
				"Error loading configuration from %s: %s", path, err))
			return nil
		}

		// The user asked us to load some config here but we didn't find any,
		// so we'll complain but continue.
		if current == nil || reflect.DeepEqual(current, &Config{}) {
			c.Ui.Warn(fmt.Sprintf("No configuration loaded from %s", path))
		}

		if config == nil {
			config = current
		} else {
			config = config.Merge(current)
		}
	}

	// Ensure the sub-structs at least exist
	if config.Client == nil {
		config.Client = &ClientConfig{}
	}

	if config.Server == nil {
		config.Server = &ServerConfig{}
	}

	// Merge any CLI options over config file options
	config = config.Merge(cmdConfig)

```

#### setupAgent 代码

```go

// setupAgent is used to start the agent and various interfaces
func (c *Command) setupAgent(config *Config, logger hclog.InterceptLogger, logOutput io.Writer, inmem *metrics.InmemSink) error {
	c.Ui.Output("Starting Nomad agent...")
	agent, err := NewAgent(config, logger, logOutput, inmem)
	if err != nil {
		// log the error as well, so it appears at the end
		logger.Error("error starting agent", "error", err)
		c.Ui.Error(fmt.Sprintf("Error starting agent: %s", err))
		return err
	}
	c.agent = agent

	// Setup the HTTP server
	http, err := NewHTTPServer(agent, config)
	if err != nil {
		agent.Shutdown()
		c.Ui.Error(fmt.Sprintf("Error starting http server: %s", err))
		return err
	}
	c.httpServer = http

	// If DisableUpdateCheck is not enabled, set up update checking
	// (DisableUpdateCheck is false by default)
	if config.DisableUpdateCheck != nil && !*config.DisableUpdateCheck {
		version := config.Version.Version
		if config.Version.VersionPrerelease != "" {
			version += fmt.Sprintf("-%s", config.Version.VersionPrerelease)
		}
		updateParams := &checkpoint.CheckParams{
			Product: "nomad",
			Version: version,
		}
		if !config.DisableAnonymousSignature {
			updateParams.SignatureFile = filepath.Join(config.DataDir, "checkpoint-signature")
		}

		// Schedule a periodic check with expected interval of 24 hours
		checkpoint.CheckInterval(updateParams, 24*time.Hour, c.checkpointResults)

		// Do an immediate check within the next 30 seconds
		go func() {
			time.Sleep(lib.RandomStagger(30 * time.Second))
			c.checkpointResults(checkpoint.Check(updateParams))
		}()
	}

	return nil
}
```

#### NewAgent 代码

```go

// NewAgent is used to create a new agent with the given configuration
func NewAgent(config *Config, logger log.InterceptLogger, logOutput io.Writer, inmem *metrics.InmemSink) (*Agent, error) {
	a := &Agent{
		config:     config,
		logOutput:  logOutput,
		shutdownCh: make(chan struct{}),
		InmemSink:  inmem,
	}

	// Create the loggers
	a.logger = logger
	a.httpLogger = a.logger.ResetNamed("http")

	// Global logger should match internal logger as much as possible
	golog.SetFlags(golog.LstdFlags | golog.Lmicroseconds)

	if err := a.setupConsul(config.Consul); err != nil {
		return nil, fmt.Errorf("Failed to initialize Consul client: %v", err)
	}

	if err := a.setupPlugins(); err != nil {
		return nil, err
	}

	if err := a.setupServer(); err != nil {
		return nil, err
	}
	if err := a.setupClient(); err != nil {
		return nil, err
	}

	if err := a.setupEnterpriseAgent(logger); err != nil {
		return nil, err
	}
	if a.client == nil && a.server == nil {
		return nil, fmt.Errorf("must have at least client or server mode enabled")
	}

	return a, nil
}
```

#### setupPlugins代码

```go
// setupPlugins is used to setup the plugin loaders.
func (a *Agent) setupPlugins() error {
	// Get our internal plugins
	internal, err := a.internalPluginConfigs()
	if err != nil {
		return err
	}

	// Build the plugin loader
	config := &loader.PluginLoaderConfig{
		Logger:            a.logger,
		PluginDir:         a.config.PluginDir,
		Configs:           a.config.Plugins,
		InternalPlugins:   internal,
		SupportedVersions: loader.AgentSupportedApiVersions,
	}
	l, err := loader.NewPluginLoader(config)
	if err != nil {
		return fmt.Errorf("failed to create plugin loader: %v", err)
	}
	a.pluginLoader = l

	// Wrap the loader to get our singleton loader
	a.pluginSingletonLoader = singleton.NewSingletonLoader(a.logger, l)

	for k, plugins := range a.pluginLoader.Catalog() {
		for _, p := range plugins {
			a.logger.Info("detected plugin", "name", p.Name, "type", k, "plugin_version", p.PluginVersion)
		}
	}

	return nil
}
```

#### NewPluginLoader中的init的调用

```go
// init initializes the plugin loader by compiling both internal and external
// plugins and selecting the highest versioned version of any given plugin.
func (l *PluginLoader) init(config *PluginLoaderConfig) error {
	// Create a mapping of name to config
	configMap := configMap(config.Configs)

	// Initialize the internal plugins
	internal, err := l.initInternal(config.InternalPlugins, configMap)
	if err != nil {
		return fmt.Errorf("failed to fingerprint internal plugins: %v", err)
	}

	// Scan for eligibile binaries
	plugins, err := l.scan()
	if err != nil {
		return fmt.Errorf("failed to scan plugin directory %q: %v", l.pluginDir, err)
	}

	// Fingerprint the passed plugins
	external, err := l.fingerprintPlugins(plugins, configMap)
	if err != nil {
		return fmt.Errorf("failed to fingerprint plugins: %v", err)
	}

	// Merge external and internal plugins
	l.plugins = l.mergePlugins(internal, external)

	// Validate that the configs are valid for the plugins
	if err := l.validatePluginConfigs(); err != nil {
		return fmt.Errorf("parsing plugin configurations failed: %v", err)
	}

	return nil
}
```

#### setClient 代码

```go

// setupClient is used to setup the client if enabled
func (a *Agent) setupClient() error {
	if !a.config.Client.Enabled {
		return nil
	}

	// Setup the configuration
	conf, err := a.clientConfig()
	if err != nil {
		return fmt.Errorf("client setup failed: %v", err)
	}

	// Reserve some ports for the plugins if we are on Windows
	if runtime.GOOS == "windows" {
		if err := a.reservePortsForClient(conf); err != nil {
			return err
		}
	}
	if conf.StateDBFactory == nil {
		conf.StateDBFactory = state.GetStateDBFactory(conf.DevMode)
	}

	nomadClient, err := client.NewClient(
		conf, a.consulCatalog, a.consulProxies, a.consulService, nil)
	if err != nil {
		return fmt.Errorf("client setup failed: %v", err)
	}
	a.client = nomadClient

	// Create the Nomad Client  services for Consul
	if *a.config.Consul.AutoAdvertise {
		httpServ := &structs.Service{
			Name:      a.config.Consul.ClientServiceName,
			PortLabel: a.config.AdvertiseAddrs.HTTP,
			Tags:      append([]string{consul.ServiceTagHTTP}, a.config.Consul.Tags...),
		}
		const isServer = false
		if check := a.agentHTTPCheck(isServer); check != nil {
			httpServ.Checks = []*structs.ServiceCheck{check}
		}
		if err := a.consulService.RegisterAgent(consulRoleClient, []*structs.Service{httpServ}); err != nil {
			return err
		}
	}

	return nil
}
```

#### NewClient 代码：

```go
// NewClient is used to create a new client from the given configuration.
// `rpcs` is a map of RPC names to RPC structs that, if non-nil, will be
// registered via https://golang.org/pkg/net/rpc/#Server.RegisterName in place
// of the client's normal RPC handlers. This allows server tests to override
// the behavior of the client.
func NewClient(cfg *config.Config, consulCatalog consul.CatalogAPI, consulProxies consulApi.SupportedProxiesAPI, consulService consulApi.ConsulServiceAPI, rpcs map[string]interface{}) (*Client, error) {
	// Create the tls wrapper
	var tlsWrap tlsutil.RegionWrapper
	if cfg.TLSConfig.EnableRPC {
		tw, err := tlsutil.NewTLSConfiguration(cfg.TLSConfig, true, true)
		if err != nil {
			return nil, err
		}
		tlsWrap, err = tw.OutgoingTLSWrapper()
		if err != nil {
			return nil, err
		}
	}

	if cfg.StateDBFactory == nil {
		cfg.StateDBFactory = state.GetStateDBFactory(cfg.DevMode)
	}

	// Create the logger
	logger := cfg.Logger.ResetNamedIntercept("client")

	// Create the client
	c := &Client{
		config:               cfg,
		consulCatalog:        consulCatalog,
		consulProxies:        consulProxies,
		consulService:        consulService,
		start:                time.Now(),
		connPool:             pool.NewPool(logger, clientRPCCache, clientMaxStreams, tlsWrap),
		tlsWrap:              tlsWrap,
		streamingRpcs:        structs.NewStreamingRpcRegistry(),
		logger:               logger,
		rpcLogger:            logger.Named("rpc"),
		allocs:               make(map[string]AllocRunner),
		allocUpdates:         make(chan *structs.Allocation, 64),
		shutdownCh:           make(chan struct{}),
		triggerDiscoveryCh:   make(chan struct{}),
		triggerNodeUpdate:    make(chan struct{}, 8),
		triggerEmitNodeEvent: make(chan *structs.NodeEvent, 8),
		fpInitialized:        make(chan struct{}),
		invalidAllocs:        make(map[string]struct{}),
		serversContactedCh:   make(chan struct{}),
		serversContactedOnce: sync.Once{},
		cpusetManager:        cgutil.NewCpusetManager(cfg.CgroupParent, logger.Named("cpuset_manager")),
		EnterpriseClient:     newEnterpriseClient(logger),
	}

	c.batchNodeUpdates = newBatchNodeUpdates(
		c.updateNodeFromDriver,
		c.updateNodeFromDevices,
		c.updateNodeFromCSI,
	)

	// Initialize the server manager
	c.servers = servers.New(c.logger, c.shutdownCh, c)

	// Start server manager rebalancing go routine
	go c.servers.Start()

	// initialize the client
	if err := c.init(); err != nil {
		return nil, fmt.Errorf("failed to initialize client: %v", err)
	}

	// initialize the dynamic registry (needs to happen after init)
	c.dynamicRegistry =
		dynamicplugins.NewRegistry(c.stateDB, map[string]dynamicplugins.PluginDispenser{
			dynamicplugins.PluginTypeCSIController: func(info *dynamicplugins.PluginInfo) (interface{}, error) {
				return csi.NewClient(info.ConnectionInfo.SocketPath, logger.Named("csi_client").With("plugin.name", info.Name, "plugin.type", "controller"))
			},
			dynamicplugins.PluginTypeCSINode: func(info *dynamicplugins.PluginInfo) (interface{}, error) {
				return csi.NewClient(info.ConnectionInfo.SocketPath, logger.Named("csi_client").With("plugin.name", info.Name, "plugin.type", "client"))
			}, // TODO(tgross): refactor these dispenser constructors into csimanager to tidy it up
		})

	// Setup the clients RPC server
	c.setupClientRpc(rpcs)

	// Initialize the ACL state
	if err := c.clientACLResolver.init(); err != nil {
		return nil, fmt.Errorf("failed to initialize ACL state: %v", err)
	}

	// Setup the node
	if err := c.setupNode(); err != nil {
		return nil, fmt.Errorf("node setup failed: %v", err)
	}

	// Store the config copy before restoring state but after it has been
	// initialized.
	c.configLock.Lock()
	c.configCopy = c.config.Copy()
	c.configLock.Unlock()

	fingerprintManager := NewFingerprintManager(
		c.configCopy.PluginSingletonLoader, c.GetConfig, c.configCopy.Node,
		c.shutdownCh, c.updateNodeFromFingerprint, c.logger)

	c.pluginManagers = pluginmanager.New(c.logger)

	// Fingerprint the node and scan for drivers
	if err := fingerprintManager.Run(); err != nil {
		return nil, fmt.Errorf("fingerprinting failed: %v", err)
	}

	// Build the allow/denylists of drivers.
	// COMPAT(1.0) uses inclusive language. white/blacklist are there for backward compatible reasons only.
	allowlistDrivers := cfg.ReadStringListToMap("driver.allowlist", "driver.whitelist")
	blocklistDrivers := cfg.ReadStringListToMap("driver.denylist", "driver.blacklist")

	// Setup the csi manager
	csiConfig := &csimanager.Config{
		Logger:                c.logger,
		DynamicRegistry:       c.dynamicRegistry,
		UpdateNodeCSIInfoFunc: c.batchNodeUpdates.updateNodeFromCSI,
		TriggerNodeEvent:      c.triggerNodeEvent,
	}
	csiManager := csimanager.New(csiConfig)
	c.csimanager = csiManager
	c.pluginManagers.RegisterAndRun(csiManager.PluginManager())

	// Setup the driver manager
	driverConfig := &drivermanager.Config{
		Logger:              c.logger,
		Loader:              c.configCopy.PluginSingletonLoader,
		PluginConfig:        c.configCopy.NomadPluginConfig(),
		Updater:             c.batchNodeUpdates.updateNodeFromDriver,
		EventHandlerFactory: c.GetTaskEventHandler,
		State:               c.stateDB,
		AllowedDrivers:      allowlistDrivers,
		BlockedDrivers:      blocklistDrivers,
	}
	drvManager := drivermanager.New(driverConfig)
	c.drivermanager = drvManager
	c.pluginManagers.RegisterAndRun(drvManager)

	// Setup the device manager
	devConfig := &devicemanager.Config{
		Logger:        c.logger,
		Loader:        c.configCopy.PluginSingletonLoader,
		PluginConfig:  c.configCopy.NomadPluginConfig(),
		Updater:       c.batchNodeUpdates.updateNodeFromDevices,
		StatsInterval: c.configCopy.StatsCollectionInterval,
		State:         c.stateDB,
	}
	devManager := devicemanager.New(devConfig)
	c.devicemanager = devManager
	c.pluginManagers.RegisterAndRun(devManager)

	// Batching of initial fingerprints is done to reduce the number of node
	// updates sent to the server on startup. This is the first RPC to the servers
	go c.batchFirstFingerprints()

	// create heartbeatStop. We go after the first attempt to connect to the server, so
	// that our grace period for connection goes for the full time
	c.heartbeatStop = newHeartbeatStop(c.getAllocRunner, batchFirstFingerprintsTimeout, logger, c.shutdownCh)

	// Watch for disconnection, and heartbeatStopAllocs configured to have a maximum
	// lifetime when out of touch with the server
	go c.heartbeatStop.watch()

	// Add the stats collector
	statsCollector := stats.NewHostStatsCollector(c.logger, c.config.AllocDir, c.devicemanager.AllStats)
	c.hostStatsCollector = statsCollector

	// Add the garbage collector
	gcConfig := &GCConfig{
		MaxAllocs:           cfg.GCMaxAllocs,
		DiskUsageThreshold:  cfg.GCDiskUsageThreshold,
		InodeUsageThreshold: cfg.GCInodeUsageThreshold,
		Interval:            cfg.GCInterval,
		ParallelDestroys:    cfg.GCParallelDestroys,
		ReservedDiskMB:      cfg.Node.Reserved.DiskMB,
	}
	c.garbageCollector = NewAllocGarbageCollector(c.logger, statsCollector, c, gcConfig)
	go c.garbageCollector.Run()

	// Set the preconfigured list of static servers
	c.configLock.RLock()
	if len(c.configCopy.Servers) > 0 {
		if _, err := c.setServersImpl(c.configCopy.Servers, true); err != nil {
			logger.Warn("none of the configured servers are valid", "error", err)
		}
	}
	c.configLock.RUnlock()

	// Setup Consul discovery if enabled
	if c.configCopy.ConsulConfig.ClientAutoJoin != nil && *c.configCopy.ConsulConfig.ClientAutoJoin {
		c.shutdownGroup.Go(c.consulDiscovery)
		if c.servers.NumServers() == 0 {
			// No configured servers; trigger discovery manually
			c.triggerDiscoveryCh <- struct{}{}
		}
	}

	if err := c.setupConsulTokenClient(); err != nil {
		return nil, errors.Wrap(err, "failed to setup consul tokens client")
	}

	// Setup the vault client for token and secret renewals
	if err := c.setupVaultClient(); err != nil {
		return nil, fmt.Errorf("failed to setup vault client: %v", err)
	}

	// wait until drivers are healthy before restoring or registering with servers
	select {
	case <-c.fpInitialized:
	case <-time.After(batchFirstFingerprintsProcessingGrace):
		logger.Warn("batch fingerprint operation timed out; proceeding to register with fingerprinted plugins so far")
	}

	// Register and then start heartbeating to the servers.
	c.shutdownGroup.Go(c.registerAndHeartbeat)

	// Restore the state
	if err := c.restoreState(); err != nil {
		logger.Error("failed to restore state", "error", err)
		logger.Error("Nomad is unable to start due to corrupt state. "+
			"The safest way to proceed is to manually stop running task processes "+
			"and remove Nomad's state and alloc directories before "+
			"restarting. Lost allocations will be rescheduled.",
			"state_dir", c.config.StateDir, "alloc_dir", c.config.AllocDir)
		logger.Error("Corrupt state is often caused by a bug. Please " +
			"report as much information as possible to " +
			"https://github.com/hashicorp/nomad/issues")
		return nil, fmt.Errorf("failed to restore state")
	}

	// Begin periodic snapshotting of state.
	c.shutdownGroup.Go(c.periodicSnapshot)

	// Begin syncing allocations to the server
	c.shutdownGroup.Go(c.allocSync)

	// Start the client! Don't use the shutdownGroup as run handles
	// shutdowns manually to prevent updates from being applied during
	// shutdown.
	go c.run()

	// Start collecting stats
	c.shutdownGroup.Go(c.emitStats)

	c.logger.Info("started client", "node_id", c.NodeID())
	return c, nil
}

```

#### client 启动代码

```go
// run is a long lived goroutine used to run the client. Shutdown() stops it first
func (c *Client) run() {
	// Watch for changes in allocations
	allocUpdates := make(chan *allocUpdates, 8)
	go c.watchAllocations(allocUpdates)

	for {
		select {
		case update := <-allocUpdates:
			// Don't apply updates while shutting down.
			c.shutdownLock.Lock()
			if c.shutdown {
				c.shutdownLock.Unlock()
				return
			}

			// Apply updates inside lock to prevent a concurrent
			// shutdown.
			c.runAllocs(update)
			c.shutdownLock.Unlock()

		case <-c.shutdownCh:
			return
		}
	}
}
```



### Driver的初始化流程

#### 默认注册内置Plugin

> /helper/pluginutils/catalog/register.go

```go
// This file is where all builtin plugins should be registered in the catalog.
// Plugins with build restrictions should be placed in the appropriate
// register_XXX.go file.
func init() {
	RegisterDeferredConfig(rawexec.PluginID, rawexec.PluginConfig, rawexec.PluginLoader)
	Register(exec.PluginID, exec.PluginConfig)
	Register(qemu.PluginID, qemu.PluginConfig)
	Register(java.PluginID, java.PluginConfig)
	RegisterDeferredConfig(docker.PluginID, docker.PluginConfig, docker.PluginLoader)
}
```

#### DockerDriver 的定义

配置的定义

```go
	// PluginConfig is the rawexec factory function registered in the
	// plugin catalog.
	PluginConfig = &loader.InternalPluginConfig{
		Config:  map[string]interface{}{},
		Factory: func(ctx context.Context, l hclog.Logger) interface{} { return NewDockerDriver(ctx, l) },
	}
```

初始化DockerDriver

```go
// NewDockerDriver returns a docker implementation of a driver plugin
func NewDockerDriver(ctx context.Context, logger hclog.Logger) drivers.DriverPlugin {
	logger = logger.Named(pluginName)
	return &Driver{
		eventer: eventer.NewEventer(ctx, logger),
		config:  &DriverConfig{},
		tasks:   newTaskStore(),
		ctx:     ctx,
		logger:  logger,
	}
}
```



### Plugin Manager 代码



#### Driver Manager:

```go

// Run starts the manager, initializes driver plugins and blocks until Shutdown
// is called.
func (m *manager) Run() {
	// Load any previous plugin reattach configuration
	if err := m.loadReattachConfigs(); err != nil {
		m.logger.Warn("unable to load driver plugin reattach configs, a driver process may have been leaked",
			"error", err)
	}

	// Get driver plugins
	driversPlugins := m.loader.Catalog()[base.PluginTypeDriver]
	if len(driversPlugins) == 0 {
		m.logger.Debug("exiting since there are no driver plugins")
		m.cancel()
		return
	}

	var skippedDrivers []string
	for _, d := range driversPlugins {
		id := loader.PluginInfoID(d)
		if m.isDriverBlocked(id.Name) {
			skippedDrivers = append(skippedDrivers, id.Name)
			continue
		}

		storeFn := func(c *plugin.ReattachConfig) error {
			return m.storePluginReattachConfig(id, c)
		}
		fetchFn := func() (*plugin.ReattachConfig, bool) {
			return m.fetchPluginReattachConfig(id)
		}

		instance := newInstanceManager(&instanceManagerConfig{
			Logger:               m.logger,
			Ctx:                  m.ctx,
			Loader:               m.loader,
			StoreReattach:        storeFn,
			FetchReattach:        fetchFn,
			PluginConfig:         m.pluginConfig,
			ID:                   &id,
			UpdateNodeFromDriver: m.updater,
			EventHandlerFactory:  m.eventHandlerFactory,
		})

		m.instancesMu.Lock()
		m.instances[id.Name] = instance
		m.instancesMu.Unlock()
	}

	if len(skippedDrivers) > 0 {
		m.logger.Debug("drivers skipped due to allow/block list", "skipped_drivers", skippedDrivers)
	}

	// signal ready
	close(m.readyCh)
}
```

#### csiManager Run:

```go
// Run starts a plugin manager and should return early
func (c *csiManager) Run() {
	go c.runLoop()
}

func (c *csiManager) runLoop() {
	timer := time.NewTimer(0) // ensure we sync immediately in first pass
	controllerUpdates := c.registry.PluginsUpdatedCh(c.shutdownCtx, "csi-controller")
	nodeUpdates := c.registry.PluginsUpdatedCh(c.shutdownCtx, "csi-node")
	for {
		select {
		case <-timer.C:
			c.resyncPluginsFromRegistry("csi-controller")
			c.resyncPluginsFromRegistry("csi-node")
			timer.Reset(c.pluginResyncPeriod)
		case event := <-controllerUpdates:
			c.handlePluginEvent(event)
		case event := <-nodeUpdates:
			c.handlePluginEvent(event)
		case <-c.shutdownCtx.Done():
			close(c.shutdownCh)
			return
		}
	}
}
```

#### deviceManager Run:

```go


// Run starts the device manager. The manager will shutdown any previously
// launched plugin and then begin fingerprinting and stats collection on all new
// device plugins.
func (m *manager) Run() {
	// Check if there are any plugins that didn't get cleanly shutdown before
	// and if there are shut them down.
	m.cleanupStalePlugins()

	// Get device plugins
	devices := m.loader.Catalog()[base.PluginTypeDevice]
	if len(devices) == 0 {
		m.logger.Debug("exiting since there are no device plugins")
		m.cancel()
		return
	}

	for _, d := range devices {
		id := loader.PluginInfoID(d)
		storeFn := func(c *plugin.ReattachConfig) error {
			id := id
			return m.storePluginReattachConfig(id, c)
		}
		m.instances[id] = newInstanceManager(&instanceManagerConfig{
			Logger:           m.logger,
			Ctx:              m.ctx,
			Loader:           m.loader,
			StoreReattach:    storeFn,
			PluginConfig:     m.pluginConfig,
			Id:               &id,
			FingerprintOutCh: m.fingerprintResCh,
			StatsInterval:    m.statsInterval,
		})
	}

	// Now start the fingerprint handler
	go m.fingerprint()
}
```

### 任务分发执行流程

接着`cli.run()`就可以看到开始监听alloctions然后执行;watch逻辑主要是监听server的`Node.GetClientAllocs`

### runAllocs代码

```go

// runAllocs is invoked when we get an updated set of allocations
func (c *Client) runAllocs(update *allocUpdates) {
	// Get the existing allocs
	c.allocLock.RLock()
	existing := make(map[string]uint64, len(c.allocs))
	for id, ar := range c.allocs {
		existing[id] = ar.Alloc().AllocModifyIndex
	}
	c.allocLock.RUnlock()

	// Diff the existing and updated allocations
	diff := diffAllocs(existing, update)
	c.logger.Debug("allocation updates", "added", len(diff.added), "removed", len(diff.removed),
		"updated", len(diff.updated), "ignored", len(diff.ignore))

	errs := 0

	// Remove the old allocations
	for _, remove := range diff.removed {
		c.removeAlloc(remove)
	}

	// Update the existing allocations
	for _, update := range diff.updated {
		c.updateAlloc(update)
	}

	// Make room for new allocations before running
	if err := c.garbageCollector.MakeRoomFor(diff.added); err != nil {
		c.logger.Error("error making room for new allocations", "error", err)
		errs++
	}

	// Start the new allocations
	for _, add := range diff.added {
		migrateToken := update.migrateTokens[add.ID]
		if err := c.addAlloc(add, migrateToken); err != nil {
			c.logger.Error("error adding alloc", "error", err, "alloc_id", add.ID)
			errs++
			// We mark the alloc as failed and send an update to the server
			// We track the fact that creating an allocrunner failed so that we don't send updates again
			if add.ClientStatus != structs.AllocClientStatusFailed {
				c.handleInvalidAllocs(add, err)
			}
		}
	}

	// Mark servers as having been contacted so blocked tasks that failed
	// to restore can now restart.
	c.serversContactedOnce.Do(func() {
		close(c.serversContactedCh)
	})

	// Trigger the GC once more now that new allocs are started that could
	// have caused thresholds to be exceeded
	c.garbageCollector.Trigger()
	c.logger.Debug("allocation updates applied", "added", len(diff.added), "removed", len(diff.removed),
		"updated", len(diff.updated), "ignored", len(diff.ignore), "errors", errs)
}
```

#### update 逻辑

最后会调用到allocRunner.Update方法：

```go
// Update asyncronously updates the running allocation with a new version
// received from the server.
// When processing a new update, we will first attempt to drain stale updates
// from the queue, before appending the new one.
func (ar *allocRunner) Update(update *structs.Allocation) {
	select {
	// Drain queued update from the channel if possible, and check the modify
	// index
	case oldUpdate := <-ar.allocUpdatedCh:
		// If the old update is newer than the replacement, then skip the new one
		// and return. This case shouldn't happen, but may in the case of a bug
		// elsewhere inside the system.
		if oldUpdate.AllocModifyIndex > update.AllocModifyIndex {
			ar.logger.Debug("Discarding allocation update due to newer alloc revision in queue",
				"old_modify_index", oldUpdate.AllocModifyIndex,
				"new_modify_index", update.AllocModifyIndex)
			ar.allocUpdatedCh <- oldUpdate
			return
		} else {
			ar.logger.Debug("Discarding allocation update",
				"skipped_modify_index", oldUpdate.AllocModifyIndex,
				"new_modify_index", update.AllocModifyIndex)
		}
	case <-ar.waitCh:
		ar.logger.Trace("AllocRunner has terminated, skipping alloc update",
			"modify_index", update.AllocModifyIndex)
		return
	default:
	}

	// Queue the new update
	ar.allocUpdatedCh <- update
}
```

#### addAllocs代码

```go

// addAlloc is invoked when we should add an allocation
func (c *Client) addAlloc(alloc *structs.Allocation, migrateToken string) error {
	c.allocLock.Lock()
	defer c.allocLock.Unlock()

	// Check if we already have an alloc runner
	if _, ok := c.allocs[alloc.ID]; ok {
		c.logger.Debug("dropping duplicate add allocation request", "alloc_id", alloc.ID)
		return nil
	}

	// Initialize local copy of alloc before creating the alloc runner so
	// we can't end up with an alloc runner that does not have an alloc.
	if err := c.stateDB.PutAllocation(alloc); err != nil {
		return err
	}

	// Collect any preempted allocations to pass into the previous alloc watcher
	var preemptedAllocs map[string]allocwatcher.AllocRunnerMeta
	if len(alloc.PreemptedAllocations) > 0 {
		preemptedAllocs = make(map[string]allocwatcher.AllocRunnerMeta)
		for _, palloc := range alloc.PreemptedAllocations {
			preemptedAllocs[palloc] = c.allocs[palloc]
		}
	}

	// Since only the Client has access to other AllocRunners and the RPC
	// client, create the previous allocation watcher here.
	watcherConfig := allocwatcher.Config{
		Alloc:            alloc,
		PreviousRunner:   c.allocs[alloc.PreviousAllocation],
		PreemptedRunners: preemptedAllocs,
		RPC:              c,
		Config:           c.configCopy,
		MigrateToken:     migrateToken,
		Logger:           c.logger,
	}
	prevAllocWatcher, prevAllocMigrator := allocwatcher.NewAllocWatcher(watcherConfig)

	// Copy the config since the node can be swapped out as it is being updated.
	// The long term fix is to pass in the config and node separately and then
	// we don't have to do a copy.
	c.configLock.RLock()
	arConf := &allocrunner.Config{
		Alloc:               alloc,
		Logger:              c.logger,
		ClientConfig:        c.configCopy,
		StateDB:             c.stateDB,
		Consul:              c.consulService,
		ConsulProxies:       c.consulProxies,
		ConsulSI:            c.tokensClient,
		Vault:               c.vaultClient,
		StateUpdater:        c,
		DeviceStatsReporter: c,
		PrevAllocWatcher:    prevAllocWatcher,
		PrevAllocMigrator:   prevAllocMigrator,
		DynamicRegistry:     c.dynamicRegistry,
		CSIManager:          c.csimanager,
		CpusetManager:       c.cpusetManager,
		DeviceManager:       c.devicemanager,
		DriverManager:       c.drivermanager,
		RPCClient:           c,
	}
	c.configLock.RUnlock()

	ar, err := allocrunner.NewAllocRunner(arConf)
	if err != nil {
		return err
	}

	// Store the alloc runner.
	c.allocs[alloc.ID] = ar

	// Maybe mark the alloc for halt on missing server heartbeats
	c.heartbeatStop.allocHook(alloc)

	go ar.Run()
	return nil
}
```

#### NewAllocRunner代码

```go

// NewAllocRunner returns a new allocation runner.
func NewAllocRunner(config *Config) (*allocRunner, error) {
	alloc := config.Alloc
	tg := alloc.Job.LookupTaskGroup(alloc.TaskGroup)
	if tg == nil {
		return nil, fmt.Errorf("failed to lookup task group %q", alloc.TaskGroup)
	}

	ar := &allocRunner{
		id:                       alloc.ID,
		alloc:                    alloc,
		clientConfig:             config.ClientConfig,
		consulClient:             config.Consul,
		consulProxiesClient:      config.ConsulProxies,
		sidsClient:               config.ConsulSI,
		vaultClient:              config.Vault,
		tasks:                    make(map[string]*taskrunner.TaskRunner, len(tg.Tasks)),
		waitCh:                   make(chan struct{}),
		destroyCh:                make(chan struct{}),
		shutdownCh:               make(chan struct{}),
		state:                    &state.State{},
		stateDB:                  config.StateDB,
		stateUpdater:             config.StateUpdater,
		taskStateUpdatedCh:       make(chan struct{}, 1),
		taskStateUpdateHandlerCh: make(chan struct{}),
		allocUpdatedCh:           make(chan *structs.Allocation, 1),
		deviceStatsReporter:      config.DeviceStatsReporter,
		prevAllocWatcher:         config.PrevAllocWatcher,
		prevAllocMigrator:        config.PrevAllocMigrator,
		dynamicRegistry:          config.DynamicRegistry,
		csiManager:               config.CSIManager,
		cpusetManager:            config.CpusetManager,
		devicemanager:            config.DeviceManager,
		driverManager:            config.DriverManager,
		serversContactedCh:       config.ServersContactedCh,
		rpcClient:                config.RPCClient,
	}

	// Create the logger based on the allocation ID
	ar.logger = config.Logger.Named("alloc_runner").With("alloc_id", alloc.ID)

	// Create alloc broadcaster
	ar.allocBroadcaster = cstructs.NewAllocBroadcaster(ar.logger)

	// Create alloc dir
	ar.allocDir = allocdir.NewAllocDir(ar.logger, config.ClientConfig.AllocDir, alloc.ID)

	ar.taskHookCoordinator = newTaskHookCoordinator(ar.logger, tg.Tasks)

	// Initialize the runners hooks.
	if err := ar.initRunnerHooks(config.ClientConfig); err != nil {
		return nil, err
	}

	// Create the TaskRunners
	if err := ar.initTaskRunners(tg.Tasks); err != nil {
		return nil, err
	}

	return ar, nil
}
```

##### ar.initTaskRunners

```go

// initTaskRunners creates task runners but does *not* run them.
func (ar *allocRunner) initTaskRunners(tasks []*structs.Task) error {
	for _, task := range tasks {
		trConfig := &taskrunner.Config{
			Alloc:                ar.alloc,
			ClientConfig:         ar.clientConfig,
			Task:                 task,
			TaskDir:              ar.allocDir.NewTaskDir(task.Name),
			Logger:               ar.logger,
			StateDB:              ar.stateDB,
			StateUpdater:         ar,
			DynamicRegistry:      ar.dynamicRegistry,
			Consul:               ar.consulClient,
			ConsulProxies:        ar.consulProxiesClient,
			ConsulSI:             ar.sidsClient,
			Vault:                ar.vaultClient,
			DeviceStatsReporter:  ar.deviceStatsReporter,
			CSIManager:           ar.csiManager,
			DeviceManager:        ar.devicemanager,
			DriverManager:        ar.driverManager,
			ServersContactedCh:   ar.serversContactedCh,
			StartConditionMetCtx: ar.taskHookCoordinator.startConditionForTask(task),
		}

		if ar.cpusetManager != nil {
			trConfig.CpusetCgroupPathGetter = ar.cpusetManager.CgroupPathFor(ar.id, task.Name)
		}

		// Create, but do not Run, the task runner
		tr, err := taskrunner.NewTaskRunner(trConfig)
		if err != nil {
			return fmt.Errorf("failed creating runner for task %q: %v", task.Name, err)
		}

		ar.tasks[task.Name] = tr
	}
	return nil
}
```

##### NewTaskRunner

```go

func NewTaskRunner(config *Config) (*TaskRunner, error) {
	// Create a context for causing the runner to exit
	trCtx, trCancel := context.WithCancel(context.Background())

	// Create a context for killing the runner
	killCtx, killCancel := context.WithCancel(context.Background())

	// Initialize the environment builder
	envBuilder := taskenv.NewBuilder(
		config.ClientConfig.Node,
		config.Alloc,
		config.Task,
		config.ClientConfig.Region,
	)

	// Initialize state from alloc if it is set
	tstate := structs.NewTaskState()
	if ts := config.Alloc.TaskStates[config.Task.Name]; ts != nil {
		tstate = ts.Copy()
	}

	tr := &TaskRunner{
		alloc:                  config.Alloc,
		allocID:                config.Alloc.ID,
		clientConfig:           config.ClientConfig,
		task:                   config.Task,
		taskDir:                config.TaskDir,
		taskName:               config.Task.Name,
		taskLeader:             config.Task.Leader,
		envBuilder:             envBuilder,
		dynamicRegistry:        config.DynamicRegistry,
		consulServiceClient:    config.Consul,
		consulProxiesClient:    config.ConsulProxies,
		siClient:               config.ConsulSI,
		vaultClient:            config.Vault,
		state:                  tstate,
		localState:             state.NewLocalState(),
		stateDB:                config.StateDB,
		stateUpdater:           config.StateUpdater,
		deviceStatsReporter:    config.DeviceStatsReporter,
		killCtx:                killCtx,
		killCtxCancel:          killCancel,
		shutdownCtx:            trCtx,
		shutdownCtxCancel:      trCancel,
		triggerUpdateCh:        make(chan struct{}, triggerUpdateChCap),
		waitCh:                 make(chan struct{}),
		csiManager:             config.CSIManager,
		cpusetCgroupPathGetter: config.CpusetCgroupPathGetter,
		devicemanager:          config.DeviceManager,
		driverManager:          config.DriverManager,
		maxEvents:              defaultMaxEvents,
		serversContactedCh:     config.ServersContactedCh,
		startConditionMetCtx:   config.StartConditionMetCtx,
	}

	// Create the logger based on the allocation ID
	tr.logger = config.Logger.Named("task_runner").With("task", config.Task.Name)

	// Pull out the task's resources
	ares := tr.alloc.AllocatedResources
	if ares == nil {
		return nil, fmt.Errorf("no task resources found on allocation")
	}

	tres, ok := ares.Tasks[tr.taskName]
	if !ok {
		return nil, fmt.Errorf("no task resources found on allocation")
	}
	tr.taskResources = tres

	// Build the restart tracker.
	rp := config.Task.RestartPolicy
	if rp == nil {
		tg := tr.alloc.Job.LookupTaskGroup(tr.alloc.TaskGroup)
		if tg == nil {
			tr.logger.Error("alloc missing task group")
			return nil, fmt.Errorf("alloc missing task group")
		}
		rp = tg.RestartPolicy
	}
	tr.restartTracker = restarts.NewRestartTracker(rp, tr.alloc.Job.Type, config.Task.Lifecycle)

	// Get the driver
	if err := tr.initDriver(); err != nil {
		tr.logger.Error("failed to create driver", "error", err)
		return nil, err
	}

	// Initialize the runners hooks. Must come after initDriver so hooks
	// can use tr.driverCapabilities
	tr.initHooks()

	// Initialize base labels
	tr.initLabels()

	// Initialize initial task received event
	tr.appendEvent(structs.NewTaskEvent(structs.TaskReceived))

	return tr, nil
}
```

##### [TaskRunner]initDriver

```go
// initDriver retrives the DriverPlugin from the plugin loader for this task
func (tr *TaskRunner) initDriver() error {
	driver, err := tr.driverManager.Dispense(tr.Task().Driver)
	if err != nil {
		return err
	}
	tr.driver = driver

	schema, err := tr.driver.TaskConfigSchema()
	if err != nil {
		return err
	}
	spec, diag := hclspecutils.Convert(schema)
	if diag.HasErrors() {
		return multierror.Append(errors.New("failed to convert task schema"), diag.Errs()...)
	}
	tr.taskSchema = spec

	caps, err := tr.driver.Capabilities()
	if err != nil {
		return err
	}
	tr.driverCapabilities = caps

	return nil
}
```

 

#### ar.Run 运行

```go

// Run the AllocRunner. Starts tasks if the alloc is non-terminal and closes
// WaitCh when it exits. Should be started in a goroutine.
func (ar *allocRunner) Run() {
	// Close the wait channel on return
	defer close(ar.waitCh)

	// Start the task state update handler
	go ar.handleTaskStateUpdates()

	// Start the alloc update handler
	go ar.handleAllocUpdates()

	// If task update chan has been closed, that means we've been shutdown.
	select {
	case <-ar.taskStateUpdateHandlerCh:
		return
	default:
	}

	// When handling (potentially restored) terminal alloc, ensure tasks and post-run hooks are run
	// to perform any cleanup that's necessary, potentially not done prior to earlier termination

	// Run the prestart hooks if non-terminal
	if ar.shouldRun() {
		if err := ar.prerun(); err != nil {
			ar.logger.Error("prerun failed", "error", err)

			for _, tr := range ar.tasks {
				tr.MarkFailedDead(fmt.Sprintf("failed to setup alloc: %v", err))
			}

			goto POST
		}
	}

	// Run the runners (blocks until they exit)
	ar.runTasks()

POST:
	if ar.isShuttingDown() {
		return
	}

	// Run the postrun hooks
	if err := ar.postrun(); err != nil {
		ar.logger.Error("postrun failed", "error", err)
	}

}
```

##### ar.runTasks

```go
// runTasks is used to run the task runners and block until they exit.
func (ar *allocRunner) runTasks() {
	// Start all tasks
	for _, task := range ar.tasks {
		go task.Run()
	}

	// Block on all tasks except poststop tasks
	for _, task := range ar.tasks {
		if !task.IsPoststopTask() {
			<-task.WaitCh()
		}
	}

	// Signal poststop tasks to proceed to main runtime
	ar.taskHookCoordinator.StartPoststopTasks()

	// Wait for poststop tasks to finish before proceeding
	for _, task := range ar.tasks {
		if task.IsPoststopTask() {
			<-task.WaitCh()
		}
	}
}
```

#### task.Run

```go

// Run the TaskRunner. Starts the user's task or reattaches to a restored task.
// Run closes WaitCh when it exits. Should be started in a goroutine.
func (tr *TaskRunner) Run() {
	defer close(tr.waitCh)
	var result *drivers.ExitResult

	tr.stateLock.RLock()
	dead := tr.state.State == structs.TaskStateDead
	tr.stateLock.RUnlock()

	// if restoring a dead task, ensure that task is cleared and all post hooks
	// are called without additional state updates
	if dead {
		// do cleanup functions without emitting any additional events/work
		// to handle cases where we restored a dead task where client terminated
		// after task finished before completing post-run actions.
		tr.clearDriverHandle()
		tr.stateUpdater.TaskStateUpdated()
		if err := tr.stop(); err != nil {
			tr.logger.Error("stop failed on terminal task", "error", err)
		}
		return
	}

	// Updates are handled asynchronously with the other hooks but each
	// triggered update - whether due to alloc updates or a new vault token
	// - should be handled serially.
	go tr.handleUpdates()

	// If restore failed wait until servers are contacted before running.
	// #1795
	if tr.waitOnServers {
		tr.logger.Info("task failed to restore; waiting to contact server before restarting")
		select {
		case <-tr.killCtx.Done():
			tr.logger.Info("task killed while waiting for server contact")
		case <-tr.shutdownCtx.Done():
			return
		case <-tr.serversContactedCh:
			tr.logger.Info("server contacted; unblocking waiting task")
		}
	}

	select {
	case <-tr.startConditionMetCtx:
		tr.logger.Debug("lifecycle start condition has been met, proceeding")
		// yay proceed
	case <-tr.killCtx.Done():
	case <-tr.shutdownCtx.Done():
		return
	}

MAIN:
	for !tr.shouldShutdown() {
		select {
		case <-tr.killCtx.Done():
			break MAIN
		case <-tr.shutdownCtx.Done():
			// TaskRunner was told to exit immediately
			return
		default:
		}

		// Run the prestart hooks
		if err := tr.prestart(); err != nil {
			tr.logger.Error("prestart failed", "error", err)
			tr.restartTracker.SetStartError(err)
			goto RESTART
		}

		select {
		case <-tr.killCtx.Done():
			break MAIN
		case <-tr.shutdownCtx.Done():
			// TaskRunner was told to exit immediately
			return
		default:
		}

		// Run the task
		if err := tr.runDriver(); err != nil {
			tr.logger.Error("running driver failed", "error", err)
			tr.restartTracker.SetStartError(err)
			goto RESTART
		}

		// Run the poststart hooks
		if err := tr.poststart(); err != nil {
			tr.logger.Error("poststart failed", "error", err)
		}

		// Grab the result proxy and wait for task to exit
	WAIT:
		{
			handle := tr.getDriverHandle()
			result = nil

			// Do *not* use tr.killCtx here as it would cause
			// Wait() to unblock before the task exits when Kill()
			// is called.
			if resultCh, err := handle.WaitCh(context.Background()); err != nil {
				tr.logger.Error("wait task failed", "error", err)
			} else {
				select {
				case <-tr.killCtx.Done():
					// We can go through the normal should restart check since
					// the restart tracker knowns it is killed
					result = tr.handleKill(resultCh)
				case <-tr.shutdownCtx.Done():
					// TaskRunner was told to exit immediately
					return
				case result = <-resultCh:
				}

				// WaitCh returned a result
				if retryWait := tr.handleTaskExitResult(result); retryWait {
					goto WAIT
				}
			}
		}

		// Clear the handle
		tr.clearDriverHandle()

		// Store the wait result on the restart tracker
		tr.restartTracker.SetExitResult(result)

		if err := tr.exited(); err != nil {
			tr.logger.Error("exited hooks failed", "error", err)
		}

	RESTART:
		restart, restartDelay := tr.shouldRestart()
		if !restart {
			break MAIN
		}

		// Actually restart by sleeping and also watching for destroy events
		select {
		case <-time.After(restartDelay):
		case <-tr.killCtx.Done():
			tr.logger.Trace("task killed between restarts", "delay", restartDelay)
			break MAIN
		case <-tr.shutdownCtx.Done():
			// TaskRunner was told to exit immediately
			tr.logger.Trace("gracefully shutting down during restart delay")
			return
		}
	}

	// Ensure handle is cleaned up. Restore could have recovered a task
	// that should be terminal, so if the handle still exists we should
	// kill it here.
	if tr.getDriverHandle() != nil {
		if result = tr.handleKill(nil); result != nil {
			tr.emitExitResultEvent(result)
		}

		tr.clearDriverHandle()

		if err := tr.exited(); err != nil {
			tr.logger.Error("exited hooks failed while cleaning up terminal task", "error", err)
		}
	}

	// Mark the task as dead
	tr.UpdateState(structs.TaskStateDead, nil)

	// Run the stop hooks
	if err := tr.stop(); err != nil {
		tr.logger.Error("stop failed", "error", err)
	}

	tr.logger.Debug("task run loop exiting")
}
```

##### [TaskRunner]runDriver

```go

// runDriver runs the driver and waits for it to exit
// runDriver emits an appropriate task event on success/failure
func (tr *TaskRunner) runDriver() error {

	taskConfig := tr.buildTaskConfig()
	if tr.cpusetCgroupPathGetter != nil {
		cpusetCgroupPath, err := tr.cpusetCgroupPathGetter(tr.killCtx)
		if err != nil {
			return err
		}
		taskConfig.Resources.LinuxResources.CpusetCgroupPath = cpusetCgroupPath
	}

	// Build hcl context variables
	vars, errs, err := tr.envBuilder.Build().AllValues()
	if err != nil {
		return fmt.Errorf("error building environment variables: %v", err)
	}

	// Handle per-key errors
	if len(errs) > 0 {
		keys := make([]string, 0, len(errs))
		for k, err := range errs {
			keys = append(keys, k)

			if tr.logger.IsTrace() {
				// Verbosely log every diagnostic for debugging
				tr.logger.Trace("error building environment variables", "key", k, "error", err)
			}
		}

		tr.logger.Warn("some environment variables not available for rendering", "keys", strings.Join(keys, ", "))
	}

	val, diag, diagErrs := hclutils.ParseHclInterface(tr.task.Config, tr.taskSchema, vars)
	if diag.HasErrors() {
		parseErr := multierror.Append(errors.New("failed to parse config: "), diagErrs...)
		tr.EmitEvent(structs.NewTaskEvent(structs.TaskFailedValidation).SetValidationError(parseErr))
		return parseErr
	}

	if err := taskConfig.EncodeDriverConfig(val); err != nil {
		encodeErr := fmt.Errorf("failed to encode driver config: %v", err)
		tr.EmitEvent(structs.NewTaskEvent(structs.TaskFailedValidation).SetValidationError(encodeErr))
		return encodeErr
	}

	// If there's already a task handle (eg from a Restore) there's nothing
	// to do except update state.
	if tr.getDriverHandle() != nil {
		// Ensure running state is persisted but do *not* append a new
		// task event as restoring is a client event and not relevant
		// to a task's lifecycle.
		if err := tr.updateStateImpl(structs.TaskStateRunning); err != nil {
			//TODO return error and destroy task to avoid an orphaned task?
			tr.logger.Warn("error persisting task state", "error", err)
		}
		return nil
	}

	// Start the job if there's no existing handle (or if RecoverTask failed)
	handle, net, err := tr.driver.StartTask(taskConfig)
	if err != nil {
		// The plugin has died, try relaunching it
		if err == bstructs.ErrPluginShutdown {
			tr.logger.Info("failed to start task because plugin shutdown unexpectedly; attempting to recover")
			if err := tr.initDriver(); err != nil {
				taskErr := fmt.Errorf("failed to initialize driver after it exited unexpectedly: %v", err)
				tr.EmitEvent(structs.NewTaskEvent(structs.TaskDriverFailure).SetDriverError(taskErr))
				return taskErr
			}

			handle, net, err = tr.driver.StartTask(taskConfig)
			if err != nil {
				taskErr := fmt.Errorf("failed to start task after driver exited unexpectedly: %v", err)
				tr.EmitEvent(structs.NewTaskEvent(structs.TaskDriverFailure).SetDriverError(taskErr))
				return taskErr
			}
		} else {
			// Do *NOT* wrap the error here without maintaining whether or not is Recoverable.
			// You must emit a task event failure to be considered Recoverable
			tr.EmitEvent(structs.NewTaskEvent(structs.TaskDriverFailure).SetDriverError(err))
			return err
		}
	}

	tr.stateLock.Lock()
	tr.localState.TaskHandle = handle
	tr.localState.DriverNetwork = net
	if err := tr.stateDB.PutTaskRunnerLocalState(tr.allocID, tr.taskName, tr.localState); err != nil {
		//TODO Nomad will be unable to restore this task; try to kill
		//     it now and fail? In general we prefer to leave running
		//     tasks running even if the agent encounters an error.
		tr.logger.Warn("error persisting local task state; may be unable to restore after a Nomad restart",
			"error", err, "task_id", handle.Config.ID)
	}
	tr.stateLock.Unlock()

	tr.setDriverHandle(NewDriverHandle(tr.driver, taskConfig.ID, tr.Task(), net))

	// Emit an event that we started
	tr.UpdateState(structs.TaskStateRunning, structs.NewTaskEvent(structs.TaskStarted))
	return nil
}
```



##### docker driver StartTask

```go

func (d *Driver) StartTask(cfg *drivers.TaskConfig) (*drivers.TaskHandle, *drivers.DriverNetwork, error) {
	if _, ok := d.tasks.Get(cfg.ID); ok {
		return nil, nil, fmt.Errorf("task with ID %q already started", cfg.ID)
	}

	var driverConfig TaskConfig

	if err := cfg.DecodeDriverConfig(&driverConfig); err != nil {
		return nil, nil, fmt.Errorf("failed to decode driver config: %v", err)
	}

	if driverConfig.Image == "" {
		return nil, nil, fmt.Errorf("image name required for docker driver")
	}

	driverConfig.Image = strings.TrimPrefix(driverConfig.Image, "https://")

	handle := drivers.NewTaskHandle(taskHandleVersion)
	handle.Config = cfg

	// Initialize docker API clients
	client, _, err := d.dockerClients()
	if err != nil {
		return nil, nil, fmt.Errorf("Failed to connect to docker daemon: %s", err)
	}

	id, err := d.createImage(cfg, &driverConfig, client)
	if err != nil {
		return nil, nil, err
	}

	if runtime.GOOS == "windows" {
		err = d.convertAllocPathsForWindowsLCOW(cfg, driverConfig.Image)
		if err != nil {
			return nil, nil, err
		}
	}

	containerCfg, err := d.createContainerConfig(cfg, &driverConfig, driverConfig.Image)
	if err != nil {
		d.logger.Error("failed to create container configuration", "image_name", driverConfig.Image,
			"image_id", id, "error", err)
		return nil, nil, fmt.Errorf("Failed to create container configuration for image %q (%q): %v", driverConfig.Image, id, err)
	}

	startAttempts := 0
CREATE:
	container, err := d.createContainer(client, containerCfg, driverConfig.Image)
	if err != nil {
		d.logger.Error("failed to create container", "error", err)
		client.RemoveContainer(docker.RemoveContainerOptions{
			ID:    containerCfg.Name,
			Force: true,
		})
		return nil, nil, nstructs.WrapRecoverable(fmt.Sprintf("failed to create container: %v", err), err)
	}

	d.logger.Info("created container", "container_id", container.ID)

	// We don't need to start the container if the container is already running
	// since we don't create containers which are already present on the host
	// and are running
	if !container.State.Running {
		// Start the container
		if err := d.startContainer(container); err != nil {
			d.logger.Error("failed to start container", "container_id", container.ID, "error", err)
			client.RemoveContainer(docker.RemoveContainerOptions{
				ID:    container.ID,
				Force: true,
			})
			// Some sort of docker race bug, recreating the container usually works
			if strings.Contains(err.Error(), "OCI runtime create failed: container with id exists:") && startAttempts < 5 {
				startAttempts++
				d.logger.Debug("reattempting container create/start sequence", "attempt", startAttempts, "container_id", id)
				goto CREATE
			}
			return nil, nil, nstructs.WrapRecoverable(fmt.Sprintf("Failed to start container %s: %s", container.ID, err), err)
		}

		// Inspect container to get all of the container metadata as much of the
		// metadata (eg networking) isn't populated until the container is started
		runningContainer, err := client.InspectContainerWithOptions(docker.InspectContainerOptions{
			ID: container.ID,
		})
		if err != nil {
			client.RemoveContainer(docker.RemoveContainerOptions{
				ID:    container.ID,
				Force: true,
			})
			msg := "failed to inspect started container"
			d.logger.Error(msg, "error", err)
			client.RemoveContainer(docker.RemoveContainerOptions{
				ID:    container.ID,
				Force: true,
			})
			return nil, nil, nstructs.NewRecoverableError(fmt.Errorf("%s %s: %s", msg, container.ID, err), true)
		}
		container = runningContainer
		d.logger.Info("started container", "container_id", container.ID)
	} else {
		d.logger.Debug("re-attaching to container", "container_id",
			container.ID, "container_state", container.State.String())
	}

	if containerCfg.HostConfig.CPUSet == "" && cfg.Resources.LinuxResources.CpusetCgroupPath != "" {
		if err := setCPUSetCgroup(cfg.Resources.LinuxResources.CpusetCgroupPath, container.State.Pid); err != nil {
			return nil, nil, fmt.Errorf("failed to set the cpuset cgroup for container: %v", err)
		}
	}

	collectingLogs := !d.config.DisableLogCollection

	var dlogger docklog.DockerLogger
	var pluginClient *plugin.Client

	if collectingLogs {
		dlogger, pluginClient, err = d.setupNewDockerLogger(container, cfg, time.Unix(0, 0))
		if err != nil {
			d.logger.Error("an error occurred after container startup, terminating container", "container_id", container.ID)
			client.RemoveContainer(docker.RemoveContainerOptions{ID: container.ID, Force: true})
			return nil, nil, err
		}
	}

	// Detect container address
	ip, autoUse := d.detectIP(container, &driverConfig)

	net := &drivers.DriverNetwork{
		PortMap:       driverConfig.PortMap,
		IP:            ip,
		AutoAdvertise: autoUse,
	}

	// Return a driver handle
	h := &taskHandle{
		client:                client,
		waitClient:            waitClient,
		dlogger:               dlogger,
		dloggerPluginClient:   pluginClient,
		logger:                d.logger.With("container_id", container.ID),
		task:                  cfg,
		containerID:           container.ID,
		containerImage:        container.Image,
		doneCh:                make(chan bool),
		waitCh:                make(chan struct{}),
		removeContainerOnExit: d.config.GC.Container,
		net:                   net,
	}

	if err := handle.SetDriverState(h.buildState()); err != nil {
		d.logger.Error("error encoding container occurred after startup, terminating container", "container_id", container.ID, "error", err)
		if collectingLogs {
			dlogger.Stop()
			pluginClient.Kill()
		}
		client.RemoveContainer(docker.RemoveContainerOptions{ID: container.ID, Force: true})
		return nil, nil, err
	}

	d.tasks.Set(cfg.ID, h)
	go h.run()

	return handle, net, nil
}
```

