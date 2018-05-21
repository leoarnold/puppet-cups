require_relative 'forge_module'

namespace :travis do
  desc 'Validate the Travis CI config file'
  task :lint do
    system('travis lint')
  end

  desc 'Perform all static code analysis checks'
  task ci: %i[release_checks mdl]

  desc 'Preflight checks before deployments'
  task :deploy? do
    unless FORGE_MODULE.candidate[:title] =~ /\b#{FORGE_MODULE.candidate[:version]}\b/
      puts "Could not find CHANGELOG entries for release #{FORGE_MODULE.candidate[:version]}"
      exit(1)
    end
  end
end
