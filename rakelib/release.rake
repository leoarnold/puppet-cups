desc 'Run all checks and release the module on the Puppet Forge and Github'
task release: ['travis:ci', 'github:pages:publish', 'github:release', 'module:push']
