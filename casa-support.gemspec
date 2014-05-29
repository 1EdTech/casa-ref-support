Gem::Specification.new do |s|

  s.name        = 'casa-support'
  s.version     = '0.1.0'
  s.summary     = 'Support for the reference implementation of the CASA Protocol modules'
  s.authors     = ['Eric Bollens']
  s.email       = ['ebollens@ucla.edu']
  s.homepage    = 'http://imsglobal.github.io/casa'
  s.license     = 'BSD-3-Clause'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'coveralls'

end