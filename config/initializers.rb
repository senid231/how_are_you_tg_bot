# frozen_string_literal: true

require_relative '../lib/router'
require_relative '../lib/scheduler'
require_relative '../lib/repository'
require_relative '../lib/text_helper'
require_relative '../lib/capture_error'

Dir[Application.root.join('lib/entities/*.rb')].sort.each { |path| require path }
Dir[Application.root.join('lib/services/*.rb')].sort.each { |path| require path }

require_relative '../lib/actions/application_action'
Dir[Application.root.join('lib/actions/*.rb')].sort.each { |path| require path }
