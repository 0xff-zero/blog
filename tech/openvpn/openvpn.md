
# 客户端配置

## 1. 生成客户端证书并签约
在openvpn的服务器端，使用easy-rsa 生成证书
`./easy-rsa gen-req {user} nopass`
生成不带密码的客户端证书；

使用`./easy-rsa sign-req client {user} ` 对生成的用户进行签约

## 2.配置客户端
编辑client.ovpn文件
```

client 
dev tun
proto tcp
remote 39.165.247.211 11194 # 远程服务器
resolv-retry infinite
nobind
persist-key
persist-tun
ca /Users/daming.li/client/ca.crt # 改成ca证书地址
cert /Users/daming.li/client/ldm.crt # 改成客户证书
key /Users/daming.li/client/ldm.key # 改成客户key
remote-cert-tls server
tls-auth /Users/daming.li/client/ta.key 1 #改成ca的key
cipher AES-256-CBC
verb 3
```