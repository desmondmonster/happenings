# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'happenings/version'

Gem::Specification.new do |spec|
  spec.name          = "happenings"
  spec.version       = Happenings::VERSION
  spec.authors       = ["Desmond Bowe"]
  spec.email         = ["desmondbowe@gmail.com"]
  spec.summary       = %q{Event-Driven Domain Scaffold}
  spec.description   = %q{For use in applications where business domain events are first-class citizens}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
