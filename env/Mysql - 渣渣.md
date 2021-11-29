# Mysql - 渣渣

## 修改创建好的表的编码

```sql
ALTER TABLE tbl_name CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci
```



## 修改创建好的数据库的编码

```sql
ALTER DATABASE dbname CHARACTER SET utf8 COLLATE utf8_general_ci
```



## 开通授权远程访问

```sql
grant all privileges on *.* to 'root'@'%' identified by 'root';
flush privileges;
```

