# 配置ssh
## 修改端口

1. 修改配置文件/etcd/ssh/sshd_config
    找到port修改为2222
2. 重启ssh服务
    systemctl restart sshd

### 异常
1. `error: Bind to port 2222 on 0.0.0.0 failed: Permission denied.`
    > https://laowangblog.com/fix-centos-modify-ssh-port-error-bind-to-port-1024-on-0-0-0-0-failed-permission-denied.html
    1. 安装修改工具`yum install policycoreutils-python`
    2. 查看selinux中ssh占用的端口`semanage port -l | grep ssh`
    3. 新增目标端口`semanage port -a -t ssh_port_t -p tcp 2222`
    4. 重启sshd 服务`systemctl restart sshd`
2. 对文件无权限读写
    增加参数 --privileged=true
3. GitLab 遭遇 “Chef Infra Client failed.” 报错解决
    https://huangzz.xyz/gitlab-zao-yu-chef-infra-client-failed-bao-cuo-jie-jue.html
    重新配置 docker exec -it gitlab gitlab-ctl reconfigure
4. Error executing action `create` on resource 'storage_directory[/var/opt/gitlab/.ssh]'
    https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/2280
    https://blog.csdn.net/BigData_Mining/article/details/87801964
    
