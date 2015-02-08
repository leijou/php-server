{Emitter} = require 'atom'
{spawn} = require 'child_process'
portfinder = require 'portfinder'

module.exports =
  class PhpServerServer
    # Settings
    path: 'php'
    host: 'localhost'
    basePort: 8000

    # Properties
    documentRoot: null
    port: null
    href: null

    # Protected
    server: null
    disposables: null

    constructor: (@documentRoot, @port) ->
      @emitter = new Emitter

    destroy: ->
      @stop()


    onMessage: (callback) ->
      @emitter.on 'message', callback

    onError: (callback) ->
      @emitter.on 'error', callback


    start: (callback) ->
      @stop()

      if @port
        @innerStart()
        callback?()
      else
        portfinder.getPort (err, port) =>
          @port = port
          @innerStart()
          callback?()

    stop: (callback) ->
      @innerStop() if @server
      callback?()


    innerStart: ->
      @server = spawn @path, ["-S", "#{@host}:#{@port}"], env: process.env, cwd: @documentRoot

      @server.once 'exit', (code) =>
        @emitter.emit 'error', code if code != 0

      @server.on 'error', (err) =>
        @emitter.emit 'error', err

      @server.stderr.on 'data', (data) =>
        @emitter.emit 'message', data.asciiSlice()

      @href = "http://#{@host}:#{@port}"

    innerStop: ->
      # Send Ctrl+C
      @server.kill('SIGINT')
      @server = null

      @href = null
