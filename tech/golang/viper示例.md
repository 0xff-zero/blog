# viper 示例
> 官方文档：https://github.com/spf13/viper

官方的介绍如下：
>Viper is a complete configuration solution for Go applications including 12-Factor apps. It is designed to work within an application, and can handle all types of configuration needs and formats. It supports:
> - setting defaults
> - reading from JSON, TOML, YAML, HCL, envfile and Java -  properties config files
> - live watching and re-reading of config files (optional)
> - reading from environment variables
> - reading from remote config systems (etcd or Consul), and - watching changes
> - reading from command line flags
> - reading from buffer
> - setting explicit values

>Viper can be thought of as a registry for all of your applications configuration needs.

Viper 可以为Go的12中类型的应用提供完整的配置解决方案。嵌入应用进行配置处理，支持所有配置文件类型。支持配置类型列表如下：
- 默认值
- 从JSON,TOML,YAML,HCL,envfile 和Java-properties配置文件中读取配置内容
- 保持监听和重新加载配置文件的变化
- 读取环境变量
- 从端配置系统（etcd 或 Consul）读取配置，并监听变化
- 从命令行读取参数
- 从缓存读取
- 显示指定值
Viper 可以作为你的所有应用的需要的配置的一个注册中心。