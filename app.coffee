express = require('express')
routes = require('./routes')
http = require('http')
path = require('path')
sass = require('node-sass')
redis = require('redis')
app = express()

app.set('port', process.env.PORT || 3000)
app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'ejs')
app.use(express.favicon())
app.use(express.logger('dev'))
app.use(express.json())
app.use(express.urlencoded())
app.use(express.methodOverride())
app.use(express.cookieParser('cf1413cd1bc74e0e59916ae1c294fa3510c67b10ee94fc878d24a108cc4634abad986aaf5fad1329b139d11fd4458651214b7245c4b8814bc764f9a3d27a28b0'))
app.use(express.session())
app.use(app.router)
app.use(express.static(path.join(__dirname, 'public')))
app.use(sass.middleware({
  src: __dirname + '/public',
  dest: __dirname + '/public',
  debug: true
}))

app.use(express.errorHandler()) if 'development' == app.get('env')

app.get('/', routes.index)
app.post('/corpus', routes.create)
app.get('/corpus', routes.list)
app.get('/corpus/:id', routes.show)

http.createServer(app).listen(app.get('port'), ->
  console.log('Express server listening on port ' + app.get('port')))
