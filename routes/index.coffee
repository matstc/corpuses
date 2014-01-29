_ = require "underscore"

getDb = ->
  if process.env.REDISTOGO_URL
    rtg = require("url").parse(process.env.REDISTOGO_URL)
    db = require("redis").createClient(rtg.port, rtg.hostname)
    db.auth(rtg.auth.split(":")[1])
  else
    db = require("redis").createClient()
  db.on "error", console.log
  db

exports.index = (req, res) ->
  res.render('index', { title: 'Corpuses'})

exports.list = (req, res) ->
  db = getDb()
   
  db.hkeys 'corp', (err, reply) ->
    multi = db.multi()

    for id in _.shuffle(reply)[0..5]
      multi.hget 'corp', id, () ->

    multi.exec (err, reply) ->
      res.render('json', {content: reply.map (record) -> JSON.parse record, err: err})

exports.create = (req, res) ->
  text = req.body.text
  title = req.body.title

  words = text.split(/[ ]|\?|\!|\.|\r|\n/).filter (item) -> item != ''

  counts = {}

  for w in words
    counts[w] = if counts[w]? then counts[w] + 1 else 1

  tuples = Object.keys(counts).map (key) -> [key, counts[key]]

  tuples = tuples.filter((tuple) -> tuple[1] > 1).sort((one, other) -> one[1] - other[1]).reverse()

  db = getDb()

  id = Math.floor(Math.random(1) * 10000000)

  db.hset("corp", id, JSON.stringify({id: id, title: title, rankings: tuples, text: text}), redis.print)

  res.render('json', {content: {id: id}})

exports.show = (req, res) ->
  id = req.param("id")

  db = getDb()
   
  db.hget "corp", id, (err, reply) ->
    res.render('json', {content: JSON.parse(reply), err: err})
