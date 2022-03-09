# frozen_string_literal: true

class MessageHandler < TelegramApp::MessageHandler
  command :start do |message|
    MessageSender.send_text(message.chat.id, Application.usage)
  end

  command :startgroup, type: 'group' do |message|
    MessageSender.send_text(message.chat.id, Application.usage)
  end

  command :add_me, type: 'group' do |message|
    AddMeCommand.new.call(message)
  end

  command :stat, type: 'group' do |message|
    StatCommand.new.call(message)
  end

  command :remove_me do |message|
    RemoveMeCommand.new.call(message)
  end

  command :my_groups, type: 'private' do |message|
    MyGroupsCommand.new.call(message)
  end

  match '' do |_|
    # Telegram sends message with empty text along with Telegram::Bot::Types::ChatMemberUpdated.
    # Since we handle it in ChatMemberUpdatedHandler, we just ignore such messages here.
  end

  # other commands
  match /\/.+/ do |message|
    MessageSender.send_text(message.chat.id, Application.usage)
  end

  match /.+/, type: 'private' do |message|
    ProvideLocationCommand.new.call(message)
  end

  fallback do |message|
    MessageSender.send_text(message.chat.id, Application.usage)
  end
end
