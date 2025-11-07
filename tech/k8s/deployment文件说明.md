# Deployment 文件说明


## Service 服务
在集群上启动容器后，需要外部访问；可以通过NodePort服务的方式来对外暴露；

```yml
apiVersion: v1
kind: Service
metadata:
  name: ${appName}
  labels:
    app: ${appName}
spec:
  type: NodePort
  ports:
    - name: http-${appName}
      port: ${servicePort} # 服务对外暴露的端口
      targetPort: ${containerPort} # 目标容器端口
      nodePort: ${nodePort} # 暴露的物理端口，会占用每个物理节点的端口
  selector:
    app: ${appName}
```

集群内暴露如下：
```yml
apiVersion: v1
kind: Service
metadata:
  name: ${appName}
  labels:
    app: ${appName}
spec:
  type: ClusterIP
  ports:
    - name: http-${appName}
      port: ${servicePort} # 服务对外暴露的端口
      targetPort: ${containerPort} # 目标容器端口
  selector:
    app: ${appName}

```