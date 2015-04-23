nicolive= require 'nicolive'

module.exports= ($scope,$state)->
  $scope.login= ->
    nicolive.login $scope.id,$scope.pw,(error,cookie)->
      return alert error if error?

      $state.go '^',null,reload:yes