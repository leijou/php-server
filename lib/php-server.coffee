PhpServerView = require './php-server-view'
{CompositeDisposable} = require 'atom'
{spawn, exec} = require 'child_process'
open = require 'open'
portfinder = require 'portfinder'

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
        @messages = new PhpServerView(
            title: "PHP Server: http://localhost:#{port}"
        )
        @messages.attach()

        projectPath = atom.project.getPath()

        @server = spawn "php", ["-S", "localhost:#{port}"], env: process.env, cwd: projectPath

        @server.once 'exit', (code) =>
          console.log 'exit', code if code != 0

        @server.on 'error', (err) =>
          console.log 'error', err

        @server.stdout.on 'data', (data) =>
          #console.log 'stdout', data.asciiSlice()

        @server.stderr.on 'data', (data) =>
          @messages.addMessage data.asciiSlice()

        open "http://localhost:#{port}"

    @messages.attach() if @messages


  stop: ->
    # Send Ctrl+C
    @server?.kill('SIGINT')
    @server = null
    @messages.clear()
    @messages.detach()
