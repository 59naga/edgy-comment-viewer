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
  
  nicolive.ping (error)->
    return $state.go '.login' if error?
    
    $scope.view() if $localStorage.channel?.length

  $scope.now= -> Math.floor(Date.now()/1000)
  $scope.blank= 'http://uni.res.nimg.jp/img/user/thumb/blank.jpg'
  $scope.options=
    from: 50
    verbose: yes

  $scope.disable= ->
    $scope.error= ''
    $scope.handshaked= no
    $scope.comments= []
    viewer.end() if viewer?
    viewer= null

  $scope.logout= ->
    $scope.disable()
    delete $localStorage.channel

    $webcolorLoadingBar.start()
    $webcolorLoadingBar.complete()

  $scope.toggle= ->
    if viewer
      $localStorage.open= !$localStorage.open
    else
      $scope.view() if $localStorage.channel?

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
        viewer.on 'handshaked',(attr)->
          $scope.handshaked= yes
          $scope.attr= attr
        viewer.on 'comment',(comment)->
          $scope.comments.unshift comment
          $scope.$apply()

  $scope.comment= ->
    return unless $scope.handshaked

    nicolive.comment $scope.text,$scope.attr
    delete $scope.text