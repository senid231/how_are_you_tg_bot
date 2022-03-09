# frozen_string_literal: true

class ProvideLocationCommand < TelegramApp::Command
  def initialize
    @repo = Repository.new
  end

  def call(message)
    user = @repo.find_user_by_external_id(message.from.id)
    if user.nil?
      MessageSender.send_text message.chat.id, Application.usage
      return
    end

    ProvideLocation.new.call(user: user, location: message.text)
    MessageSender.send_text message.chat.id, 'thanks for the answer'
  end
end
