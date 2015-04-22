gulp= require 'gulp'
atom= require 'gulp-atom'
Promise= require 'bluebird'
spawn= (require 'child_process').spawn

version= 'v0.24.0'
platforms= ['win32-ia32','darwin-x64']
releases= '../releases'

gulp.task 'default',->
  return if process.env.TRAVIS_TAG is ''
  gulp.start 'zip'

gulp.task 'zip',['build'],->
  promises= []
  for platform in platforms
    promises.push new Promise (resolve,reject)->
      from= "#{releases}/#{version}/#{platform}"
      to= "#{releases}/#{version}/#{platform}"
      script= "zip -r #{to} #{from}"
      [bin,args...]= script.split ' '
      
      child= spawn bin,args,stdio:'ignore'
      child.on 'error',(error)-> reject error
      child.on 'close',-> resolve()

  Promise.all promises

gulp.task 'build',->
  atom
    srcPath: './'
    releasePath: releases
    cachePath: '../cache'
    version: version
    rebuild: false
    platforms: platforms
