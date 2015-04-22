gulp= require 'gulp'
atom= require 'gulp-atom'
Promise= require 'bluebird'
exec= (require 'child_process').exec

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
      script= "cd #{releases}/#{version} && zip -r #{platform} #{platform}"
      # [bin,args...]= script.split ' '
      
      exec script,{maxBuffer:10000*1024},(error,stdout,stderr)->
        reject error if error?
        resolve() unless error?

  Promise.all promises

gulp.task 'build',->
  atom
    srcPath: './'
    releasePath: releases
    cachePath: '../cache'
    version: version
    rebuild: false
    platforms: platforms
