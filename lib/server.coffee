Storage = require('./storage')
TwitterRawStream = require('twitter-raw-stream')

exports.run = ->
  if !process.env.DB_PATH || !process.env.TWITTER_USERNAME || !process.env.TWITTER_PASSWORD
    console.info("Usage: ")
    console.info()
    console.info("DB_PATH='[/data/twitter/]YYYY/MM/[twitter].YYYYMMDDHH[.jsons]' TWITTER_USERNAME=username TWITTER_PASSWORD=password "+process.argv[1])
    process.exit(-1)

  storage = new Storage(process.env.DB_PATH)
  storage.on 'open', (path) ->
    console.info "Opened #{path}"

  trs = new TwitterRawStream(
    process.env.TWITTER_USERNAME
    process.env.TWITTER_PASSWORD
  )

  trs.on 'data', (json, message) ->
    storage.received(json)

  trs.on 'status', (status) ->
    console.info("#{@numReceived} tweets, #{status.tps.toFixed(1)} TPS, delay: #{status.delay.toFixed(1)} s, last: #{status.last.toFixed(1)} s")

  trs.on 'stalled', ->
    console.warn 'STREAM STALLED'

  trs.on 'end', ->
    console.info 'STREAM CLOSED'

  trs.on 'error', (error) ->
    console.info "EXCEPTION CAUGHT: #{error}"

  trs.on 'reconnect', (times, wait) ->
    console.info "Reconnect in #{wait/1000} s (retry #{times})"

  trs.on 'http-error', (res) ->
    console.error "HTTP Error #{res.statusCode} returned"

  trs.on 'connect', ->
    console.info "Connection established"

  trs.start()
