# Nomad 基本使用



## 回收不用job

`curl -X PUT http://localhost:4646/v1/system/gc`

## 启动job

`nomad job run example.nomad`

## 查看job日志

`nomad alloc logs {id} {jobname}`

