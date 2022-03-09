# frozen_string_literal: true

class MyGroupsCommand < TelegramApp::Command
  def initialize
    @repo = Repository.new
  end

  def call(message)
    user = @repo.find_user_by_external_id(message.from.id)
    if user.nil?
      MessageSender.send_text(message.chat.id, 'Groups (0)')
      return
    end

    groups = @repo.collect_groups_by_user(user.id)
    group_names = groups.map(&:title)
    MessageSender.send_text(message.chat.id, "Groups (#{groups.size})\n#{group_names.join("\n")}")
  end
end
