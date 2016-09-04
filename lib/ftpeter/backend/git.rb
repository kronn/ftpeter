# frozen_string_literal: true
module Ftpeter
  module Backend
    class Git
      attr_reader :changes

      def initialize(last)
        # build up diff since last version
        files = `git log #{last}... --name-status --oneline`.split("\n")
        deleted = files.grep(/^[RD]/).map { |l| l.gsub(/^[RD]\s+/, '') }.uniq
        changed = files.grep(/^[ACMR]/).map { |l| l.gsub(/^[ACMR]\s+/, '') }.uniq
        added   = files.grep(/^[A]/).map { |l| l.gsub(/^[A]\s+/, '') }.uniq

        @changes = Ftpeter::Changes.new(deleted, changed, added)
      end
    end
  end
end
