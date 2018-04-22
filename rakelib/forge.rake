require_relative 'forge_module'

namespace :forge do
  desc 'List all versions of this module already published on the Puppet Forge'
  task :releases do
    puts FORGE_MODULE.releases
  end
end
