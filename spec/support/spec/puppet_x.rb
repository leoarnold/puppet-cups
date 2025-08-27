# frozen_string_literal: true

# Make Puppet eXtension modules available
Dir["#{__dir__}/../../../lib/puppet_x/**/*.rb"].sort.each do |file|
  require file
end
