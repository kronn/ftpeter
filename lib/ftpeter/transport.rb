module Ftpeter
  class Transport
    class Unsupported < ArgumentError
      def message
        "There is only lftp-support for now"
      end
    end

    autoload :Lftp, "ftpeter/transport/lftp"

    def initialize(changes)
      @changes = changes
    end

    def via(connection, uploader)
      raise Unsupported unless uploader == :lftp

      Ftpeter::Transport::Lftp.new(connection, @changes)
    end
  end
end
