module.exports= (grunt)->
  grunt.initConfig
    'build-electron-app':
      options:
        app_dir: __dirname
        cache_dir: '../electron-cache'
        build_dir: '../electron-build'
        platforms: [
          'darwin'
          'win32'
        ]
  grunt.loadNpmTasks 'grunt-electron-app-builder'

  grunt.registerTask 'default', ['build-electron-app']
