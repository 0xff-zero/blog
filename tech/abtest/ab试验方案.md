https://mp.weixin.qq.com/s/iULbBUvrOgiha5u3PsL4lQ

算法：murmurhash

## 开源实现
### 添加依赖
```
 <dependency>
    <groupId>com.google.guava</groupId>
    <artifactId>guava</artifactId>
    <version>31.1-jre</version>
</dependency>
```

### 测试示例

```

import com.google.common.hash.HashCode;
import com.google.common.hash.HashFunction;
import com.google.common.hash.Hashing;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * @auther zero
 * @date 2023/7/7
 **/
public class Muu {
    public static void main(String[] args) {
        HashFunction hashFunction = Hashing.murmur3_32_fixed();
        HashMap<Integer,Integer> map=new HashMap<>();
        int groupCount=7;

        for (int i = 0; i < 2000; i++) {
            HashCode hashCode = hashFunction.hashString(i+"", StandardCharsets.UTF_8);
            int key = Math.abs( hashCode.asInt()) % groupCount;
            if(map.containsKey(key)){
                map.put(key,map.get(key)+1);
            }else{
                map.put(key,1);
            }
        }

        for (Map.Entry entry : map.entrySet()) {
            System.out.println(entry.getKey()+":"+entry.getValue());
        }

    }
}
```