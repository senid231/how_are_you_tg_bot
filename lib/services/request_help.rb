# frozen_string_literal: true

class RequestHelp
  Result = Struct.new(:success, :error, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  def call(user:)
    result = SendMessage.new.call(
      chat_id: user.external_id,
      text: 'Яка вам потрібна допомога?',
      reply_markup: reply_markup
    )
    unless result.success
      return Result.new(success: false, error: "failed to send message to @#{user.username}, #{result.error}")
    end

    @repo.update_user(user.id, wait_help_request: true)
    Result.new(success: true)
  end

  private

  def reply_markup
    Telegram::Bot::Types::ForceReply.new(
      force_reply: true,
      input_field_placeholder: 'наприклад: мені потрібні гроші'
    )
  end
end
