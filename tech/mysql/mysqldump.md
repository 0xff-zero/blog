# 备份数据库
mysqldump -u {user} -p {db} > {sql file path}

# 恢复数据库
mysql -u {user} -p {db} < {sql file path}
source {sql file}