# Systemd

https://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html

## 查看日志命令
在 Linux 系统中，您可以使用 `journalctl` 命令来查看系统的日志，这些日志通常由 Systemd 日志服务管理。Systemd 是现代 Linux 系统中的初始化系统和系统管理器，它负责启动和管理各种服务，并收集系统日志。

以下是使用 `journalctl` 命令来查看日志的一些常见用法：

1. 查看所有日志：
   ```bash
   journalctl
   ```
   这会显示系统中所有可用的日志，从最新的开始显示。

2. 查看最近的日志（默认显示最近的 10 行）：
   ```bash
   journalctl -n 10
   ```

3. 查看特定单元（服务）的日志：
   ```bash
   journalctl -u unit_name
   ```
   将 `unit_name` 替换为您要查看日志的服务名称。

4. 查看某个时间范围内的日志：
   ```bash
   journalctl --since "2023-07-20 00:00:00" --until "2023-07-21 00:00:00"
   ```
   将日期和时间替换为您要查看日志的时间范围。

5. 查看指定 PID 的日志：
   ```bash
   journalctl _PID=1234
   ```
   将 `1234` 替换为您要查看日志的进程 PID。

6. 使用 `grep` 过滤日志：
   ```bash
   journalctl | grep "keyword"
   ```
   使用 `grep` 命令过滤包含特定关键词的日志。

请注意，查看日志可能需要 root 权限或使用 `sudo` 命令来运行，以便访问系统日志。根据您的系统配置，可能还有其他选项和过滤器可用，您可以使用 `man journalctl` 命令来查看 `journalctl` 的完整用法和选项。