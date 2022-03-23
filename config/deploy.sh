#!/bin/bash

# Deploy to debian server using git and ruby 2.7.5 via rbenv
# Run from root

mkdir -p /opt/
cd /opt
git clone https://github.com/senid231/how_are_you_ua_bot.git
cd how_are_you_ua_bot
cp config/config.example.yml config/config.yml
bundle exec rake db:setup
adduser --disabled-password --shell "/bin/bash" --gecos "How Are You telegram bot" how_are_you_ua_bot
chown -R how_are_you_ua_bot:how_are_you_ua_bot /opt/how_are_you_ua_bot
cp how_are_you_ua_bot.service /etc/systemd/system/
systemctl daemon-reload
echo "Replace your APP_TOKEN in /etc/systemd/system/how_are_you_ua_bot.service"
echo "Start application via systemctl start how_are_you_ua_bot.service"
echo "See status via systemctl start how_are_you_ua_bot.service"
echo "See logs via journalctl -u how_are_you_ua_bot.service -f -n 20"
