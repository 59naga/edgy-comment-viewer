nicolive= require 'nicolive'
cheerio= require 'cheerio'
moment= require 'moment'
moment.locale 'ja'

app= angular.module 'nicolive',[
  'ngStorage'

  'ngAnimate'

  'jaggy'
  'webcolor'

  'jsfxr'
]

app.directive 'timeAgo',($timeout)->
  restrict:'A'
  scope:
    timeAgo:'='
  link:(scope,element)->
    update= -> element.text moment(scope.timeAgo*1000).fromNow()

    update()
    $timeout ->
      update()
    ,1000

app.run (
  $rootScope
  $localStorage
  $webcolorLoadingBar
)->
  $rootScope.$storage= $localStorage
  $rootScope.chats= []
  $rootScope.viewer= null

  $rootScope.now= -> Math.floor(Date.now()/1000)

  $rootScope.view= ->
    $rootScope.error= ''
    $rootScope.chats= []
    $rootScope.viewer.end() if $rootScope.viewer?

    channel= $localStorage.channel or ''
    mached= channel.match(/lv\d+/)
    $localStorage.channel= mached?[0] or ''

    $webcolorLoadingBar.start()
    nicolive.view $localStorage.channel,(error,viewer)->
      $webcolorLoadingBar.complete()
      if error?
        $rootScope.error= cheerio(error).find('code').text()
        return $rootScope.$apply()

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