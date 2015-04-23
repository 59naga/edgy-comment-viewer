nicolive= require 'nicolive'

module.exports= (
  $rootScope
  $scope
  $localStorage
  $webcolorLoadingBar

  $state
)->
  $rootScope.viewer= null
  $scope.$storage= $localStorage
  
  nicolive.ping (error,viewer)->
    return $state.go '.login' if error?
    
    $scope.view() if $localStorage.channel?.length

  $scope.now= -> Math.floor(Date.now()/1000)
  $scope.blank= 'http://uni.res.nimg.jp/img/user/thumb/blank.jpg'
  $scope.options=
    from: 50

  $scope.disable= ->
    $scope.error= ''
    $scope.handshaked= no
    $scope.comments= []
    $rootScope.viewer.end() if $rootScope.viewer?
    delete $rootScope.viewer

  $scope.logout= ->
    $scope.disable()
    delete $localStorage.channel

    $webcolorLoadingBar.start()
    $webcolorLoadingBar.complete()

  $scope.toggle= ->
    if $rootScope.viewer
      $localStorage.open= !$localStorage.open
    else
      $scope.view() if $localStorage.channel?

  $scope.view= ->
    $scope.disable()

    nicolive.ping (error)->
      return $state.go '.login' if error?

      $webcolorLoadingBar.start()
      nicolive.view $localStorage.channel,$scope.options,(error,viewer)->
        $webcolorLoadingBar.complete()
        if error?
          $scope.error= error
          return $scope.$apply()

        $rootScope.viewer= viewer
        $rootScope.viewer.on 'handshaked',->
          $scope.handshaked= yes
        $rootScope.viewer.on 'comment',(comment)->
          $scope.comments.unshift comment
          $scope.$apply()

  $scope.comment= ->
    return if $scope.busy
    $scope.busy= yes

    nicolive.ping (error)->
      return $state.go '.login' if error?

      $webcolorLoadingBar.start()
      nicolive.view $localStorage.channel,$scope.options,(error,viewer)->
        if error?
          $scope.error= error
          return $scope.$apply()

        viewer.on 'handshaked',->
          $webcolorLoadingBar.complete()
          viewer.comment $scope.text
          delete $scope.text

          $scope.busy= no
