# Linux-渣渣

## ubuntu 安装go

https://cloud.tencent.com/developer/article/1623121

## 配置允许root远程登录

编辑/etc/ssh/sshd_config文件；

sudo vim /etc/ssh/sshd_config

找到配置参数：PermitRootLogin 

将该参数后面的值修改为yes即可

## 配置账户密码

passwd {username} # 就会提示输入密码了

## 配置免密登录

将本主机生成的ssh公钥复制到目标机器`~/.ssh/authorized_keys` 10.0.2.15

