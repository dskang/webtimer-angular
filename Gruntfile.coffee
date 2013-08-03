module.exports = (grunt) ->
  # load all grunt tasks
  require("matchdep").filterDev("grunt-*").forEach grunt.loadNpmTasks

  appConfig =
    app: "app"
    dist: "dist"

  grunt.initConfig
    webtimer: appConfig

    watch:
      coffee:
        files: ["<%= webtimer.app %>/{,*/}*.coffee"]
        tasks: ["coffee:dist"]
      copy:
        files: ["<%= webtimer.app %>/manifest.json"]
        tasks: ["copy:dist"]

    clean:
      dist:
        files: [
          dot: true
          src: [
            "<%= webtimer.dist %>/*"
            "!<%= webtimer.dist %>/.git*"
          ]
        ]

    coffee:
      dist:
        files: [
          expand: true
          cwd: "<%= webtimer.app %>"
          src: "{,*/}*.coffee"
          dest: "<%= webtimer.dist %>"
          ext: ".js"
        ]

    copy:
      dist:
        files: [
          expand: true
          cwd: "<%= webtimer.app %>"
          dest: "<%= webtimer.dist %>"
          src: [
            "manifest.json"
            "bower_components/**/*"
            "images/*"
          ]
        ]

  grunt.registerTask "default", [
    "clean:dist"
    "coffee:dist"
    "copy:dist"
  ]
