# vue 在Mac 环境搭建

vue前端框架，不过多介绍了，我为什么配置这环境，也不多说了

## 安装Node

> 前端框架环境都是需要NODE.js,先安装Nodejs开发环境，vue运行需要依赖node的npm的管理工具实现

### 下载安装包

从[node.js官网](https://nodejs.org/en/)下载并安装node，

下载地址[https://nodejs.org/dist/v16.13.0/node-v16.13.0.pkg](https://nodejs.org/dist/v16.13.0/node-v16.13.0.pkg)

### 验证安装成功

试用命令`npm -version`

```shell
$ npm -version
8.1.0
```

## 安装淘宝镜像源

> 为什么要安装淘宝镜像源？因为你不使用淘宝的镜像源，很多包，你可能下载不了

### 安装

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



### 验证

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

## 安装Webpack

> webpack介绍

### 安装



执行命令

```shell
sudo npm install webpack -g
sudo npm install webpack-cli -g
```



> 注意权限，需要sudo执行

### 验证

执行命令`webpack -v`,成功，提示如下：

```shell
$ webpack -v
webpack: 5.63.0
webpack-cli: 4.9.1
webpack-dev-server not installed
```



## 安装vue-cli

### 安装



执行命令：

```shell
sudo npm install vue-cli -g
```

### 验证

执行命令`vue -V`，成功显示：

```shell
$ vue -V
2.9.6
```



参考：

https://zhuanlan.zhihu.com/p/34898485

