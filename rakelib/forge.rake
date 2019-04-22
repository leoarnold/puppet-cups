require_relative 'forge_module'

namespace :forge do
  desc 'Preflight checks before release'
  task :release? do
    unless FORGE_MODULE.candidate[:title] =~ /\b#{FORGE_MODULE.candidate[:version]}\b/
      puts "Could not find CHANGELOG entries for release #{FORGE_MODULE.candidate[:version]}"
      exit(1)
    end
  end

  desc 'Release module on the Puppet forge'
  task release: %i[travis:release? module:push]

  desc 'List all versions of this module already published on the Puppet Forge'
  task :releases do
    puts FORGE_MODULE.releases
  end
end
