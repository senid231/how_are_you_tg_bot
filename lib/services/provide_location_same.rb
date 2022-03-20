# frozen_string_literal: true

class ProvideLocationSame
  Result = Struct.new(:success, :error, :message, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  def call(user:)
    user = @repo.update_user(user.id, wait_location: false, location_added_at: Time.now)
    ShowRequestInfo.new.call(user: user) if user.help_request_expired?
    Application.logger&.info { "user @#{user.username} does not change location" }
    Result.new(success: true, message: 'Збережено: місцезнаходження не змінилося')
  end
end
