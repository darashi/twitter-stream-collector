fs = require('fs')
mkdirp = require('mkdirp')
path = require('path')
moment = require('moment')
{EventEmitter} = require('events')

class Storage extends EventEmitter
  constructor: (@storagePath) ->
    unless @storagePath?
      throw 'storagePath must be set'
    @lastPath = null
    @currentStream = null

  pathForTime: (t) ->
    moment(t).utc().format(@storagePath)

  logFile: ->
    t = new Date()
    currentPath = @pathForTime(t)
    if !@lastPath || currentPath != @lastPath
      @lastPath = currentPath
      dirname = path.dirname(currentPath)
      mkdirp.sync(dirname)
      @emit 'open', currentPath
      @currentStream?.end()
      return @currentStream = fs.createWriteStream(currentPath, {flags:"a"})
    else
      return @currentStream

  received: (json) =>
    @logFile().write(json+"\r\n")

module.exports = Storage
