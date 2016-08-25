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
    end

    def go
      # internal vars
      lftp_script = []
      lftp_fn = Pathname.new("./lftp_script").expand_path

      changes = get_changes_from(:git)

      # lftp connection header
      lftp_script << "open #{@host}"
      lftp_script << "user #{@credentials["user"]} #{@credentials["pass"]}" if @credentials
      lftp_script << "cd #{@dir}"

      # lftp file commands
      lftp_script << changes.deleted.map do |fn|
        "rm #{fn}"
      end
      lftp_script << changes.newdirs.map do |fn|
        "mkdir -p #{fn}"
      end
      lftp_script << changes.added.map do |fn|
        "put #{fn} -o #{fn}"
      end
      lftp_script << changes.changed.map do |fn|
        "put #{fn} -o #{fn}"
      end
      lftp_script << @commands.split("\n").map do |cmd|
        "!#{cmd}"
      end if @commands
      lftp_script << '!echo ""'
      lftp_script << '!echo "Deployment complete"'

      # write script to file
      lftp_fn.open("w") do |f|
        f << lftp_script.flatten.join("\n")
        f << "\n"
      end

      $stdout.puts "="*80
      $stdout.puts lftp_fn.read
      $stdout.puts "="*80
      $stdout.puts

      if okay?
        `lftp -f #{lftp_fn}`
        lftp_fn.delete
      else
        $stdout.puts "#{lftp_fn} is left for your editing pleasure"
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

  module Backend
    Changes = Struct.new(:deleted, :changed, :added) do
      def newdirs
        @newdirs ||= added.map { |fn|
          Pathname.new(fn).dirname.to_s
        }.uniq.reject { |fn|
          fn == "."
        }
      end
    end

    class Git
      attr_reader :changes

      def initialize(last)
        # build up diff since last version
        files = `git log #{last}... --name-status --oneline`.split("\n")
        deleted = files.grep(/^[RD]/).map { |l| l.gsub(/^[RD]\s+/, "") }.uniq
        changed = files.grep(/^[ACMR]/).map { |l| l.gsub(/^[ACMR]\s+/, "") }.uniq
        added   = files.grep(/^[A]/).map { |l| l.gsub(/^[A]\s+/, "") }.uniq

        @changes = Ftpeter::Backend::Changes.new(deleted, changed, added)
      end
    end
  end

  class Transport
    def initialize(changes)
      @changes = changes
    end

    def via(connection, uploader)
      raise ArgumentError, "There's only lftp-support for now" unless uploader == :lftp

      Ftpeter::Transport::Lftp.new(connection, @changes)
    end

    class Lftp
      def initialize(connection, changes)
        @changes = changes
        @lftp_script = []

        @host = connection.host
        @credentials = connection.credentials
        @dir = connection.dir
        @commands = connection.commands

        prepare
      end

      def prepare
        # lftp connection header
        @lftp_script << "open #{@host}"
        @lftp_script << "user #{@credentials["user"]} #{@credentials["pass"]}" if @credentials
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
    end
  end
end

