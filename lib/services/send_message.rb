class SendMessage
  Result = Struct.new(:success, :error, keyword_init: true)

  # @param chat_id [Text]
  # @param text [Text,nil]
  # @param reply_markup [nil,Telegram::Bot::Types::ReplyKeyboardMarkup,Telegram::Bot::Types::InlineKeyboardMarkup]
  def call(chat_id:, text: nil, reply_markup: nil)
    Application.bot_api.send_message(chat_id: chat_id, text: text, reply_markup: reply_markup)
    Result.new(success: true)
  rescue Telegram::Bot::Exceptions::ResponseError => e
    handle_send_error(e)
    Result.new(success: false, error: e.message)
  end

  def handle_send_error(exception)
    CaptureError.log_error(exception)
    CaptureError.capture_exception(exception, tags: { action_class: self.class.name })
  end
end
