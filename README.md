# how_are_you_tg_bot

Telegram bot that helps team to share info about current location

## Setup

```shell
./bin/setup
```

or 
```
bundle install
cp config/config.example.yml config/config.yml
```

## Run

```shell
APP_TOKEN="mytoken" TEAM_NAME="My team" ./bin/bot
```

It will create sqlite3 db file in `db/how_are_you_bot.db`

## IRB Console

```shell
./bin/console
```

