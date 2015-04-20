app= require 'app'
crashReporter= require 'crash-reporter'
BrowserWindow= require 'browser-window'

Server= require './lib/server'

class Application
  boot: ->
    crashReporter.start();

    server= new Server __dirname+'/public'
    server.listen 59798

    app.on 'ready',=>
      options=
        width: 320
        height: 480

      @window= new BrowserWindow options
      @window.loadUrl 'http://localhost:59798'

module.exports= new Application