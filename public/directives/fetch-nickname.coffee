nicolive= require 'nicolive'

module.exports= (app)->
  app.directive 'fetchNickname',->
    scope:
      fetchNickname:'='
    link:(scope,element,attrs)->
      scope.$parent.nickname= scope.fetchNickname
      return unless scope.fetchNickname.match /^\d+$/

      nicolive.fetchNickname scope.fetchNickname,(error,nickname)->
        return console.error error if error?

        scope.nickname= nickname
        scope.$parent.nickname= nickname