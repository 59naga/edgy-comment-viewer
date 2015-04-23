module.exports= (app)->
  app.directive 'errSrc',->
    (scope,element,attrs)->
      element.bind 'error',->
        attrs.$set 'src',attrs.errSrc if attrs.src isnt attrs.errSrc