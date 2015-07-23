{$, View} = require 'atom-space-pen-views'
{MessagePanelView, PlainMessageView, LineMessageView} = require 'atom-message-panel'

module.exports =
  class PhpServerView extends MessagePanelView
    addMessage: (lines) ->
      for text in lines.split "\n"
        linematch = /in ([a-z\\\/\.\-_]+) on line ([0-9]+)$/i
        match = text.match linematch
        if match
          @add(new LineMessageView(
            line: match[2]
            file: match[1]
            message: text.substr(0, text.length - match[0].length)
          ))
        else
          @add(new PlainMessageView(
            message: text
          ))
        @toggle() if !@body.isVisible()
        @body.scrollToBottom()

    addError: (lines) ->
      @add(new PlainMessageView(
        message: lines
        className: 'text-error'
      ))
