require 'pathname'

module Ftpeter
  class Transport
    class Lftp
      attr_reader :script

      def initialize(connection, changes)
        @changes = changes
        @lftp_script = []
        @script = Pathname.new("./lftp_script").expand_path

        @host = connection.host
        @credentials = connection.credentials
        @dir = connection.dir
        @commands = connection.commands

        prepare
      end

      def prepare
        # lftp connection header
        @lftp_script << "open #{@host}"
        if @credentials
          @lftp_script << "user #{@credentials["user"]} #{@credentials["pass"]}"
        end
        @lftp_script << "cd #{@dir}"

        # lftp file commands
        @lftp_script << @changes.deleted.map do |fn|
          "rm #{fn}"
        end
        @lftp_script << @changes.newdirs.map do |fn|
          "mkdir -p #{fn}"
        end
        @lftp_script << @changes.added.map do |fn|
          "put #{fn} -o #{fn}"
        end
        @lftp_script << @changes.changed.map do |fn|
          "put #{fn} -o #{fn}"
        end
        @lftp_script << @commands.split("\n").map do |cmd|
          "!#{cmd}"
        end if @commands
        @lftp_script << '!echo ""'
        @lftp_script << '!echo "Deployment complete"'

        @lftp_script.flatten!.compact!

        @lftp_script
      end

      def commands
        @lftp_script
      end

      def inform
        @lftp_script.join("\n")
      end

      def persist
        script.open("w") do |f|
          f << @lftp_script.flatten.join("\n")
          f << "\n"
        end
      end

      def execute
        system("lftp -f #{script}")
      end

      def cleanup
        script.delete
      end
    end
  end
end
