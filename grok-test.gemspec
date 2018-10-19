require 'rake'

Gem::Specification.new do |s|
  s.name        = 'grok-test'
  s.version     = '0.2.0'
  s.summary     = "Test grok patterns"
  s.authors     = ["Tero Marttila"]
  s.email       = 'tero.marttila@funidata.fi'
  s.files       = FileList[
    'bin/grok-test',
    'lib/*.rb',
    'patterns/*',
  ]
  s.executables = [
    'grok-test',
  ]

  s.add_runtime_dependency "jls-grok", '~> 0.11.3'
end
