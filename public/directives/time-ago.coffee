moment= require 'moment'
moment.locale 'ja'

module.exports= (app)->
  app.directive 'timeAgo',($timeout)->
    scope:
      timeAgo:'='
    link:(scope,element)->
      update= -> element.text moment(scope.timeAgo*1000).fromNow()

      update()
      $timeout ->
        update()
      ,1000