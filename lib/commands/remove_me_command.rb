# frozen_string_literal: true

class RemoveMeCommand < TelegramApp::Command
  def initialize
    @repo = Repository.new
  end

  def call(message)
    if message.chat.type == 'group'
      remove_from_all_groups(message)
    else
      remove_me_from_group(message)
    end
  end

  private

  def remove_me_from_group(message)
    Application.logger.info { "remove me command from id=#{message.from.id.inspect}, username=#{message.from.username.inspect}" }
    user = @repo.find_user_by_external_id(message.from.id)
    group = @repo.find_group_by_external_id(message.chat.id)
    if user.nil? || group.nil?
      MessageSender.send_text(message.chat.id, "user @#{message.from.username} already removed")
      return
    end

    result = RemoveUser.new.call(user: user, groups: [group])
    if result.success
      MessageSender.send_text(message.chat.id, "user @#{message.from.username} removed from group #{group.title}")
    else
      MessageSender.send_text(message.chat.id, "Error: failed to remove user @#{message.from.username} from group @#{message.chat.username}, #{result.error}")
    end
  end

  def remove_from_all_groups(message)
    user = @repo.find_user_by_external_id(message.from.id)
    if user.nil?
      MessageSender.send_text(message.chat.id, "user @#{message.from.username} removed from all groups")
      return
    end

    result = RemoveUser.new.call(user: user)
    if result.success
      MessageSender.send_text(message.chat.id, "user @#{message.from.username} removed all groups")
    else
      MessageSender.send_text(message.chat.id, "Error: failed to remove user @#{message.from.username} from all groups, #{result.error}")
    end
  end
end
