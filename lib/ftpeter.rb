require "ftpeter/version"
require "pathname"

# TODO extract git-backend to detect changes
# TODO extract lftp-backend to deploy files
# TODO setup help and option-parsing
module Ftpeter
  autload :CLI, "ftpeter/cli"
end
