# vue  环境搭建



vue前端框架，不过多介绍了，我为什么配置这环境，也不多说了

## Mac环境搭建

### 安装Node

> 前端框架环境都是需要NODE.js,先安装Nodejs开发环境，vue运行需要依赖node的npm的管理工具实现

#### 下载安装包

从[node.js官网](https://nodejs.org/en/)下载并安装node，

下载地址[https://nodejs.org/dist/v16.13.0/node-v16.13.0.pkg](https://nodejs.org/dist/v16.13.0/node-v16.13.0.pkg)

#### 验证安装成功

试用命令`npm -version`

```shell
$ npm -version
8.1.0
```

### 安装淘宝镜像源

> 为什么要安装淘宝镜像源？因为你不使用淘宝的镜像源，很多包，你可能下载不了

#### 安装

淘宝的`cnpm` 可以替换`npm`，我们保持试用喜欢，直接替换`npm`的源保持试用`npm`命令

试用命令：

```shell
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

执行后，等待安装

> 如果不使用管理员命令的话，会报错没权限
>
> 可以使用管理员执行，或者使用命令：
>
> ```shell
> sudo npm install -g cnpm --registry=https://registry.npm.taobao.org
> ```

**安装失败，版本不匹配**，如图：

![](https://gitee.com/lidaming/assets/raw/master/env/vue-error.png)

根据提示，使用命令：

```shell
sudo npm install -g npm@8.1.3
```

升级完成后，重新执行安装命令：

```shell
sudo npm install -g cnpm --registry=https://registry.npm.taobao.org
```

到此，安装完成！！



#### 验证

执行命令`cnpm -v`

```shell
$ cnpm -v
cnpm@7.1.0 (/usr/local/lib/node_modules/cnpm/lib/parse_argv.js)
npm@6.14.15 (/usr/local/lib/node_modules/cnpm/node_modules/npm/lib/npm.js)
node@16.13.0 (/usr/local/bin/node)
npminstall@5.2.1 (/usr/local/lib/node_modules/cnpm/node_modules/npminstall/lib/index.js)
prefix=/usr/local 
darwin x64 20.4.0 
registry=https://registry.npmmirror.com
```

### 安装Webpack

> webpack介绍

#### 安装



执行命令

```shell
sudo npm install webpack -g
sudo npm install webpack-cli -g
```



> 注意权限，需要sudo执行

#### 验证

执行命令`webpack -v`,成功，提示如下：

```shell
$ webpack -v
webpack: 5.63.0
webpack-cli: 4.9.1
webpack-dev-server not installed
```



### 安装vue-cli

#### 安装



执行命令：

```shell
sudo npm install vue-cli -g
```

#### 验证

执行命令`vue -V`，成功显示：

```shell
$ vue -V
2.9.6
```



## Win环境搭建

### 安装Node

#### 安装

官网下载地址：https://nodejs.org/en/download/ 【下载的版本为16.13】

下一步，安装完成

#### 验证

执行命令`npm -v`,成功展示：

```powershell
 User> npm -v
8.1.0
```

#### 设置缓存

> 和mac有点差异，可以自行设置

**在nodejs安装目录下创建node_global和node_cache两个文件夹**

> 我的本机安装目录是D:\nodejs

设置缓存文件夹

```powershell
npm config set cache "D:\nodejs\node_cache"
```

设置全局模块存放路径

```powershell
npm config set prefix "D:\nodejs\node_global"
```

设置成功后，使用命令`npm install XXX -g`安装的模块就在D:\nodejs\node_global里面

### 设置淘宝镜像源

执行命令：

```powershell
npm install -g cnpm --registry=https://registry.npm.taobao.org
```

> 使用管理员权限执行才可以，不然会报无权限

### 设置环境变量

> 设置环境变量可以使得住任意目录下都可以使用cnpm、vue等命令，而不需要输入全路径

鼠标右键"此电脑"，选择“属性”菜单，在弹出的“系统”对话框中左侧选择“高级系统设置”，弹出“系统属性”对话框。

1. 修改系统变量PATH,增加：`D:\nodejs\node_global`
2. 新增系统变量NODE_PATH 值为`D:\nodejs\node_modules`

### 安装vue

执行命令：

```powershell
npm install vue -g
```

### 安装 vue-cli,即vue-cli脚手架

执行命令：

```powershell
npm install vue-cli -g
```



至此win下安装完成。小伙伴可能要问，为什么mac下安装了webpack,但是win下没安装，webpack只是一个工具，不影响vue的使用，所以，win下省略，未安装。



异常：在我的PowerShell 中无法执行`vue -v` 命令，[同问题](https://www.pianshen.com/article/57882082129/)

根据文章方案，执行`set-ExecutionPolicy RemoteSigned `，可以顺利解决



参考：

https://zhuanlan.zhihu.com/p/34898485

https://www.cnblogs.com/zhaomeizi/p/8483597.html
