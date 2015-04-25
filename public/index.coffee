app= angular.module 'nicolive',[
  'ui.router'
  'ngStorage'

  'ngAnimate'

  'jaggy'
  'webcolor'

  'jsfxr'
]
app.config (jsfxr)->
   jsfxr.getRandomSound.masterVolume= .4
app.config ($locationProvider)->
  $locationProvider.html5Mode true
app.config ($stateProvider)->
  $stateProvider.state 'viewer.login',
    url: '/login'
    controller: require './components/login'
    templateUrl: 'components/login'

  $stateProvider.state 'viewer.logout',
    url: '/logout'
    controller: require './components/logout'

  $stateProvider.state 'viewer',
    url: '*path'
    controller: require './components/viewer'
    templateUrl: 'components/viewer'

app.run ($rootScope,$state)->
  $rootScope.$state= $state

require('./directives/time-ago') app
require('./directives/err-src') app
require('./directives/fetch-nickname') app