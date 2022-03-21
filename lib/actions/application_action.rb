class ApplicationAction < TelegramApp::Action
  handle_send_exception do |exception|
    CaptureError.log_error(exception)
    CaptureError.capture_exception(exception, tags: { action_class: self.class.name })
  end

  private

  def user
    return @user if defined?(@user)

    @user = repo.find_user_by_external_id(from.id)
  end

  def group
    return @group if defined?(@group)

    @group = ['group', 'supergroup'].include?(chat.type) ? repo.find_group_by_external_id(chat.id) : nil
  end

  def repo
    @repo ||= Repository.new
  end
end
