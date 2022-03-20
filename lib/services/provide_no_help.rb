# frozen_string_literal: true

class ProvideNoHelp
  Result = Struct.new(:success, :error, :message, keyword_init: true)

  def initialize
    @repo = Repository.new
  end

  def call(user:)
    user = @repo.update_user(user.id, wait_help_request: false, help_request: nil, help_request_added_at: Time.now)
    ShowRequestInfo.new.call(user: user) if user.location_expired?
    Application.logger&.info { "user @#{user.username} requires no help" }
    Result.new(success: true, message: 'Збережено: допомога не потрібна')
  end
end
