# 常用命令

进入命令行模式：
进入界面模式：

设置root允许远程连接：
```
# 安装ssh服务
sudo apt update 
sudo apt install ssh -y
# 启动ssh服务
sudo systemctl start sshd
# 设置ssh服务开机启动
sudo systemctl enable sshd
sudo systemctl status sshd
```