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
  scope:
    timeAgo:'='
  link:(scope,element)->
    update= -> element.text moment(scope.timeAgo*1000).fromNow()

    update()
    $timeout ->
      update()
    ,1000
app.directive 'errSrc',->
  (scope,element,attrs)->
    element.bind 'error',->
      attrs.$set 'src',attrs.errSrc if attrs.src isnt attrs.errSrc
app.directive 'nickname',->
  scope:
    nickname:'='
  link:(scope,element,attrs)->
    scope.$parent.nickname= scope.nickname
    return unless scope.nickname.match /^\d+$/

    nicolive.getNickname scope.nickname,(error,nickname)->
      return console.error error if error?

      scope.nickname= nickname
      scope.$parent.nickname= nickname

app.run (
  $rootScope
  $localStorage
  $webcolorLoadingBar
)->
  $rootScope.$storage= $localStorage
  $rootScope.chats= []
  $rootScope.viewer= null

  $rootScope.now= -> Math.floor(Date.now()/1000)
  $rootScope.blank= 'http://uni.res.nimg.jp/img/user/thumb/blank.jpg'
  profilePrefix= 'http://www.nicovideo.jp/user/'
  usericonPrefix= 'http://usericon.nimg.jp/usericon/'

  $rootScope.view= ->
    $rootScope.error= ''
    $rootScope.chats= []
    $rootScope.viewer.end() if $rootScope.viewer?

    channel= $localStorage.channel or ''
    mached= channel.match(/lv\d+/)
    $localStorage.channel= mached?[0] or ''

    options= from:50

    $webcolorLoadingBar.start()
    nicolive.view $localStorage.channel,options,(error,viewer)->
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
              usericon: $rootScope.blank

            unless chat.attr.anonymity?
              {user_id}= chat.attr
              chat.usericon= usericonPrefix+user_id.slice(0,2)+'/'+user_id+'.jpg' if user_id

            $rootScope.chats.unshift chat

  $rootScope.view() if $localStorage.channel?.length