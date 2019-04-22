require_relative 'forge_module'

namespace :travis do
  desc 'Validate the Travis CI config file'
  task :lint do
    system('travis lint')
  end

  desc 'Perform all static code analysis checks'
  task ci: %i[release_checks mdl]
end
