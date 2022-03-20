# frozen_string_literal: true

class ShowRequestInfoAction < ApplicationAction
  def call
    halt_message(chat_id: chat.id, text: 'nothing asked') if user.nil?

    ShowRequestInfo.new.call(user: user)
  end
end
