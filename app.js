//開啟本地伺服器所用的 nodejs 腳本，需要 npm install express 的模組。
//引用需要的nodeJs modules
var express = require('express');
var app = express();
var serv = require('http').Server(app);

//設定 http server 的回傳路徑
app.get('/',function(req,res){
    res.sendFile(__dirname +'/index.html');
});
app.use('/',express.static(__dirname+'/'));

//設定監聽的 port 為 2000
serv.listen(2000);
console.log("server is running!");