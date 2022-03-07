$:.push File.expand_path('../lib', __FILE__)

require 'virtus_model/version'

Gem::Specification.new do |s|
  s.name = 'virtus_model'
  s.version = VirtusModel::VERSION
  s.authors = ['Derek Schaefer']
  s.email = ['derek.schaefer@gmail.com']
  s.summary = 'VirtusModel = Virtus + ActiveModel'
  s.description = 'A practical and pleasant union of Virtus and ActiveModel.'
  s.homepage = 'https://github.com/derek-schaefer/virtus_model'
  s.licenses = ['MIT']

  s.required_ruby_version = '>= 2.2.2'
  s.files = Dir['{lib}/**/*', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'virtus', '~> 1.0'
  s.add_dependency 'activemodel', '>= 6.1', '< 7'
  s.add_dependency 'activesupport', '>= 6.1', '< 7'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rdoc', '~> 4.2'
  s.add_development_dependency 'rspec', '~> 3.10'
  s.add_development_dependency 'shoulda-matchers', '~> 4.0'
  s.add_development_dependency 'shoulda-callback-matchers', '~> 1.1'
  s.add_development_dependency 'simplecov', '~> 0.17'
end
