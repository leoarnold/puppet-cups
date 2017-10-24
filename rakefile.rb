require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'
require 'rspec-puppet/rake_task'

require 'rubocop/rake_task'
RuboCop::RakeTask.new

desc 'Check style of MarkDown documents'
task :mdl do
  Dir['*.md', '.github/**/*.md', 'examples/**/*.md'].each do |document|
    sh "mdl -s .mdl/style.rb #{document}"
  end
end

desc 'Perform all static code analysis checks'
task static_checks: %i[release_checks mdl]
