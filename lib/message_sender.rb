# frozen_string_literal: true

module MessageSender
  Result = Struct.new(:success, :error, keyword_init: true)

  module_function

  def bot
    Application.bot
  end

  def send_text(chat_id, text, **opts)
    bot.api.send_message(chat_id: chat_id, text: text, **opts)
    Result.new(success: true)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    Application.logger.error { "Failed to send message to chat_id=#{chat_id.inspect}\n#{e.class}: #{e.message}\n#{e.backtrace&.join("\n")}" }
    Result.new(success: false, error: e.message)
  end
end
