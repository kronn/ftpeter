lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ftpeter/version"

Gem::Specification.new do |spec|
  spec.name          = "ftpeter"
  spec.version       = Ftpeter::VERSION
  spec.authors       = ["Matthias Viehweger"]
  spec.email         = ["kronn@kronn.de"]

  spec.summary       = %q{Deployments via FTP}
  spec.description   = %q{Upload or delete files that have changed in git using lftp. lftp supports ftp, ftps, sftp and more.}
  spec.homepage      = "https://git.lanpartei.de/kronn/ftpeter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakefs"
end
