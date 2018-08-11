source 'https://rubygems.org'

puppet_version = ENV['PUPPET_GEM_VERSION']

gem 'puppet', (puppet_version.nil? ? '~> 5.0' : puppet_version)

group :development do
  gem 'bundler', '~> 1.16'
  gem 'codacy-coverage', '~> 2.0'
  gem 'coderay', '~> 1.1'
  gem 'mdl', '~> 0.3'
  gem 'metadata-json-lint', '~> 2.0'
  gem 'puppetlabs_spec_helper', '~> 2.0'
  gem 'rake', '~> 12.2'
  gem 'rspec-puppet-facts', '~> 1.7'
  gem 'semantic_puppet' if puppet_version.to_f < 4.9
  gem 'simplecov', '~> 0.13'
end

group :acceptance_testing do
  gem 'beaker', '~> 3.27'
  gem 'beaker-rspec', '~> 6.2'
end

group :documentation do
  gem 'puppet-strings', '~> 2.0'
  gem 'redcarpet', '~> 3.4'
end

group :release do
  gem 'github_api', '~> 0.18'
  gem 'puppet-blacksmith', '~> 4.0'
end

group :metatools do
  gem 'github-linguist', '~> 6.0'
  gem 'guard', '~> 2.14'
  gem 'guard-bundler', '~> 2.1'
  gem 'guard-livereload', '~> 2.5'
  gem 'guard-rake', '~> 1.0'
  gem 'guard-rubocop', '~> 1.3'
  gem 'overcommit', '~> 0.41'
  gem 'rubocop', '~> 0.51'
  gem 'travis', '~> 1.8'
end
