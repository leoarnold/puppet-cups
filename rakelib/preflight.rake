desc 'Preflight checks before building the module'
task :preflight do
  raise 'Please redact README.md first!' if File.readlines("README.md").grep(/release:exclude/).size > 0
end

task build: :preflight
