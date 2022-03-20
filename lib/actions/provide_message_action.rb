# frozen_string_literal: true

class ProvideMessageAction < ApplicationAction
  def call
    halt_message(chat_id: chat.id, text: 'nothing asked') if user.nil?

    result = ProvideInfo.new.call(user: user, text: message.text)
    if result.success
      send_message(chat_id: message.chat.id, text: result.message)
    end
  end
end
