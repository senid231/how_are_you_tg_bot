# frozen_string_literal: true

class StopAction < ApplicationAction
  def call
    if chat.type == 'group'
      remove_me_from_group
    else
      remove_from_all_groups
    end
  end

  private

  def remove_me_from_group
    logger.info { "remove me command from id=#{from.id.inspect}, username=#{from.username.inspect}" }
    halt_message(chat_id: chat.id, text: "user @#{from.username} already removed") if user.nil? || group.nil?

    result = RemoveUser.new.call(user: user, groups: [group])
    unless result.success
      halt_message(chat_id: chat.id, text: "Error: failed to remove user @#{from.username} from group @#{chat.username}, #{result.error}")
    end

    send_message(chat_id: chat.id, text: "user @#{from.username} removed from group #{group.title}")
  end

  def remove_from_all_groups
    halt_message(chat_id: chat.id, text: "user @#{from.username} removed from all groups") if user.nil?

    result = RemoveUser.new.call(user: user)
    unless result.success
      halt_message(chat_id: chat.id, text: "Error: failed to remove user @#{from.username} from all groups, #{result.error}")
    end

    send_message(chat_id: chat.id, text: "user @#{from.username} removed all groups")
  end
end
