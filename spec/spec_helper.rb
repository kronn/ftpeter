$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "ftpeter"
require "fakefs/spec_helpers" # ftpeter creates a temporary script for lftp
require "stringio"            # capture $stdout/$stderr in specs
