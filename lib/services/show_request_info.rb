# frozen_string_literal: true

class ShowRequestInfo
  Result = Struct.new(:success, :error, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  def call(user:)
    result = SendMessage.new.call(
      chat_id: user.external_id,
      text: reply_text(user),
      reply_markup: reply_markup(user)
    )
    unless result.success
      return Result.new(success: false, error: "failed to send message to @#{user.username}, #{result.error}")
    end

    Result.new(success: true)
  end

  private

  def reply_text(user)
    text_lines = []
    if user.location_added_at
      text_lines.push(
        "#{emoji_for(user, :location)}Остання інформація про місцезнаходження (#{user.location_added_at.strftime('%F')}): #{user.location}."
      )
    end
    if user.help_request_added_at && !user.help_request.nil?
      text_lines.push(
        "#{emoji_for(user, :help_request)}Останній запит допомоги (#{user.help_request_added_at.strftime('%F')}): #{user.help_request}."
      )
    end
    if user.help_request_added_at && user.help_request.nil?
      text_lines.push(
        "#{emoji_for(user, :help_request)}Останній раз допомога була не потрібна  (#{user.help_request_added_at.strftime('%F')})."
      )
    end

    text_lines.push("\n" + TextHelper.initial_request_info)
    text_lines.join("\n")
  end

  def reply_markup(user)
    keyboard = []
    keyboard.push(
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Вказати місцезнаходження', callback_data: 'request_location')
    )
    keyboard.push(
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Місцезнаходження не змінилося', callback_data: 'request_location_same')
    ) if user.location_added_at
    keyboard.concat(
      [
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Потрібна допомога', callback_data: 'request_help'),
        Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Допомога не потрібна', callback_data: 'request_no_help')
      ]
    )
    Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: keyboard)
  end

  def emoji_for(user, type)
    if type == :location
      user.location_expired? ? '⚠ ' : ''
    elsif type == :help_request
      user.help_request_expired? ? '⚠ ' : ''
    else
      raise ArgumentError, "invalid type #{type.inspect}"
    end
  end
end
