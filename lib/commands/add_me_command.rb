# frozen_string_literal: true

class AddMeCommand < TelegramApp::Command
  def call(message)
    result = AddUser.new.call(
      user_external_id: message.from.id,
      username: message.from.username,
      group_external_id: message.chat.id,
      group_title: message.chat.title
    )
    if result.success
      MessageSender.send_text(message.chat.id, "user @#{message.from.username} added")
    else
      MessageSender.send_text(message.chat.id, "Error: failed to add user @#{message.from.username}, #{result.error}")
    end
  end
end
