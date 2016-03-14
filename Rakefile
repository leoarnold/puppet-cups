require 'puppetlabs_spec_helper/rake_tasks'
require 'rspec-puppet/rake_task'

require 'rubocop/rake_task'
RuboCop::RakeTask.new

if RUBY_VERSION.to_f >= 2.0
  require 'reek/rake/task'
  Reek::Rake::Task.new do |t|
    t.fail_on_error = false
  end
end
