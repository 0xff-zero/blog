# Linux-渣渣



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

