#!/bin/env bash
#后台运行，全称：detach
#docker run -d\ 
#将容器内部端口向外映射
#-p 8443:443\
#将容器内80端口映射至宿主机8090端口，这是访问gitlab的端口
#-p 8090:80\
#将容器内22端口映射至宿主机8022端口，这是访问ssh的端口
#-p 8022:22\
#--restart always\
#--name gitlab\
#将容器/etc/gitlab目录挂载到宿主机/usr/local/gitlab/etc目录下，若宿主机内此目录不存在将会自动创建
#-v /data/gitlab/etc:/etc/gitlab\
#-v /data/gitlab/log:/var/log/gitlab\
#-v /data/gitlab/data:/var/opt/gitlab\
#--privileged=true docker.io/twang2218/gitlab-ce-zh

docker run -d -p 8443:443 -p 8090:80 -p 8022:22 --restart always --name gitlab -v /data/gitlab/etc:/etc/gitlab -v /data/gitlab/log:/var/log/gitlab -v /data/gitlab/data:/var/opt/gitlab -v /data/gitlab/gitlab.yml:/var/opt/gitlab/gitlab-rails/etc/gitlab.yml --privileged=true docker.io/twang2218/gitlab-ce-zh