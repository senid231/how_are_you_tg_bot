# how_are_you_tg_bot

[![Stand With Ukraine](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://vshymanskyy.github.io/StandWithUkraine)

Telegram bot that helps team to share info about current location

## Setup

```shell
./bin/setup
```

or 
```
bundle install
cp config/config.example.yml config/config.yml
bundle exec rake db:setup
```

## Run

```shell
APP_TOKEN="mytoken" TZ="Europe/Kiev" ./bin/bot
```

It will create sqlite3 db file in `db/how_are_you_bot.db`

## IRB Console

```shell
./bin/console
```

