# vue-cli-server中的devServer开启日志

```
 devServer: {
    host: '0.0.0.0',
    port: port,
    open: true, // 默认打开浏览器
    before: function (app, server, compiler) {
      app.use('/', function (req, res,next) {
          console.log(`from ${req.ip} - ${req.method} - ${req.originalUrl}`);
          next();
      });
    },
    proxy: {
      // detail: https://cli.vuejs.org/config/#devserver-proxy

      [process.env.VUE_APP_BASE_API]: {
        target: `http://localhost:8080`,
        changeOrigin: true,
        pathRewrite: {
          [`^${process.env.VUE_APP_BASE_API}`]: ''
          
        },
        logLevel: 'debug' 
      }
    },
    disableHostCheck: true
  }
}
```
日志示例：
```
from 127.0.0.1 - GET - /login?redirect=%2Findex
from 127.0.0.1 - GET - /static/js/chunk-vendors.js
from 127.0.0.1 - GET - /static/js/app.js
from 127.0.0.1 - GET - /static/img/login-background.f9f49138.jpg
from 127.0.0.1 - GET - /devapi/captchaImage
[HPM] Rewriting path from "/devapi/captchaImage" to "/captchaImage"
[HPM] GET /devapi/captchaImage ~> http://localhost:8080
from 127.0.0.1 - GET - /favicon.ico
from 127.0.0.1 - GET - /static/fonts/element-icons.535877f5.woff
```