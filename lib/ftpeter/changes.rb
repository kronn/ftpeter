module Ftpeter
  Changes = Struct.new(:deleted, :changed, :added) do
    def newdirs
      @newdirs ||= added.map { |fn|
        Pathname.new(fn).dirname.to_s
      }.uniq.reject do |fn|
        fn == "."
      end
    end
  end
end
