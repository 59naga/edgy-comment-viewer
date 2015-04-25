nicolive= require 'nicolive'
viewer= null

module.exports= (
  $rootScope
  $scope
  $localStorage
  $webcolorLoadingBar
  $window

  $state

  jsfxr
  Jsfxr
)->
  $scope.$storage= $localStorage
  $scope.$storage.anonymity?= true
  
  nicolive.ping (error)->
    return $state.go '.login' if error?
    
    $scope.view() if $localStorage.channel?.length

  $scope.now= -> Math.floor(Date.now()/1000)
  $scope.blank= 'http://uni.res.nimg.jp/img/user/thumb/blank.jpg'
  $scope.options=
    from: 50
    verbose: yes if process.env.NODE_ENV isnt 'production'

  $scope.$watch '$storage.anonymity',->
    $scope.placeholder= 'ユーザー名でコメントします'
    $scope.placeholder= '184でコメントします' if $scope.$storage.anonymity

  $scope.view= ->
    channel= $localStorage.channel
    channel= channel.match(/lv\d+/)[0] if channel.match(/lv\d+/)
    channel= channel.match(/co\d+/)[0] if channel.match(/co\d+/)
    channel= channel.match(/watch\/([\w\/]+)/)[1] if channel.match(/watch\/([\w\/]+)/)
    $localStorage.channel= channel

    $scope.disable()

    nicolive.ping (error)->
      return $state.go '.login' if error?

      $webcolorLoadingBar.start()
      nicolive.view channel,$scope.options,(error,socket)->
        $webcolorLoadingBar.complete()
        if error?
          errorSound.play()
          $scope.error= error
          return $scope.$apply()

        usericonURL= (require 'nicolive/lib/api').url.usericonURL
        user_id= nicolive.playerStatus.user_id
        $scope.usericon= usericonURL+user_id.slice(0,2)+'/'+user_id+'.jpg'

        viewer= socket
        viewer.on 'error',(error)->
          $scope.error+= error

        viewer.on 'handshaked',(attr)->
          $scope.handshaked= yes
          $scope.attr= attr
        viewer.on 'comment',(comment)->
          comment.type= switch
            when comment.attr.premium is '2'
              'command'

            when comment.attr.premium is '3'
              'owner'

            when comment.attr.anonymity isnt '1' and $scope.attr.user_id is comment.attr.user_id
              'myself'

            else
              'anonymous'

          $scope.comments.push comment
          $scope.$apply()
          $window.scrollBy 0,$window.document.body.clientHeight

  $scope.comment= ->
    return unless $scope.handshaked

    $scope.attr.mail= ''
    $scope.attr.mail= '184' if $scope.$storage.anonymity
    nicolive.comment $scope.text,{}
    delete $scope.text

  $scope.disable= ->
    $scope.error= ''
    $scope.handshaked= no
    $scope.comments= []
    
    viewer.destroy() if viewer?
    viewer= null

  $scope.logout= ->
    return $scope.disable() if viewer?
    $state.go 'viewer.logout'

  errorSound= new Jsfxr
    sustainTime:
      0.2
    decayTime:
      0.8

    startFrequency:
      0.25
    minFrequency:
      0.0035

    slide:
      -0.3
    deltaSlide:
      0.2

    vibratoDepth:
      1
    vibratoSpeed:
      2

    repeatSpeed:
      0.3
    lpFilterCutoff:
      1
    masterVolume:
      jsfxr.getRandomSound.masterVolume
