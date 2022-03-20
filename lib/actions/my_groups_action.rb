# frozen_string_literal: true

class MyGroupsAction < ApplicationAction
  def call
    halt_message(chat_id: chat.id, text: 'Groups (0)') if user.nil?

    groups = repo.collect_groups_by_user(user.id)
    group_names = groups.map(&:title)
    send_message(chat_id: chat.id, text: "Groups (#{groups.size})\n#{group_names.join("\n")}")
  end
end
