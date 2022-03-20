# frozen_string_literal: true

class ProvideInfo
  Result = Struct.new(:success, :error, :message, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  def call(user:, text:)
    if user.wait_location
      user = @repo.update_user(user.id, wait_location: 0, location: text, location_added_at: Time.now)
      ShowRequestInfo.new.call(user: user) if user.help_request_expired?
      Application.logger&.info { "user @#{user.username} changes location to: #{text}" }
      return Result.new(success: true, message: 'Збережено: місцезнаходження оновлено')
    end

    if user.wait_help_request
      user = @repo.update_user(user.id, wait_help_request: 0, help_request: text, help_request_added_at: Time.now)
      ShowRequestInfo.new.call(user: user) if user.location_expired?
      Application.logger&.info { "user @#{user.username} requires help with: #{text}" }
      return Result.new(success: true, message: "Збережено: запит на допомогу оновлений")
    end

    Result.new(success: false, error: 'nothing asked')
  end
end
