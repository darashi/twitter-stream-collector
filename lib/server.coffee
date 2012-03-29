Storage = require('./storage')
TwitterRawStream = require('twitter-raw-stream')
redis = require('redis')

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

  if process.env.REDIS_CHANNEL
    channel = process.env.REDIS_CHANNEL
    host = process.env.REDIS_HOST || '127.0.0.1'
    port = process.env.REDIS_PORT || 6379
    password = process.env.REDIS_PASSWORD
    console.log "Connecting to Redis on %s:%s", host, port
    client = redis.createClient(port, host)

    if password?
      console.info "Setting Redis password"
      client.auth(password)

    client.on 'error', (error) ->
      console.warn 'Redis connection error: %s', error

    client.on 'connect', ->
      console.info 'Redis connected'

    console.info "Messages are directed to channel '%s'", channel

    trs.on 'data', (json, message) ->
      client.publish(channel, json)

  trs.start()
