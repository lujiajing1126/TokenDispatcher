# coding: utf-8
require 'rubygems'
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
require 'tokendispatcher/version'

Gem::Specification.new do |s|
  s.name        = 'tokendispatcher'
  s.version     = TokenDispatcher::VERSION
  s.date        = '2015-01-21'  
  s.licenses    = ['MIT']
  s.summary     = "A Token Dispatcher"
  s.description = "A useful token provider with fix lru cache pool and fixed length queue"  
  s.authors     = ["Megrez Lu"]
  s.email       = 'lujiajing1126@gmail.com'
  s.platform = Gem::Platform::RUBY
  s.files = `git ls-files`.split("\n")
  s.require_paths << 'lib'
  s.homepage ='https://github.com/lujiajing1126/tokendispatcher.git'
  s.bindir = 'bin'
  s.executables << 'tokendispatcher'
  s.add_runtime_dependency('eventmachine','1.0.4')
  s.add_runtime_dependency('uuid','2.3.7')
end
