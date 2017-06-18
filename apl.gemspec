# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "apl/version"

Gem::Specification.new do |spec|
  spec.name          = "apl"
  spec.version       = APL::VERSION
  spec.authors       = ["Marnen Laibow-Koser"]
  spec.email         = ["marnen@marnen.org"]

  spec.summary       = 'Gem to allow APL array operations in Ruby'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/marnen/apl-gem'
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  [
    ["bundler", "~> 1.15"],
    ["rake", "~> 10.0"],
    'byebug',
    ['kpeg', '~> 1.0'],
    ["rspec", "~> 3.0"],
    'guard-rspec'
  ].each {|gem| spec.add_development_dependency *gem }
end
