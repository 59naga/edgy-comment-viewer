nicolive= require 'nicolive'

module.exports= (app)->
  app.directive 'nickname',->
    scope:
      nickname:'='
    link:(scope,element,attrs)->
      scope.$parent.nickname= scope.nickname
      return unless scope.nickname.match /^\d+$/

      nicolive.fetchNickname scope.nickname,(error,nickname)->
        return console.error error if error?

        scope.nickname= nickname
        scope.$parent.nickname= nickname