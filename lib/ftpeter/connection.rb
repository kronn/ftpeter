# frozen_string_literal: true
module Ftpeter
  Connection = Struct.new(:host, :credentials, :dir, :commands)
end
