require "pathname"
require "uri"

module Ftpeter
  class CLI
    def initialize(args)
      @host = args[0] # the host to deploy to
      @dir  = args[1] || "/" # the directory to change into
      @last = args[2] || "origin/master" # get the last deployed version and current version

      configure
    end

    def configure
      @credentials = `grep #{URI(@host).host} ~/.netrc`.chomp
        .split("\n").first
        .match(/login (?<user>\S+) password (?<pass>\S+)/)
    end

    def go
      # internal vars
      lftp_script = []
      lftp_fn = Pathname.new("./lftp_script").expand_path

      # build up diff since last version
      files = `git log #{@last}... --name-status --oneline`.split("\n")
      deleted = files.grep(/^[RD]/).map { |l| l.gsub(/^[RD]\s+/, "") }.uniq
      changed = files.grep(/^[ACMR]/).map { |l| l.gsub(/^[ACMR]\s+/, "") }.uniq
      added   = files.grep(/^[A]/).map { |l| l.gsub(/^[A]\s+/, "") }.uniq
      newdirs = added.map { |fn| Pathname.new(fn).dirname.to_s }.uniq.reject { |fn| fn == "." }

      # lftp connection header
      lftp_script << "open #{@host}"
      lftp_script << "user #{@credentials["user"]} #{@credentials["pass"]}"
      lftp_script << "cd #{@dir}"

      # lftp file commands
      lftp_script << deleted.map do |fn|
        "rm #{fn}"
      end
      lftp_script << newdirs.map do |fn|
        "mkdir -p #{fn}"
      end
      lftp_script << changed.map do |fn|
        "put #{fn} -o #{fn}"
      end

      # write script to file
      lftp_fn.open("w") do |f|
        f << lftp_script.flatten.join("\n")
        f << "\n"
      end

      puts "="*80
      puts lftp_fn.read
      puts "="*80
      puts

      if okay?
        `lftp -f #{lftp_fn}`
        lftp_fn.delete
      else
        puts "#{lftp_fn} is left for your editing pleasure"
      end
    end

    def confirm(confirmation = "yes")
      $stderr.print "[yes, No] > "

      if $stdin.gets.chomp != confirmation
        abort("you did not enter '#{confirmation}', aborting")
      else
        true
      end
    end

    def okay?
      $stderr.puts "is this script okay?"
      begin
        confirm("yes")
      rescue
        false
      end
    end
  end
end
