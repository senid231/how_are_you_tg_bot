# frozen_string_literal: true

require_relative './boot'

class Application < TelegramApp::Application
  configure do |app|
    app.root = File.expand_path('..', __dir__)
    app.logger = Logger.new($stdout)
    $stdout.sync = true

    require_relative './initializers'

    app.config = Configuration.load_config
    app.router = Router.new(app)
    app.scheduler = Scheduler.new(app)

    Repository.database_url = app.config.database_url
    CaptureError.setup
  end

  around_receive do |message, &block|
    repo = Repository.new
    user = repo.find_user_by_external_id(message.from.id)
    CaptureError.with_context(
      user: { id: user&.id },
      context: {
        telegram_message: Utils::Format.pretty_hash_message(message)
      },
      &block
    )
  end
end
