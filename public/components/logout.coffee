nicolive= require 'nicolive'

module.exports= ($scope,$state)->
  nicolive.logout ->
    $state.go 'viewer.login',null,reload:yes