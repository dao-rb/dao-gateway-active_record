lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dao/gateway/active_record/version'

Gem::Specification.new do |spec|
  spec.name          = 'dao-gateway-active_record'
  spec.version       = Dao::Gateway::ActiveRecord::VERSION
  spec.authors       = ['llxff', 'ssnikolay']
  spec.email         = ['ll.wg.bin@gmail.com']

  spec.summary       = 'ActiveRecord gateway for dao-repository'
  spec.description   = 'ActiveRecord gateway for dao-repository'
  spec.homepage      = 'https://github.com/dao-rb/dao-gateway-active_record'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2.2'

  spec.add_dependency 'dao-gateway', '~> 1.3'
  spec.add_dependency 'activerecord', '>= 4.2'
  spec.add_dependency 'activesupport', '>= 4.2'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
