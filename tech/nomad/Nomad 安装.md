# Nomad 安装

## 安装

### 需要先安装好Consul

参考之前的文章



### 安装Nomad

#### 下载

官网下载：https://releases.hashicorp.com/nomad

下载`wget https://releases.hashicorp.com/nomad/1.2.3/nomad_1.2.3_linux_amd64.zip`

#### 解压

```shell
unzip nomad_1.2.3_linux_amd64.zip -d /usr/local/bin
chown root:root /usr/local/bin/nomad
```

#### 安装自动补全功能

```shell
nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad
```

#### 创建数据目录和配置目录

```she
mkdir /opt/nomad
mkdir /etc/nomad.d
```

#### 添加nomad到systemd

创建service文件`touch /etc/systemd/system/nomad.service`

```shell
[Unit]
Description=Nomad
Documentation=https://www.nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

# When using Nomad with Consul it is not necessary to start Consul first. These
# lines start Consul before Nomad as an optimization to avoid Nomad logging
# that Consul is unavailable at startup.
#Wants=consul.service
#After=consul.service

[Service]

# Nomad server should be run as the nomad user. Nomad clients
# should be run as root
User=nomad
Group=nomad

ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=65536
LimitNPROC=infinity
Restart=on-failure
RestartSec=2

## Configure unit start rate limiting. Units which are started more than
## *burst* times within an *interval* time span are not permitted to start any
## more. Use `StartLimitIntervalSec` or `StartLimitInterval` (depending on
## systemd version) to configure the checking interval and `StartLimitBurst`
## to configure how many starts per interval are allowed. The values in the
## commented lines are defaults.

# StartLimitBurst = 5

## StartLimitIntervalSec is used for systemd versions >= 230
# StartLimitIntervalSec = 10s

## StartLimitInterval is used for systemd versions < 230
# StartLimitInterval = 10s

TasksMax=infinity
OOMScoreAdjust=-1000

[Install]
WantedBy=multi-user.target
```

配置说明：

The following parameters are set for the `[Unit]` stanza:

- [`Description`](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Description=) - Free-form string describing the Nomad service
- [`Documentation`](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Documentation=) - Link to the Nomad documentation
- [`Wants`](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#Wants=) - Configure a dependency on the network service
- [`After`](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#After=) - Configure an ordering dependency on the network service being started before the Nomad service

The following parameters are set for the `[Service]` stanza:

- [`User`, `Group`](https://www.freedesktop.org/software/systemd/man/systemd.exec.html#User=) - Nomad servers should run as the nomad user. Nomad clients should run as root.
- [`ExecReload`](https://www.freedesktop.org/software/systemd/man/systemd.service.html#ExecReload=) - Send Nomad a `SIGHUP` signal to trigger a configuration reload
- [`ExecStart`](https://www.freedesktop.org/software/systemd/man/systemd.service.html#ExecStart=) - Start Nomad with the `agent` argument and path to a directory of configuration files
- [`KillMode`](https://www.freedesktop.org/software/systemd/man/systemd.kill.html#KillMode=) - Treat Nomad as a single process
- [`LimitNOFILE`, `LimitNPROC`](https://www.freedesktop.org/software/systemd/man/systemd.exec.html#Process Properties) - Disable limits for file descriptors and processes
- [`RestartSec`](https://www.freedesktop.org/software/systemd/man/systemd.service.html#RestartSec=) - Restart Nomad after 2 seconds of it being considered 'failed'
- [`Restart`](https://www.freedesktop.org/software/systemd/man/systemd.service.html#Restart=) - Restart Nomad unless it returned a clean exit code
- [`StartLimitBurst`, `StartLimitIntervalSec`](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#StartLimitIntervalSec=interval) - Configure unit start rate limiting
- [`TasksMax`](https://www.freedesktop.org/software/systemd/man/systemd.resource-control.html#TasksMax=N) - Disable task limits (only available in systemd >= 226)

The following parameters are set for the `[Install]` stanza:

- [`WantedBy`](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#WantedBy=) - Creates a weak dependency on Nomad being started by the multi-user run level

## 配置Nomad

### 通用配置

配置文件:`/etc/nomad.d/nomad.hcl`

确认权限`chmod 700 /etc/nomad.d`

配置内容：

```shell
datacenter = "dc1"
data_dir = "/opt/nomad"
```

- [`datacenter`](https://www.nomadproject.io/docs/configuration#datacenter) - The datacenter in which the agent is running.
- [`data_dir`](https://www.nomadproject.io/docs/configuration#data_dir) - The data directory for the agent to store state.

### server 配置

配置文件：`/etc/nomad.d/server.hcl`

```shell
server {
  enabled = true
  bootstrap_expect = 3
}
```

This [`server`](https://www.nomadproject.io/docs/configuration/server) stanza contains the following parameters:

- [`enabled`](https://www.nomadproject.io/docs/configuration/server#enabled) - Specifies if this agent should run in server mode. All other server options depend on this value being set.
- [`bootstrap_expect`](https://www.nomadproject.io/docs/configuration/server#bootstrap_expect)- The number of expected servers in the cluster. Either this value should not be provided or the value must agree with other servers in the cluster.

### client 配置

配置文件：`/etc/nomad.d/client.hcl`

```shell
client {
  enabled = true
}
```

This [`client`](https://www.nomadproject.io/docs/configuration/client) stanza contains the following parameters:

- [`enabled`](https://www.nomadproject.io/docs/configuration/client#enabled) - Specifies if this agent should run in client mode. All other client options depend on this value being set.



## ACL 配置

为了安全，主要用户Nomad的访问控制

详细参考：https://learn.hashicorp.com/collections/nomad/access-control

## TLS配置

Nomad不允许，明文传输，所以加密传输是必须的

参考：https://learn.hashicorp.com/tutorials/nomad/security-enable-tls

## 启动Nomad

```shell
systemctl enabled nomad
systemctl start nomad
systemctl status nomad
```

