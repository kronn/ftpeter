module Ftpeter
  class Transport
    autoload :Lftp, "ftpeter/transport/lftp"

    def initialize(changes)
      @changes = changes
    end

    def via(connection, uploader)
      raise ArgumentError, "There's only lftp-support for now" unless uploader == :lftp

      Ftpeter::Transport::Lftp.new(connection, @changes)
    end
  end
end
