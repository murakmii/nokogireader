# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nokogireader/version'

Gem::Specification.new do |spec|
  spec.name          = "nokogireader"
  spec.version       = Nokogireader::VERSION
  spec.authors       = ["bonono"]
  spec.email         = ["bonono.jp@gmail.com"]

  spec.summary       = %q{DSL for parsing xml using Nokogiri::XML::Reader}
  spec.homepage      = "https://github.com/bonono/nokogireader"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'nokogiri', '~> 1.6'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-its", "~> 1.0"
  spec.add_development_dependency "simplecov"
end
