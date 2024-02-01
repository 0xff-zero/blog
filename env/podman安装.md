# podman 安装说明【官网翻译】
[下载桌面版本](https://podman-desktop.io/downloads)
## 在macOS 和 windows 安装
虽然 "容器是 Linux 的"，但 Podman 也能在 Mac 和 Windows 上运行，它提供本地 podman CLI，并嵌入一个客户 Linux 系统来启动你的容器。该客户机被称为 Podman 机器，使用 podman 机器命令进行管理。Mac 和 Windows 上的 Podman 还监听 Docker API 客户端，支持直接使用基于 Docker 的工具，并支持从您选择的语言进行编程访问。
### macOS
在 Mac 上，每个 Podman 机器都由虚拟机提供支持。安装完成后，可直接从终端中的 Unix shell 运行 podman 命令，与机器虚拟机中运行的 podman 服务进行远程通信。

> 可以从[Podman io](https://podman.io/)或[Github release page](https://github.com/containers/podman/releases)下载.

尽管不建议，Podman 可以通过Homebrew 获取安装。
```
brew install podman
```

安装后，需要创建并启动一个 Podman 机器

```
podman machine init
podman machine start
```
可以通过下面命令验证安装信息：
```
podman info
```

### Windows
在windows上，每个 Podman 机器后端都有虚拟化的Windows 的linux子系统（WSLv2）支持。安装完成后，可以在windows的PowerShell（或者cmd）运行 Podman 命令与虚拟子系统重的Podman 机器，进行远程通信。如果你喜欢linux 提示符或者linux工具，也可以通过WSL实例直接访问Podman .

Windows 下按照指引[Podman for windows guide](https://github.com/containers/podman/blob/main/docs/tutorials/podman-for-windows.md)