source 'https://rubygems.org'

puppetversion = ENV['PUPPET_GEM_VERSION']

# Gemnasium.com does not understand ternary operators
#
# rubocop:disable Bundler/DuplicatedGem
if puppetversion.nil?
  gem 'puppet', '~> 5.0'
else
  gem 'puppet', puppetversion
end
# rubocop:enable Bundler/DuplicatedGem

group :development do
  gem 'bundler', '~> 1.16'
  gem 'codacy-coverage', '~> 1.0'
  gem 'coderay', '~> 1.1'
  gem 'guard', '~> 2.14'
  gem 'guard-bundler', '~> 2.1'
  gem 'guard-livereload', '~> 2.5'
  gem 'guard-rake', '~> 1.0'
  gem 'guard-rubocop', '~> 1.3'
  gem 'mdl', '~> 0.3'
  gem 'metadata-json-lint', '~> 2.0'
  gem 'overcommit', '~> 0.41'
  gem 'parallel_tests', '~> 2.13'
  gem 'puppetlabs_spec_helper', '~> 2.0'
  gem 'rake', '~> 12.2'
  gem 'rspec-puppet-facts', '~> 1.7'
  gem 'rubocop', '~> 0.51'
  gem 'semantic_puppet' if puppetversion.to_f < 4.9
  gem 'simplecov', '~> 0.13'
  gem 'simplecov-murmur', '~> 0.8'
end

group :acceptance_testing do
  gem 'beaker', '~> 3.27'
  gem 'beaker-rspec', '~> 6.2'
end

group :ci do
  gem 'codeclimate-test-reporter', '~> 1.0'
end

group :documentation do
  gem 'puppet-strings', '~> 1.1'
  gem 'redcarpet', '~> 3.4'
  gem 'rgen', '~> 0.8'
end

group :release do
  gem 'github_api', '~> 0.18'
  gem 'puppet-blacksmith', '~> 4.0'
end

group :metatools do
  gem 'github-linguist', '~> 6.0'
  gem 'travis', '~> 1.8'
end
