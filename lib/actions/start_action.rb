# frozen_string_literal: true

class StartAction < ApplicationAction
  before_action :private_greeting

  def call
    if chat.type != 'group'
      halt_message(chat_id: chat.id, text: 'TODO: usage')
    end

    user_data = AddUser::UserData.new(
      external_id: from.id,
      username: from.username,
      first_name: from.first_name,
      last_name: from.last_name
    )
    group_data = AddUser::GroupData.new(
      external_id: chat.id,
      title: chat.title
    )
    result = AddUser.new.call(
      user_data: user_data,
      group_data: group_data
    )
    unless result.success
      halt_message(
        chat_id: chat.id,
        text: "Error: failed to add user @#{message.from.username}, #{result.error}"
      )
    end

    send_message(chat_id: chat.id, text: "user @#{from.username} added")
  end

  private

  def private_greeting
    return if chat.type != 'private'

    halt_message(chat_id: chat.id, text: "Greeting @#{from.username}")
  end
end
