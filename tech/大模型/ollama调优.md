Ollama github 官方说明可以看到：


参数|描述|  zh
---|---|---
num_ctx |	Sets the size of the context window used to generate the next token. (Default: 2048)	|影响的是模型可以一次记住的最大 token 数量。
num_predict|	Maximum number of tokens to predict when generating text. (Default: 128, -1 = infinite generation, -2 = fill context)|	影响模型最大可以生成的 token 数量。

num_ctx 默认配置 2048，相当于一次只能向模型输入 2k token，超过 2k 模型就无法记住。当 prompt 特别长时往往会出现问题。并且现在开源模型往往支持长上下文，默认配置会严重限制本地模型能力。

num_predict 默认配置 128，相当于每次模型只能生成小于 128 token 回复。无法生成长回复。

# 优化配置
 以 llama3.1:8b 模型为例，说明如何修改配置。

 ## 获取模型默认 Modelfile 配置
 `ollama show llama3.1:8b --modelfile`

 将其中默认的 Modelfile 内容复制出来。

在本地创建一个 Modelfile 文件，将内容复制进去。

## 查询模型 context length

`ollama show llama3.1:8b`

llama3.1:8b 模型，context length 131072，相当于 128k token。

## 创建新 Modelfile 配置


在本地 Modelfile 最后，插入两行配置

```
PARAMETER num_ctx 131072
PARAMETER num_predict -1

```

## 创建新模型

```
# 个人将新模型命名 xxxx-max-context 能区分这是最大 token 配置模型
ollama create llama3.1:8b-max-context -f Modelfile
```
运行命令后，提示 success。


使用上述方式，可以将所有模型都使用最新配置重新生成。

后续只要使用 xxxx-max-context 结尾模型，都可以使用模型支持的最大化 token。当然通过 API 调用也同样生效。同样的，输入的 token 越多，所需要的资源也就越多，响应也相对慢一些。

还是那句话，不同使用场景，应该选择不同模型。简单场景使用小参数模型，响应快速。复杂场景使用 max-context 模型，最大化发挥模型能力。