# set nx
https://blog.csdn.net/datszhang/article/details/51744462

```
public boolean setNx(String key, String value, long expires, TimeUnit timeUnit) {
        boolean flag = false;
        try {
            flag = (boolean) redisTemplate.execute((RedisCallback<Boolean>) connection -> connection.set(key.getBytes(), value.getBytes(), Expiration.from(expires, timeUnit), RedisStringCommands.SetOption.ifAbsent()));
        } catch (Exception e) {
            log.error("设置缓存异常, key = {}", key, e);
        }
        return flag;
    }
```
也可以这样实现
```
public boolean setNx(String key) {
        return (Boolean) redisTemplate.execute((RedisCallback) connection -> {
            long expireAt = System.currentTimeMillis() + LOCKTIME + 1;
            Boolean acquire = connection.setNX(key.getBytes(), String.valueOf(expireAt).getBytes());
            if (acquire) {
                //设置成功标识没有锁
                return true;
            } else {
                //已加锁
                byte[] value = connection.get(key.getBytes());
                if (Objects.nonNull(value) && value.length > 0) {
                    long expireTime = Long.parseLong(new String(value));
                    if (expireTime < System.currentTimeMillis()) {
                        // 加锁时间过期
                        byte[] oldValue = connection.getSet(key.getBytes(), String.valueOf(System.currentTimeMillis() + LOCKTIME + 1).getBytes());
                        // 防止死锁
                        return Long.parseLong(new String(oldValue)) < System.currentTimeMillis();
                    }
                }
            }
            return false;
        });
    }
```