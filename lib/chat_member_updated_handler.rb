# frozen_string_literal: true

class ChatMemberUpdatedHandler
  def initialize
    @bot_id = Application.bot_info.id
    @repo = Repository.new
  end

  def call(message)
    # Application.logger.debug { Utils::Format.pretty_format_message(message) }
    old = message.old_chat_member
    new = message.new_chat_member
    return if old.user.id != @bot_id || new.user.id != @bot_id

    if old.status == 'member' && (new.status == 'kicked' || new.status == 'left')
      kicked(message)
    elsif (old.status == 'kicked' || old.status == 'left') && new.status == 'member'
      added(message)
    end
  end

  private

  def remove_group(group_external_id)
    group = @repo.find_group_by_external_id(group_external_id)
    return if group.nil?

    RemoveGroup.new.call(group: group)
  end

  def remove_user(user_external_id)
    user = @repo.find_user_by_external_id(user_external_id)
    return if user.nil?

    RemoveUser.new.call(user: user)
  end

  def kicked(message)
    if message.chat.type == 'group'
      Application.logger.info { "Bot removed from group #{message.chat.title.inspect}" }
      remove_group(message.chat.id)
    elsif message.chat.type == 'private'
      Application.logger.info { "Bot blocked by @#{message.chat.username}" }
      remove_user(message.chat.id)
    end
  end

  def added(message)
    if message.chat.type == 'group'
      Application.logger.info { "Bot added to group #{message.chat.title.inspect}" }
      MessageSender.send_text(message.chat.id, Application.usage)
    elsif message.chat.type == 'private'
      Application.logger.info { "Bot started by @#{message.chat.username}" }
      # After this event user always sent /start command, so nothing to do here.
    end
  end
end
