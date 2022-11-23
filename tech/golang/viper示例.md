# viper 示例
> 官方文档：https://github.com/spf13/viper
>https://www.cnblogs.com/rickiyang/p/11074161.html

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

## 读取配置文件
Viper 可以通过少量的配置，就可以读取响应的配置文件。Viper支持JSON, TOML, YAML, HCL, INI, envfile and Java Properties files。Viper可以对多个路径进行配置文件搜索，但是在单个Viper实例中只支持一个配置文件生效。Viper不指定任何默认配置路径，让应用决定默认的路径。

下面进行配置文件读取的简单示例。演示如何搜索并读取配置文件，不强制要求指定配置文件路径，至少要指定一个配置文件的搜索路径。
```
viper.SetConfigName("config") // name of config file (without extension)
viper.SetConfigType("yaml") // REQUIRED if the config file does not have the extension in the name
viper.AddConfigPath("/etc/appname/")   // path to look for the config file in
viper.AddConfigPath("$HOME/.appname")  // call multiple times to add many search paths
viper.AddConfigPath(".")               // optionally look for config in the working directory
err := viper.ReadInConfig() // Find and read the config file
if err != nil { // Handle errors reading the config file
	panic(fmt.Errorf("fatal error config file: %w", err))
}
```
如果配置文件不存在可以增加额外的处理逻辑，如下代码：
```
if err := viper.ReadInConfig(); err != nil {
	if _, ok := err.(viper.ConfigFileNotFoundError); ok {
		// Config file not found; ignore error if desired
	} else {
		// Config file was found but another error was produced
	}
}

// Config file found and successfully parsed
```

## 读取环境变量
Viper完全支持读取环境变量。此功能属于12种应用之外的类型。提供了以下五种方法支持读取环境：
- AutomaticEnv()
- BindEnv(string...) : error
- SetEnvPrefix(string)
- SetEnvKeyReplacer(string...) *strings.Replacer
- AllowEmptyEnv(bool)

-*-Viper在读取环境变量的时候，是大小写敏感的。-*-

Viper 提供了一种机制保证读取的环境变量是唯一的。使用方法`SetEnvPrefix`可以读取指定前缀的环境变量。此时`BindEnv`和`AutomaticEnv`在使用时，前缀也会生效。