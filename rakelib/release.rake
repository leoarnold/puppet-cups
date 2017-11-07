desc 'Run all checks and release the module on the Puppet Forge and Github'
task release: [:release_checks, 'github:pages:publish', 'github:release', 'module:push']
