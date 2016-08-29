require "pathname"

module Ftpeter
  class CLI
    def initialize(args)
      raise ArgumentError, "Please specify a host to deploy to" unless args[0]

      @host = args[0]
      @dir  = args[1] || "/" # the directory to change into
      @last = args[2] || "origin/master" # get the last deployed version and current version

      configure
    end

    def configure
      cleaned_host = if @host =~ %r!//!
                        require "uri"
                        URI(@host).host
                      else
                        @host
                      end

      @credentials = begin
                       `grep #{cleaned_host} ~/.netrc`.chomp
                         .split("\n").first
                         .match(/login (?<user>\S+) password (?<pass>\S+)/)
                     rescue NoMethodError => e
                       nil
                     end

      @commands    = begin
                       Pathname.new("./.ftpeterrc").read.chomp
                     rescue Errno::ENOENT=> e
                       nil
                     end

      @connection = Ftpeter::Connection.new(
        @host,
        @credentials,
        @dir,
        @commands
      )
    end

    def go
      changes = get_changes_from(:git)
      upload  = transport(changes).via(@connection, :lftp)

      $stdout.puts "="*80, upload.inform, "="*80, nil
      upload.persist

      if okay?
        upload.execute and upload.cleanup
      else
        $stdout.puts "#{upload.script} is left for your editing pleasure"
      end
    end

    def confirm(confirmation = "yes")
      $stderr.print "[yes, No] > "

      if $stdin.gets.chomp != confirmation
        raise "you did not enter '#{confirmation}', aborting"
      else
        true
      end
    end

    def okay?
      $stdout.puts "is this script okay?"
      begin
        confirm("yes")
      rescue RuntimeError
        false
      end
    end

    def get_changes_from(vcs)
      raise ArgumentError, "There's only git-support for now" unless vcs == :git

      Ftpeter::Backend::Git.new(@last).changes
    end

    def transport(changes)
      Ftpeter::Transport.new(changes)
    end
  end
end

