PhpServerView = require './php-server-view'
PhpServerServer = require './php-server-server'
open = require 'open'

module.exports =
  config:
    phpPath:
      title: 'Path to PHP Executable'
      type: 'string'
      default: 'php'
    localhost:
      title: 'Hostname to use'
      type: 'string'
      default: 'localhost'
    startPort:
      title: 'Default port to bind to'
      description: 'Will search for an empty port starting from here'
      type: 'integer'
      default: 8000

  server: null
  view: null


  activate: ->
    atom.commands.add 'atom-workspace', "php-server:start", => @start()
    atom.commands.add 'atom-workspace', "php-server:clear", => @clear()
    atom.commands.add 'atom-workspace', "php-server:stop", => @stop()

  deactivate: ->
    @stop()


  start: ->
    freshstart = false

    if !@server
      @server = new PhpServerServer atom.project.getPath()
      freshstart = true

      @server.onError (err) =>
        console.error err

    @server.path = atom.config.get('php-server.phpPath')
    @server.host = atom.config.get('php-server.localhost')
    @server.basePort = atom.config.get('php-server.startPort')

    if !@view
      @view = new PhpServerView(
          title: "PHP Server: Launching..."
      )

      @server.onMessage (message) =>
        @view.addMessage message

      @server.onError (message) =>
        if message.code == 'ENOENT'
          @view.addError "PHP Server could not launch"
          @view.addError "Have you defined the right path to PHP in your settings? Using #{@server.path}"
        else
          @view.addError message.message

    @view.attach()

    @server.start =>
      @view.setTitle "PHP Server: <a href=\"#{@server.href}\">#{@server.href}</a>", true

      if freshstart
        @view.addMessage "Listening on #{@server.href}"
        @view.addMessage "Document root is #{@server.documentRoot}"

      open @server.href

  stop: ->
    @server?.destroy()

    @view?.clear()
    @view?.detach()

    @server = null
    @view = null

  clear: ->
    @view?.clear()
