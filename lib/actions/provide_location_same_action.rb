# frozen_string_literal: true

class ProvideLocationSameAction < ApplicationAction
  def call
    halt_message(chat_id: chat.id, text: 'add yourself to the ask-list in the group') if user.nil?

    result = ProvideLocationSame.new.call(user: user)
    if result.success
      send_message(chat_id: chat.id, text: result.message)
    end
  end
end
