# 命令行参数的形式
java -jar {jar pkg name} --spring.profile.active={env}
> 也可以修改端口等配置 --server.port={port}

# 通过环境变量控制
spring.profile.active=${ENV:dev}

如果环境有ENV环境变量，就是用ENV，否则就用dev