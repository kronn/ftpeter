# TODO check if needed here (they shouldn't be)
require "ftpeter/version"
require "pathname"

# TODO setup help and option-parsing
module Ftpeter
  autoload :CLI, "ftpeter/cli"
  autoload :Changes, "ftpeter/changes"
  autoload :Connection, "ftpeter/connection"
  autoload :Transport, "ftpeter/transport"
  autoload :Backend, "ftpeter/backend"
end
