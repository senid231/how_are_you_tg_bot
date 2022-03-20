# frozen_string_literal: true

class RequestLocationAction < ApplicationAction
  def call
    halt_message(chat_id: chat.id, text: 'add yourself to the ask-list in the group') if user.nil?

    RequestLocation.new.call(user: user)
  end
end
