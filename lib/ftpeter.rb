# frozen_string_literal: true

# TODO: setup help and option-parsing
module Ftpeter
  autoload :CLI, 'ftpeter/cli'
  autoload :VERSION, 'ftpeter/version'

  # value classes
  autoload :Changes, 'ftpeter/changes'
  autoload :Connection, 'ftpeter/connection'

  # collection of plugable components
  autoload :Transport, 'ftpeter/transport'
  autoload :Backend, 'ftpeter/backend'
end
