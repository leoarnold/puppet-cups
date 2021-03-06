# frozen_string_literal: true

require 'shellwords'

require 'beaker'
require 'beaker-puppet'
require 'beaker-rspec'

# Beaker related configuration
# http://www.rubydoc.info/github/puppetlabs/beaker/Beaker/DSL
RSpec.configure do |c|
  project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  c.before(:suite) do
    hosts.each do |host|
      shell("sed -i 's/^nameserver.*/nameserver 8.8.8.8/' /etc/resolv.conf")
      install_puppet_agent_on(host, puppet_collection: 'puppet6')
      install_puppet_module_via_pmt_on(host, module_name: 'camptocamp-systemd', version: '1.0.0')
      copy_module_to(host, module_name: 'cups', source: project_root, target_module_path: '/etc/puppetlabs/code/modules')
      scp_to(host, File.join(project_root, 'spec/fixtures/ppd/textonly.ppd'), '/tmp/')
    end
  end
end

# Custom helper functions

def ensure_cups_is_running
  apply_manifest('class { "cups": }', catch_failures: true)
end

def add_printers(*names)
  names.each do |name|
    shell("lpadmin -p #{Shellwords.escape(name)} -m drv:///sample.drv/generic.ppd -o printer-is-shared=false")
  end
end

def add_printers_to_classes(class_members)
  add_printers('Dummy')
  class_members.each_key do |classname|
    members = class_members[classname]
    members = %w[Dummy] if members.empty?
    members.each do |printername|
      shell("lpadmin -p #{Shellwords.escape(printername)} -c #{Shellwords.escape(classname)}")
    end
    shell("lpadmin -p #{Shellwords.escape(classname)} -o printer-is-shared=false")
  end
  remove_queues('Dummy')
end

def remove_queues(*names)
  names.flatten.each do |name|
    shell("lpadmin -x #{Shellwords.escape(name)}", acceptable_exit_codes: [0, 1])
  end
end

def purge_all_queues
  request = '{
    OPERATION CUPS-Get-Printers
    GROUP operation
    ATTR charset attributes-charset utf-8
    ATTR language attributes-natural-language en
    DISPLAY printer-name
  }'
  result = shell('ipptool -t ipp://localhost/ /dev/stdin', stdin: request, acceptable_exit_codes: [0, 1])
  queues = result.stdout.scan(%r{printer-name \(nameWithoutLanguage\) = ([^\s"'\\,#/]+)})
  remove_queues(queues)
end
