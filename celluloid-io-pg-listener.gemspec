# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "celluloid-io-pg-listener/version"

Gem::Specification.new do |spec|
  spec.name          = "celluloid-io-pg-listener"
  spec.version       = CelluloidIOPGListener::VERSION
  spec.authors       = ["Peter Boling", "Rohit Gupta"]
  spec.email         = ["peter.boling@gmail.com", "rhitrg@gmail.com"]

  spec.summary       = %q{Asynchronously LISTEN for Postgresql NOTIFY messages with payloads and Do Something}
  spec.description   = %q{Asynchronously LISTEN for Postgresql NOTIFY messages with payloads and Do Something}
  spec.homepage      = "https://github.com/pboling/celluloid-io-pg-listener"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "celluloid-io", ">= 0.17.2"
  spec.add_dependency "pg", ">= 0.18.3"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "rspec-rails", "~> 5.0"
  spec.add_development_dependency "appraisal", "~> 2.1"
  spec.add_development_dependency "activerecord", ">= 3.2"
  spec.add_development_dependency "database_cleaner", "~> 2.0"
  spec.add_development_dependency "test-unit", "~> 3.1"
  spec.add_development_dependency "pry", "~> 0.10"

end
