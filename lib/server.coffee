# Dependencies
express= require 'express'
fs= require 'fs'
path= require 'path'

stylus= require 'stylus'
koutoSwiss= require 'kouto-swiss'

lookup= (req,basedir)->
  fileName= req.url.slice(1) or 'index'
  fileName= path.join fileName,'index' if fileName.slice(-1) is '/'
  fileName+= '.jade' if fileName.indexOf('.jade') is -1

  filePath= fileName
  filePath= path.join basedir,filePath
  filePath

# Specs
# * static for basedir
# * static render for basedir
class Server
  constructor: (basedir)->
    server= express()
    server.set 'view engine','jade'
    server.set 'views',basedir
    server.locals.basedir= basedir
    server.locals.pretty= process.env.NODE_ENV isnt 'production'

    server.use (req,res,next)=>
      filePath= lookup req,basedir

      found= fs.existsSync filePath
      viaUIRouter= req.accepts().join() is 'text/html'
      return next() unless found
      return next() unless viaUIRouter

      res.render filePath
    server.use express.static basedir
    server.get '/index.css',(req,res)->
      css= ''

      stylus fs.readFileSync(basedir+'/index.styl').toString()
      .set 'paths',[basedir]
      .set 'compress',process.env.NODE_ENV is 'production'
      .use koutoSwiss()
      .render (error,rendered)->
        throw error if error?

        css= rendered

      res.end css
    server.use (req,res)->
      filePath= lookup req,basedir
      res.status 404 if not fs.existsSync filePath
      res.render 'index'

    return server

module.exports= Server