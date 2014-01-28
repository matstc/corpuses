var redis = require("redis");

exports.index = function(req, res){
  res.render('index', { title: 'Corpuses'});
};

exports.create = function(req, res){
  var text = req.body.text;
  var title = req.body.title;

  var words = text.split(/[ ]|\?|\!|\.|\r|\n/).filter(function(item){return item != '';});
  var counts = {};
  for(i in words){counts[words[i]] = counts[words[i]] ? counts[words[i]] + 1 : 1;}

  var tuples = Object.keys(counts).map(function(key){ return [key, counts[key]]; });
  tuples = tuples.filter(function(tuple){return tuple[1] > 1;}).sort(function(one, other){return one[1] > other[1];}).reverse();

  var db = redis.createClient();
  db.on("error", function (err) {
    console.log("Error " + err);
  });

  var id = Math.floor(Math.random(1) * 10000000);

  db.set(id, JSON.stringify({id: id, title: title, tuples: tuples}), redis.print);

  res.render('json', {content: JSON.stringify({id: id, corpus: tuples})});
};

exports.show = function(req, res){
  var id = req.param("id");

  var db = redis.createClient();

  db.on("error", function (err) {
    console.log("Error " + err);
  });
   
  db.get(id, function(err, reply){
    res.render('json', {content: JSON.parse(reply), err: err});
  });

};
