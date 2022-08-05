# Linux-渣渣

## ngrok安装
https://ngrok.com/download
1.下载
sudo tar xvzf ~/Downloads/ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin
## centos 更换为国内的源
> https://blog.csdn.net/wudinaniya/article/details/105758739
备份源：
## 固定ip配置
https://cloud.tencent.com/developer/article/1721181
https://blog.csdn.net/johnnycode/article/details/40624403

配置完成以后，可能需要禁用NetworkManager
```
systemctl stop NetworkManager
systemctl disable NetworkManager
```

## 后台启动服务

nohup {cmd} > {logfile} 2>&1 &

## 修改hostname

永久性：hostnamectl set-hostname {new_hostname}

暂时：hostname {new hostname}



> 修改hostname需要修改相应的hosts文件

## 远程复制

scp [source] [target]

scp {localfile} {username}@{remote_ip}:{dir}

## 查看系统版本

cat /proc/version

## ubuntu 允许root远程登录

vim /etc/ssh/sshd_config

PermitRootLogin 改为yes



重启ssh服务，systemctl restart ssh

## Ubuntu 20 打开sqllite3

https://blog.csdn.net/qq_31878883/article/details/94389303



 ./sqlite3: No such file or directory



apt-get install lib32z1



https://www.sqlite.org/cli.html

## pid ppid tgid 的区别

PID：流程ID
PPID：父进程ID（启动此PID的那个）
TGID：线程组ID

tid：线程的真实pid

https://blog.csdn.net/u012398613/article/details/52183708

## pstree 命令

-p {pid} 查看pid的进程树



## shell 循环

可以使用for循环

```shell
for((i=1;i<=10;i++));  
do   
echo $(expr $i \* 3 + 1);  
done  
```

可以使用while循环：

```shell
while [ True ]; do
    echo 'running'
    sleep 2
done
```



## systemctl

systemctl 

--type=‘’ 筛选类型

--state ='筛选状态'

## 如何解读 Ubuntu的server --status-all

https://askubuntu.com/questions/407075/how-to-read-service-status-all-results

https://ubuntuqa.com/article/1040.html

## ssh生成公私钥

https://www.jianshu.com/p/31cbbbc5f9fa

`ssh-keygen -t rsa -C "your_email@example.com"`



## ubuntu 安装go

> https://cloud.tencent.com/developer/article/1623121

完成下面的步骤，在 Ubuntu 20.04 上安装 Go

### 1.1 下载 Go 压缩包

在写这篇文章的时候，Go 的最新版为 1.14.2。在我们下载安装包时，请浏览[Go 官方下载页面](https://yq.aliyun.com/go/articleRenderRedirect?url=https%3A%2F%2Fgolang.org%2Fdl%2F),并且检查一下是否有新的版本可用。

以 root 或者其他 sudo 用户身份运行下面的命令，下载并且解压 Go 二进制文件到`/usr/local`目录：

```javascript
wget -c https://go.dev/dl/go1.17.7.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
```

### 1.2 调整环境变量

通过将 Go 目录添加到`$PATH`环境变量，系统将会知道在哪里可以找到 Go 可执行文件。

这个可以通过添加下面的行到`/etc/profile`文件（系统范围内安装）或者`$HOME/.profile`文件（当前用户安装）：

```javascript
export PATH=$PATH:/usr/local/go/bin
```

保存文件，并且重新加载新的PATH 环境变量到当前的 shell 会话：

```javascript
source ~/.profile
```

## 配置允许root远程登录

编辑/etc/ssh/sshd_config文件；

sudo vim /etc/ssh/sshd_config

找到配置参数：PermitRootLogin 

将该参数后面的值修改为yes即可

## 配置账户密码

passwd {username} # 就会提示输入密码了

## 配置免密登录

将本主机生成的ssh公钥复制到目标机器`~/.ssh/authorized_keys` 10.0.2.15

