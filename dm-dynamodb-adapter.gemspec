# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'dm-dynamodb-adapter/version'

Gem::Specification.new do |spec|
  spec.name          = "dm-dynamodb-adapter"
  spec.version       = DynamoDBAdapter::VERSION
  spec.authors       = ["AnyPresence"]
  spec.email         = ["info@anypresence.com"]
  spec.summary       = "DM adapter for Amazon DynamoDB based data sources."
  spec.homepage      = "https://github.com/AnyPresence/dm-dynamodb-adapter"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency "aws-sdk",     "~> 1.12.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
