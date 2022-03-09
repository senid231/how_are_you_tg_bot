# frozen_string_literal: true

require_relative './listener'
require_relative './scheduler'
require_relative './message_sender'
require_relative './message_handler'
require_relative './chat_member_updated_handler'
require_relative './repository'
require_relative './entities/user'
require_relative './entities/group'
require_relative './services/add_user'
require_relative './services/remove_user'
require_relative './services/remove_group'
require_relative './services/generate_stat'
require_relative './services/provide_location'
require_relative './services/request_location'
require_relative './commands/add_me_command'
require_relative './commands/remove_me_command'
require_relative './commands/stat_command'
require_relative './commands/my_groups_command'
require_relative './commands/provide_location_command'

Repository.check_schema
