PhpServerView = require './php-server-view'
{CompositeDisposable} = require 'atom'
{spawn, exec} = require 'child_process'
open = require 'open'
portfinder = require 'portfinder'
{MessagePanelView, PlainMessageView} = require 'atom-message-panel'


module.exports =
  server: null
  messages: null

  activate: ->
    atom.commands.add 'atom-workspace', "php-server:start", => @start()
    atom.commands.add 'atom-workspace', "php-server:stop", => @stop()

  deactivate: ->
      @stop()

  start: ->
    if !@server
      portfinder.getPort (err, port) =>
        #@log = atom.workspace.addBottomPanel(item: new PhpServerView)
        #@log.show()

        @messages = new MessagePanelView(
            title: "PHP Server: http://localhost:#{port}"
        )
        @messages.attach()
        console.log @messages.body

        projectPath = atom.project.getPath()

        @server = spawn "php", ["-S", "localhost:#{port}"], env: process.env, cwd: projectPath

        @server.once 'exit', (code) =>
          console.log 'exit'
          @server = null
          @messages.clear()
          @messages.detach()

        @server.on 'error', (err) =>
          console.log 'error', err
          @server = null
          @messages.clear()
          @messages.detach()

        @server.stdout.on 'data', (data) =>
          @messages.add(new PlainMessageView(
            message: data.asciiSlice()
          ))
          @messages.toggle() if !@messages.body.isVisible()
          @messages.body.scrollToBottom()

        @server.stderr.on 'data', (data) =>
          @messages.add(new PlainMessageView(
            message: data.asciiSlice()
          ))
          @messages.toggle() if !@messages.body.isVisible()
          @messages.body.scrollToBottom()

        open "http://localhost:#{port}"

    @messages.attach() if @messages


  stop: ->
    # Send Ctrl+C
    @server.kill('SIGINT') if @server
