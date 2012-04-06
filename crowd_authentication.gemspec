# -*- encoding: utf-8 -*-
require File.expand_path('../lib/crowd_authentication/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'crowd_authentication'
  s.version     = CrowdAuthentication::VERSION
  s.date        = '2012-04-06'
  s.summary     = "Atlassian Crowd authentication in Rails"
  s.description = "Gem to integrate Atlassian Crowd authentication into a Rails application"
  s.authors     = ["Dieter Pisarewski"]
  s.email       = ['dieter@pisarewski.info']
  s.files       = Dir.glob("lib/**/*")
  s.homepage    = "http://www.arvatosystems-us.com/"
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rails"
  s.add_runtime_dependency "rest-client", "~> 1.6"
end