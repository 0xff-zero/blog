# 在 kubernetes 上创建一个应用
## 使用命令行创建
### 创建deployment
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1 # 告知 Deployment 运行 1 个与该模板匹配的 Pod
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

# 参考文档
> https://kubernetes.io/zh-cn/docs/tasks/run-application/run-stateless-application-deployment/