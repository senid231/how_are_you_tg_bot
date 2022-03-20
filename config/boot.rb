# frozen_string_literal: true

require 'bundler/setup'

Bundler.require(:default)

$LOAD_PATH.push File.expand_path('../../lib', __FILE__)

require 'utils'
require 'telegram_app'
require_relative './configuration'
