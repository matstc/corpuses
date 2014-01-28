var redis = require("redis");

exports.index = function(req, res){

  var db = redis.createClient();
  
  db.on("error", function (err) {
    console.log("Error " + err);
  });

  var ua = req.headers['user-agent'];
  console.log(ua);
  db.set("ua", ua, redis.print);

  db.get("ua", function(err, reply){
    res.render('index', { title: 'Express', ua: reply });
  });
};
