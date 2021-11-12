# Git- 渣渣

## 创建分支

`git branch {branchname}`

## 分支推送到远端

```shell 
$  git push origin feature-branch:feature-branch    //推送本地的feature-branch(冒号前面的)分支到远程origin的feature-branch(冒号后面的)分支(没有会自动创建)
```

## ignore 文件重新生效

```shell
git rm -r --cached . # 移除当前git缓存
git add .
git commit . -m'update .gitignore'
git push
```

