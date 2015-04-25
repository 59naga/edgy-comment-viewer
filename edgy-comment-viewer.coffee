app= require 'app'
crashReporter= require 'crash-reporter'
BrowserWindow= require 'browser-window'

path= require 'path'

Server= require './lib/server'

class Application
  constructor: ->
    process.env.APP= __dirname
    process.env.PUBLIC= path.join __dirname,'public'
    process.env.NODE_ENV= 'production' if process.argv.join().indexOf('electron-prebuilt') is -1

  boot: ->
    crashReporter.start();

    server= new Server process.env.PUBLIC
    server.listen 59799

    app.on 'ready',=>
      options=
        width: 320
        height: 480

      @window= new BrowserWindow options
      @window.openDevTools() if process.env.NODE_ENV isnt 'production'
      @window.loadUrl 'http://localhost:59799'

    app.on 'window-all-closed',->
      app.quit() if process.platform isnt 'darwin'

module.exports= new Application