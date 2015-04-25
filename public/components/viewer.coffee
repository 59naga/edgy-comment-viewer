nicolive= require 'nicolive'
viewer= null

module.exports= (
  $rootScope
  $scope
  $localStorage
  $webcolorLoadingBar

  $state
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
    verbose: yes

  $scope.view= ->
    $scope.disable()

    nicolive.ping (error)->
      return $state.go '.login' if error?

      $webcolorLoadingBar.start()
      nicolive.view $localStorage.channel,$scope.options,(error,socket)->
        $webcolorLoadingBar.complete()
        if error?
          $scope.error= error
          return $scope.$apply()

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

          $scope.comments.unshift comment
          $scope.$apply()

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

  $scope.toggle= ->
    if viewer
      $localStorage.open= !$localStorage.open
    else
      $scope.view() if $localStorage.channel?
