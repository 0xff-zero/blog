# myqsldump
## 备份一个数据库
mysqldump -u root -p db1 > /tmp/bak.sql

## 备份多个数据库
mysqldump -u root -p --database db1 db2 > bak.sql