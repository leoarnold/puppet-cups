source 'https://rubygems.org'

puppet_version = ENV['PUPPET_GEM_VERSION']

gem 'puppet', (puppet_version.nil? ? '~> 5.0' : puppet_version)

group :development do
  gem 'bundler', '1.16.3'
  gem 'codacy-coverage', '2.0.1'
  gem 'coderay', '1.1.2'
  gem 'mdl', '0.5.0'
  gem 'metadata-json-lint', '2.2.0'
  gem 'puppetlabs_spec_helper', '2.9.1'
  gem 'rake', '12.3.1'
  gem 'rspec-puppet-facts', '1.9.0'
  gem 'semantic_puppet' if puppet_version.to_f < 4.9
  gem 'simplecov', '0.16.1'
end

group :acceptance_testing do
  gem 'beaker', '4.0.0'
  gem 'beaker-rspec', '6.2.4'
end

group :documentation do
  gem 'puppet-strings', '2.1.0'
  gem 'redcarpet', '3.4.0'
end

group :release do
  gem 'github_api', '0.18.2'
  gem 'puppet-blacksmith', '4.1.2'
end

group :metatools do
  gem 'github-linguist', '6.4.1'
  gem 'guard', '~> 2.14'
  gem 'guard-bundler', '~> 2.1'
  gem 'guard-livereload', '~> 2.5'
  gem 'guard-rake', '~> 1.0'
  gem 'guard-rubocop', '~> 1.3'
  gem 'overcommit', '0.45.0'
  gem 'rubocop', '0.58.2'
  gem 'rubocop-rspec', '1.28.0'
  gem 'travis', '1.8.9'
end
