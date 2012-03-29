# A twitter stream collector

## Usage:

    DB_PATH="[/data/twitter/]YYYY/MM/[twitter].YYYYMMDD.HH[.jsons]" TWITTER_USERNAME=username TWITTER_PASSWORD=password npm start

`DB_PATH` specifies the filename format of destination files. `DB_PATH` is treated as [Moment.js](http://momentjs.com/) format string (in UTC).


### Redis support (experimental)

If you have set environment variable `REDIS_CHANNEL`, the received messages are published to redis.

`REDIS_HOST`, `REDIS_PORT` and `REDIS_PASSWORD` are optional. If none specified, it connects localhost:6379 without password.
