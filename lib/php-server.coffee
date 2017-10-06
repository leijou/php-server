PhpServerView = require './php-server-view'
PhpServerServer = require './php-server-server'
open = require 'open'
fs = require 'fs'

module.exports =
  config:
    phpPath:
      title: 'Path to PHP Executable'
      description: 'On Windows this might need to be the full path to php.exe'
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
    phpIni:
      title: 'Custom php.ini file'
      description: 'Will replace your standard CLI php.ini settings'
      type: 'string'
      default: ''
    overrideErrorlog:
      title: 'Override error log'
      description: 'Redirect error log to panel in Atom. Overrides ini settings. May not work on Windows'
      type: 'boolean'
      default: false
    expandOnLog:
      title: 'Expand on log message'
      description: 'Expands the server console window when selected requests are received by the server'
      type: 'string'
      enum: ['all', 'none']
      default: 'all'
    openInBrowser:
      title: 'Open in browser'
      description: 'Open browser at local URL on server start'
      type: 'boolean'
      default: true


  server: null
  view: null


  activate: ->
    atom.commands.add 'atom-workspace', "php-server:start", => @start()
    atom.commands.add 'atom-workspace', "php-server:start-tree", => @startTree()
    atom.commands.add 'atom-workspace', "php-server:start-tree-route", => @startTreeRoute()
    atom.commands.add 'atom-workspace', "php-server:start-document", => @startDocument()
    atom.commands.add 'atom-workspace', "php-server:clear", => @clear()
    atom.commands.add 'atom-workspace', "php-server:stop", => @stop()


  deactivate: ->
    @stop()


  startTree: ->
    @start atom.packages.getLoadedPackage('tree-view').mainModule.treeView.selectedPath


  startTreeRoute: ->
    [path, basename] = @splitPath atom.packages.getLoadedPackage('tree-view').mainModule.treeView.selectedPath
    @start path, basename


  startDocument: ->
    @start(atom.workspace.getActiveTextEditor()?.getPath())


  splitPath: (path) ->
    basename = false
    if !fs.lstatSync(path).isDirectory()
      basename = path.split(/[\\/]/).pop()
      path = path.substring(0, Math.max(path.lastIndexOf("/"), path.lastIndexOf("\\")))

    return [path, basename]


  start: (documentroot, router) ->
    # Stop server if currently running
    if @server
      @server.stop()
      @server = null

    # Set up panel
    if !@view
      @view = new PhpServerView(
        title: "PHP Server: Launching..."
      )

    @view.attach()

    # Collapse view if expandOnLog is set to none
    if atom.config.get('php-server.expandOnLog') == 'none'
      @view?.hide()

    # Launch server in given working directory
    if !documentroot
      documentroot = atom.project.getPaths()[0]

    if !documentroot
      @view.addError "PHP Server could not launch"
      @view.addError "Atom project directory not found"
      return

    [documentroot, basename] = @splitPath documentroot

    @server = new PhpServerServer documentroot, router

    # Pass package settings
    @server.path = atom.config.get('php-server.phpPath')
    @server.host = atom.config.get('php-server.localhost')
    @server.basePort = atom.config.get('php-server.startPort')
    @server.ini = atom.config.get('php-server.phpIni')
    @server.overrideErrorlog = atom.config.get('php-server.overrideErrorlog')

    # Listen
    @server.on 'message', (message) =>
      @view?.addMessage message, atom.config.get('php-server.expandOnLog')

    @server.on 'error', (err) =>
      console.error err

      if @view
        if err.code == 'ENOENT'
          @view.addError "PHP Server could not launch"
          @view.addError "Have you defined the right path to PHP in your settings? Using #{@server.path}"
        else if err.code == 'ENOTDIR'
          @view.addError "PHP Server could not launch"
          @view.addError "Not a directory? Using #{@server.documentRoot}"
        else
          @view.addError err.message

    # Start server
    @server.start =>
      @view.setTitle "PHP Server: <a href=\"#{@server.href}\">#{@server.href}</a>", true

      @view.addMessage "Listening on #{@server.href}", atom.config.get('php-server.expandOnLog')
      @view.addMessage "Document root is #{@server.documentRoot}", atom.config.get('php-server.expandOnLog')

      href = @server.href
      if basename
        href += '/' + basename

      # Launch browser
      if atom.config.get('php-server.openInBrowser')
        open href


  stop: ->
    @server?.stop()

    @view?.clear()
    @view?.close()

    @server = null
    @view = null


  clear: ->
    @view?.clear()
