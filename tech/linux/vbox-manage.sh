 #!/bin/bash
################################################################################
#
# 通过命令完成VirtualBox操作
#包括:创建 删除 启动 停止 重启 快照 列表查询等
# certor:xinfei
###############################################################################

## 虚拟机名称

## 被拷贝虚拟机的虚拟机名称
# vmC
## 虚拟机类型
osType="Linux_64"
## 虚拟机存放路径
baseFolder="/home/data/VirtualBox/"
## 虚拟机磁盘路径
# file
## 虚拟机磁盘大小 单位M 默认20G
size=2000
## 需要安装镜像名称
medium="/home/data/VirtualBox/images/CentOS-7-x86_64-DVD-2207-02.iso"
## 网络模式 默认桥接
nic="bridged"
## 宿主机的网卡名称
bridgeadapter="em1"
## 虚拟机内存大小
memory=4096
##虚拟机cpu个数
cpus=2
## 快照名称 
# snapshot
## 快照描述
description=""

###################################
##################################

printHelp() {
 echo "使用 VirtualBox-Construct.sh 格式"
 echo "options 必填  flages默认都可以不需要指定 除非修改某一项需要指向"
 echo "  "
 echo "./VirtualBox-Construct.sh [options] [flages] [content] [flages] ...."
 echo "    "
 echo "options:"
 echo "  create :创建新的虚拟机啊 "
 echo "     [flages]:"
 echo "       --name <content>                                     :虚拟机名称 "
 echo "       --ostype <Linux_64|Ubunt_64|Windows10|RedHat_64...>  :虚拟机类型 默认Linux_64"
 echo "       --basefolder <content>                               :虚拟机存放路径 默认/data/VirtualBox/${name}"
 echo "       --filename <content>                                 :虚拟机磁盘存放位置 默认/data/VirtualBox/disk/"
 echo "       --size <content>                                     :虚拟机磁盘大小 单位M  默认 20G"
 echo "       --medium <content>                                   :虚拟机镜像路径以及镜像名称 /*iso 默认/data/VirtualBox/images/CentOS-7-x86_64-DVD-1611.iso"
 echo "       --nic<1-N> <nat|bridged|intnet|hostonly...>          :虚拟机网络设置  默认bridged 桥接模式"
 echo "       --bridgeadapter<1-N> <content>                       :虚拟机使用主机的哪一个接口 默认em1"
 echo "       --memory <content>                                   :虚拟机内存大小 单位M 默认4G"
 echo "       --cpus <content>                                     :虚拟机cpu个数  默认2个"
 echo "        "
 echo "  clone :克隆虚拟机"
 echo "     [flages]:"
 echo "       --name <content>                                     :虚拟机名称 "
 echo "       --cname <content>                                    :被克隆虚拟机名称 默认centos7VMServer0"
 echo "       --basefolder <content>                               :虚拟机存放路径 默认/data/VirtualBox/${name}"
 echo "       --size <content>                                     :虚拟机磁盘大小 单位M  默认 20G"
 echo "       --memory <content>                                   :虚拟机内存大小 单位M 默认4G"
 echo "       --cpus <content>                                     :虚拟机cpu个数  默认2个"
 echo " "
 echo "  delete :删除虚拟机"
 echo "     [flages]:"
 echo "       --name <content>                                     :虚拟机名称 "
 echo " "
 echo "  start :启动虚拟机"
 echo "     [flages:]"
 echo "       --name <content>                                     :虚拟机名称 "
 echo " "
 echo "  stop :停止虚拟机"
 echo "     [flages:]"
 echo "       --name <content>                                     :虚拟机名称 "
 echo " "
 echo "  restart :重启虚拟机"
 echo "     [flages:]"
 echo "       --name <content>                                     :虚拟机名称 "
 echo " "
 echo "  snapshot :快照"
 echo "     [flages:]"
 echo "       --name <content>                                     :虚拟机名称 "
 echo "       --snapshotname <content>                             :快照名称名称 "
 echo "       --description <content>                              :快照描述 默认 \${name}快照 "
 echo " "
 echo "  snapshotrestore :快照回复"
 echo "     [flages:]"
 echo "       --name <content>                                     :虚拟机名称 "
 echo "       --snapshotname <content>                             :快照名称名称 "
 echo " "
 echo "  snapshotdelete :删除指定快照"
 echo "     [flages:]"
 echo "       --name <content>                                     :虚拟机名称 "
 echo "       --snapshotname <content>                             :快照名称名称 "
 echo " "
 echo "  vmlist :列出所有已经创建虚拟机"
 echo " "
 echo "  runlist :列出正在运行的虚拟机"
 echo " "
 echo "  snapshotlist"
 echo "     [flages:]"
 echo "       --name <content>                                     :虚拟机名称 "
 echo " "
 echo "示例:"
 echo "创建"
 echo "./VirtualBox-Construct.sh create --name centos7VMServer0 --ostype Linux_64 --basefolder /data/VirtualBox/centos7VMServer0 --filename /data/VirtualBox/disk --size 20000 --medium /data/VirtualBox/images/CentOS-7-x86_64-DVD-1611.iso --nic1 bridged --bridgeadapter1 em1 --memory 4096 --cpus 2"
 echo "  "
 echo "克隆"
 echo "./VirtualBox-Construct.sh clone --cname centos7VMServer0 --name centos7VMServer2 --basefolder /data/VirtualBox/centos7VMServer2 --size 20000 --memory 4096 --cpus 2 " 
 echo " "
 echo "删除"
 echo "./VirtualBox-Construct.sh delete --name centos7VMServer1"
 echo " "
 echo "启动"
 echo "./VirtualBox-Construct.sh start --name centos7VMServer1"
 echo " "
 echo "停止"
 echo "./VirtualBox-Construct.sh stop --name centos7VMServer1"
 echo " "
 echo "重启"
 echo "./VirtualBox-Construct.sh restart --name centos7VMServer1"
 echo " "
 echo "快照"
 echo "./VirtualBox-Construct.sh snapshot --name centos7VMServer1 --snapshotname centos7VMServer1快照 --description centos7VMServer1快照-2020-11-12"
 echo " "
 echo "回复快照"
 echo "./VirtualBox-Construct.sh snapshotrestore --name centos7VMServer1 --snapshotname centos7VMServer1快照" 
 echo " "
 echo "快照删除"
 echo "./VirtualBox-Construct.sh snapshotdelete --name centos7VMServer1 --snapshotname centos7VMServer1快照"
 echo " "
 echo "列出已经创建虚拟机"
 echo "./VirtualBox-Construct.sh vmlist"
 echo " "
 echo "列出正在运行虚拟机"
 echo "./VirtualBox-Construct.sh runlist"
 echo " "
 echo "列出指定虚拟机快照"
 echo "./VirtualBox-Construct.sh snapshotlist --name centos7VMServer1"
}

checkFlags(){
 params=$1
 num=$2
 nameTime=0
 cnameTime=0
 floderTime=0
 snapshotTime=0
 for((i=1;i<=$num;i++))
   do
     case ${params[$i]} in
       --name)
         nameTime=$(expr $nameTime + 1)
         name=${params[$i+1]}
       ;;
      --cname)
         cnameTime=$(expr $cnameTime + 1)
         vmCName=${params[$i+1]}
       ;;
      --snapshotname)
         snapshotTime=$(expr $snapshotTime + 1)
         snapshotName=${params[$i+1]}
       ;;
      --ostype)
         osType=${params[$i+1]}
       ;;
      --basefolder)
         baseFolder=${params[$i+1]}
         floderTime=$(expr $floderTime + 1)
       ;;
      --filename)
         fileName=${params[$i+1]}
       ;;
      --size)
         size=${params[$i+1]}
       ;;
      --medium)
         medium=${params[$i+1]}
       ;;
      --nic*)
         nic=${params[$i+1]}
       ;;
      --bridgeadapter*)
         bridgeadapter=${params[$i+1]}
       ;;
      --memory)
         memory=${params[$i+1]}
       ;;
      --cpus)
        cpus=${params[$i+1]}
       ;;
      --description)
        description=${params[$i+1]}
       ;;
      *)
       ;;
     esac
  done

 if [ $nameTime -eq 0 ] || [ $nameTime -ge 2 ];then
    echo "缺少--name 参数"
    exit 1
 fi
 if [ $floderTime -eq 0 ];then
    baseFolder="$baseFolder/$name"
 fi
 if [ ${params[0]} == "clone" ];then
    if [ $cnameTime -eq 0 ] || [ $cnameTime -ge 2 ];then
    echo "缺少--cname 参数"
    exit 1
    fi
 fi
 if [ ${params[0]} == "snapshot" ];then
   if [ $snapshotTime -eq 0 ] || [ $snapshotTime -ge 2 ] ;then
    echo "缺少--snapshotTime 参数"
    exit 1
   fi
 fi
}

createVM() {
 params=($1)
 num=$2
 checkFlags $params $num
 ## 检测虚拟机是否存在
 runVM=`vboxmanage list vms | grep -w $name | awk '{print \$1}'`
 echo "runVM:$runVM"
 if [ "$runVM" == \"$name\" ];then
  echo "虚拟机已经创建了"
  exit 0
 fi
 ## 检测存放虚拟机目录是否存在
 if [ ! -d "$baseFolder" ];then
   mkdir -p $baseFolder
 fi
 echo "1\. 创建虚拟机"
 VBoxManage createvm --name $name --ostype $osType --register --basefolder $baseFolder
 echo "2\. 创建虚拟磁盘"
 echo "VBoxManage createvdi --filename ${fileName}/${name}.vdi --size $size"
 VBoxManage createvdi --filename ${fileName}/${name}.vdi --size $size

 echo "3\. 创建虚拟机的硬盘控制器"
 VBoxManage storagectl $name --name ${name}_controller_1 --add ide
 echo "4\. 挂载虚拟硬盘和虚拟光驱"
 VBoxManage storageattach $name --storagectl ${name}_controller_1 --type hdd --port 0 --device 0 --medium $fileName/${name}.vdi
 VBoxManage storageattach $name --storagectl ${name}_controller_1 --type dvddrive --port 1 --device 0 --medium $medium
 echo "5\. 设置启动顺序"
 VBoxManage modifyvm $name --boot1 dvd
 VBoxManage modifyvm $name --boot2 disk
 echo "6\. 查看自己的网卡，并创建桥接网络"
 VBoxManage modifyvm $name --nic1 $nic --cableconnected1 on --nictype1 82540EM --bridgeadapter1 $bridgeadapter --intnet1 brigh1 --macaddress1 auto
 echo "7\. VRDE模块"
 VBoxManage modifyvm $name --vrde on
 echo "8\. 调整系统参数CPU、内存等参数"
 VBoxManage modifyvm $name --memory $memory
 VBoxManage modifyvm $name --cpus $cpus
 echo "9\. 启动虚拟机"
 VBoxHeadless -startvm $name 
}

cloneVM() {
 params=($1)
 num=$2
 checkFlags $params $num
 ## 检测存放虚拟机目录是否存在
 if [ ! -d "$baseFolder" ];then
   mkdir -p $baseFolder
 fi
 ## 1\. 检测要拷贝的虚拟机是否以及关闭
 runVM=`vboxmanage list runningvms | grep -w $vmCName | awk '{print \$1}'`
 if [ "$runVM" == \"$vmCName\" ];then
  echo "被需要拷贝的虚拟机正在启动中 是否需要关闭 [y/n]"
  read onoff
   if [ "$onoff" == y ];then 
     VBoxManage controlvm ${vmCName} poweroff
  else
    exit 0
  fi
 fi
 ## 2\. 拷贝
 VBoxManage clonevm $vmCName --name $name --register --basefolder $baseFolder
 ## 3\. 查看列表
 VBoxManage list vms
 ## 4\. 设置远程连接
 VBoxManage modifyvm $name --vrde on --memory $memory --cpus $cpus
 ## 5\. 启动
 VBoxManage startvm $name -type headless
}

deleteVM() {
 params=($1)
 num=$2
 checkFlags $params $num
 ## 1\. 检测要删除的虚拟机是否以及关闭
 runVM=`vboxmanage list runningvms | grep -w $name | awk '{print \$1}'`
 if [ "$runVM" == \"$name\" ];then
  echo "被需要删除的虚拟机正在启动中 是否确定关闭 [y/n]"
  read onoff
   if [ "$onoff" == y ];then
     VBoxManage controlvm ${name} poweroff    
  else
    exit 0
  fi
 fi
 VBoxManage unregistervm ${name} --delete
 rm -rf /data/VirtualBox/${name}
}

startVM() {
 params=($1)
 num=$2
 checkFlags $params $num
 ## 1\. 检测要拷贝的虚拟机是否以及关闭
 runVM=`vboxmanage list runningvms | grep -w $name | awk '{print \$1}'`
 if [ "$runVM" == \"$name\" ];then
   echo "虚拟机已经启动了"
   exit 0
 fi
 VBoxManage startvm ${name}  --type headless
}

stopVM() {
 params=($1)
 num=$2
 checkFlags $params $num
 VBoxManage controlvm ${name} poweroff
}

restartVM() {
 params=($1)
 num=$2
 checkFlags $params $num
 VBoxManage controlvm ${name} poweroff
 VBoxManage startvm ${name}  --type headless
}

snapshotVM() {
 params=($1)
 num=$2
 checkFlags $params $num
 if [ ${#description} -eq 0 ];then
  description="${snapshotName}快照"
 fi
 VBoxManage snapshot ${name} take ${snapshotName} --description $description
}

snapshotrestoreVM() {
 params=($1)
 num=$2
 checkFlags $params $num
 ## 检测回复快照是否启动中
 runVM=`vboxmanage list runningvms | grep -w $name | awk '{print \$1}'`
 if [ "$runVM" == \"$name\" ];then
  echo "回复快照的虚拟机正在启动中 是否确定关闭 [y/n]"
  read onoff
   if [ "$onoff" == y ];then
     VBoxManage controlvm ${name} poweroff
  else
    exit 0
  fi
 fi
 VBoxManage snapshot ${name} restore ${snapshotName}
}

snapshotdeleteVM() {
 params=($1)
 num=$2
 checkFlags $params $num
 vboxmanage snapshot ${name} delete ${snapshotName}
}

snapshotlistVM() {
 params=($1)
 num=$2
 checkFlags $params $num
 vboxmanage snapshot ${name}  list 
}

option=$1
args=$@

case $option in
  create)
    checkParamsNum=$#
    if [ $(($checkParamsNum%2)) -ne 0 ];then
          createVM "$args" $checkParamsNum
    else
       echo "params error"
       exit 1
    fi
    ;;
  clone)
    checkParamsNum=$#
    if [ $(($checkParamsNum%2)) -ne 0 ];then
          cloneVM "$args" $checkParamsNum
    else
       echo "params error"
       exit 1
    fi
   ;;
  delete)
    checkParamsNum=$#
    if [ $(($checkParamsNum%2)) -ne 0 ];then
          deleteVM "$args" $checkParamsNum
    else
       echo "params error"
       exit 1
    fi
   ;;
  start)
   checkParamsNum=$#
    if [ $(($checkParamsNum%2)) -ne 0 ];then
          startVM "$args" $checkParamsNum
    else
       echo "params error"
       exit 1
    fi
   ;;
  stop)
   checkParamsNum=$#
    if [ $(($checkParamsNum%2)) -ne 0 ];then
          stopVM "$args" $checkParamsNum
    else
       echo "params error"
       exit 1
    fi
   ;;
  restart)
    checkParamsNum=$#
    if [ $(($checkParamsNum%2)) -ne 0 ];then
          restartVM "$args" $checkParamsNum
    else
       echo "params error"
       exit 1
    fi
   ;;
  snapshot)
    checkParamsNum=$#
    if [ $(($checkParamsNum%2)) -ne 0 ];then
          snapshotVM "$args" $checkParamsNum
    else
       echo "params error"
       exit 1
    fi
   ;;
   snapshotrestore)
    checkParamsNum=$#
    if [ $(($checkParamsNum%2)) -ne 0 ];then
          snapshotrestoreVM "$args" $checkParamsNum
    else
       echo "params error"
       exit 1
    fi
   ;;
   snapshotdelete)
    checkParamsNum=$#
    if [ $(($checkParamsNum%2)) -ne 0 ];then
          snapshotdeleteVM "$args" $checkParamsNum
    else
       echo "params error"
       exit 1
    fi
   ;;
   vmlist)
    vboxmanage list vms
   ;;
   runlist)
    vboxmanage list runningvms
   ;;
   snapshotlist)
    checkParamsNum=$#
    if [ $(($checkParamsNum%2)) -ne 0 ];then
          snapshotlistVM "$args" $checkParamsNum
    else
       echo "params error"
       exit 1
    fi
   ;;
  *)
   printHelp
  ;;
esac

exit 0

