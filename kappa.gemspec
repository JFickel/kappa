Gem::Specification.new do |s|
  s.name = 'kappa'
  s.version = eval(File.read('lib/kappa/version.rb'))
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'Ruby library for interfacing with the Twitch.tv API.'
  s.description = <<-END
    A Ruby library for interfacing with the Twitch.tv API
    including users, channels, streams, and followers.
  END
  s.authors = ['Chris Schmich']
  s.email = 'schmch@gmail.com'
  s.files = Dir['{lib}/**/*.rb', 'bin/*', '*.md']
  s.require_path = 'lib'
  s.homepage = 'https://github.com/schmich/kappa'
  s.add_runtime_dependency 'httparty', '>= 0.9.0'
  s.add_runtime_dependency 'addressable', '>= 2.3.3'
  s.add_development_dependency 'rake', '>= 0.9'
  s.add_development_dependency 'webmock', '>= 1.11.0'
  s.add_development_dependency 'rspec', '>= 2.13.0'
  s.add_development_dependency 'launchy', '>= 2.3.0'
  s.add_development_dependency 'yard', '>= 0.8.6'
  s.add_development_dependency 'simplecov', '>= 0.7.1'
  s.add_development_dependency 'coveralls'
end
