# frozen_string_literal: true

class StatCommand < TelegramApp::Command
  def initialize
    @repo = Repository.new
  end

  def call(message)
    group = @repo.find_group_by_external_id(message.chat.id)
    result = GenerateStat.new.call(group: group)
    if result.success
      MessageSender.send_text(message.chat.id, result.text)
    else
      MessageSender.send_text(message.chat.id, "Error: failed to generate stat, #{result.error}")
    end
  end
end
