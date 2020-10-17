# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
    gem.name          = "fluent-plugin-rsyslog"
    gem.version       = "0.1"

    gem.authors       = ["Atanas Prezhdarov"]
    gem.email         = ["atanas.prezhdarov@gtt.net"]
    gem.description   = "Output plugin for streaming logs out to a remote syslog in either RFC3164 or RFC5242 format"
    gem.summary       = gem.description
    gem.homepage      = "https://github.com/prezhdarov/fluent-plugin-rsyslog"
  
    gem.license = "Apache-2.0"

    gem.files         = `git ls-files`.split($\)
    gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
    gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
    gem.require_paths = ['lib']
   
  
    gem.required_ruby_version = '>= 2.4'


    gem.add_dependency("fluentd", ["~> 1.11.3"])
    #gem.add_dependency("fluent-mixin-config-placeholders", ["~> 0.4.0"])

    gem.add_development_dependency("rake", ["~> 13.0"])
    gem.add_development_dependency("rr", ["~> 1.0"])
    gem.add_development_dependency("test-unit", ["~> 3.3"])
    gem.add_development_dependency("test-unit-rr", ["~> 1.0"])
  end




