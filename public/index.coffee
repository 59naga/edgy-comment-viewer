nicolive= require 'nicolive'
cheerio= require 'cheerio'

Jsfxr= require '../lib/jsfxr'
jsfxr= new Jsfxr

app= angular.module 'nicolive',[
  'ngAnimate'
  'ngStorage'
  'jaggy'
]

app.run (
  $rootScope
  $localStorage
)->
  $rootScope.$storage= $localStorage
  $rootScope.chats= []
  $rootScope.viewer= null

  $rootScope.view= ->
    $rootScope.chats= []
    $rootScope.viewer.end() if $rootScope.viewer?

    $localStorage.channel= $localStorage.channel.match(/lv\d+/)[0]
    nicolive.view $localStorage.channel,{from:1},(error,viewer)->
      return alert error if error?

      chunks= ''
      $rootScope.viewer= viewer
      $rootScope.viewer.on 'data',(buffer)->
        chunk= buffer.toString()
        chunks+= chunk
        return unless chunk.match /\u0000$/

        data= cheerio '<data>'+chunks+'</data>'
        chunks= ''

        resultcode= data.find('thread').attr 'resultcode'
        return alert 'Resultcode is '+resultcode if resultcode>0

        for item in data.find('chat')
          element= cheerio item
          $rootScope.$apply ->
            chat=
              attr: element.attr()
              body: element.text()

            $rootScope.chats.unshift chat

  $rootScope.view() if $localStorage.channel.length

app.directive 'popopo',->
  restrict: 'A'
  scope:
    popopo:'='
  link: (scope,element)->
    text= scope.popopo

    jsfxr.regenerate
      waveType:
        0
      sustainTime:
        0.05+0.05*Math.random()
      decayTime:
        0.10+0.10*Math.random()
      startFrequency:
        0.10+0.40*Math.random()
      slide:
        0.10+0.10*Math.random()
      lpFilterCutoff:
        1
      masterVolume:
        0.5

    i= 0
    setTimeout -> popopo()
    popopo= ->
      return if text.length<i
      element.text text.slice 0,i++
      jsfxr.play()

      setTimeout popopo,1000/20