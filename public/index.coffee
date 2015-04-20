nicolive= require 'nicolive'
cheerio= require 'cheerio'

app= angular.module 'nicolive',['ngAnimate','jaggy']
app.run ($rootScope)->
  $rootScope.channel= 'lv218379698'
  $rootScope.chats= []
  $rootScope.viewer= null

  $rootScope.view= ->
    $rootScope.chats= []
    $rootScope.viewer.end() if $rootScope.viewer?

    nicolive.view $rootScope.channel,(error,viewer)->
      return alert error if error?

      console.log 'Connected',$rootScope.channel

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
