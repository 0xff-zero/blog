# Gradle和Maven共用本地仓库
Gradle 和 Maven 同为构建管理工具，对依赖的管理都需要从本地加载或远端仓库进行下载。都存咋从本地加载的行为，尽量复用是最优选择。

## maven配置
Maven会读取settings.xml配置文件，加载本地仓库路径，用于存放下载的依赖，或加载依赖的来源，在配置文件中的配置项如下：
```xml
 <localRepository>${HOME}/.m2/repository</localRepository>
```



## Gradle 配置
Gradle 是通过环境变量来解析本地仓库的。

`GRADLE_USER_HOME` 可以直接配置本地仓库，如果不配置会使用，`%USER_HOME%/caches/modules-2/files-2.1`作为本地仓库路径。

在使用Gradle的时候，可以设置环境变量如下
```bash
export GRADLE_UER_HOME=${HOME}/.m2/repository
```

保持和maven的本地仓库路径一致

