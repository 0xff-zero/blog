# Makefile-Go项目高效构建

Go项目的构建工具





## 问题

### missing separator.  Stop.

> 参考：https://blog.csdn.net/limanjihe/article/details/52231243

第一：makefile的命令行，开头必须用tab键，目前没有发现tabstop的设定值的不同，会引起error。例如:

                        set tabstop=3(默认）  OR   set tabstop=4等，均可以。

第二：编码方式引起的原因。这个原因不多见，不容易发现。查看/etc/vimrc文件以及~/.vimrc，查看是否有set fileencodings的选项，是否设定了utf-8。没有的话加上。


