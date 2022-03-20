# frozen_string_literal: true

# Calculate correct cron time at https://crontab.guru/
class Scheduler < TelegramApp::Scheduler

  # Every day at 12:00
  cron '* * * * *' do
    # cron '0 12 * * *' do
    Application.logger&.info { 'ask users with expired info to update it' }
    repo = Repository.new
    repo.collect_users.each do |user|
      ShowRequestInfo.new.call(user: user) if user.location_expired? || user.help_request_expired?
    end
  end

  # Every day at 13:00
  cron '* * * * *' do
    # cron '0 13 * * *' do
    Application.logger&.info { 'print stats for groups' }
    repo = Repository.new
    repo.collect_groups.each do |group|
      GenerateStat.new.call(group: group)
    end
  end
end
