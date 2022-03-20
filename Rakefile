require_relative 'config/application'

task :application do
  Application.setup
end

namespace :db do
  task setup: :application do
    require_relative 'db/schema'

    Schema.call
  end
end
