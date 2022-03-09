# frozen_string_literal: true

class RequestLocation
  Result = Struct.new(:success, :error, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  def call(user:)
    result = MessageSender.send_text(user.external_id, 'Where are you?')
    unless result.success
      return Result.new(success: false, error: "failed to send message to @#{user.username}, #{result.error}")
    end

    @repo.update_user(user.id, wait_location: true)
    Application.logger.info { "request location from @#{user.username}" }
    Result.new(success: true)
  end
end
