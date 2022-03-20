module CaptureError
  module_function

  def setup
    return if defined?(@setup) && @setup

    Sentry.init do |config|
      config.dsn = Application.config.sentry_dsn
      config.environment = Application.config.sentry_env

      config.traces_sample_rate = 0.5
      config.background_worker_threads = 1
      config.send_default_pii = true

      config.logger = logger
      config.breadcrumbs_logger = [:sentry_logger]

      release_path = Application.root.join('.git_release')
      config.release = File.exist?(release_path) ? File.read(release_path).chomp : 'unknown'
    end
    Sentry.configure_scope do |scope|
      scope.set_tags(Application.config.sentry_tags || {})
    end
    @setup = true
  end

  def logger
    Application.logger
  end

  def capture_exception(exception, context = {})
    with_context(context) do
      Sentry.capture_exception(exception)
    end
  end

  def capture_message(message, context = {})
    with_context(context) do
      Sentry.capture_message(message)
    end
  end

  def with_context(context = {})
    Sentry.with_scope do |scope|
      scope.set_tags(context[:tags]) if context[:tags]
      scope.set_extras(context[:extra]) if context[:extra]
      scope.set_user(context[:user]) if context[:user]
      scope.set_contexts(context[:context]) if context[:context]
      yield
    end
  end

  def log_error(exception, skip_backtrace = false, causes = [])
    return if logger.nil?

    logger&.error do
      parts = []
      parts.push('caused by:') unless causes.empty?
      parts.push("<#{exception.class}> #{exception.message}")
      parts.push(exception.backtrace&.join("\n")) unless skip_backtrace
      parts.join("\n")
    end

    if exception.cause && exception.cause != exception && !causes.include?(exception.cause)
      causes.push(exception)
      log_error(exception.cause, skip_backtrace: skip_backtrace, causes: causes)
    end
  end
end
