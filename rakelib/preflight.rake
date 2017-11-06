desc 'Preflight checks before building the module'
task :preflight do
  raise 'Please redact README.md first!' unless File.readlines('README.md').grep(/release:exclude/).empty?
end

task build: :preflight
