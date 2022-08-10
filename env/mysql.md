# 配置root远程登录
GRANT ALL ON *.* TO 'root'@'%';
flush privileges;
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
 FLUSH PRIVILEGES;