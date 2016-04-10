# encoding: UTF-8
require 'pathname'
require 'uri'

Puppet::Type.newtype(:cups_queue) do
  @doc = "Installs and manages CUPS queues.

    Printers: Minimal manifest examples

        cups_queue { 'MinimalRaw':
          ensure => 'printer',
          uri    => 'lpd://192.168.2.105/binary_p1'
        }

      OR

        cups_queue { 'MinimalModel':
          ensure => 'printer',
          model  => 'drv:///sample.drv/generic.ppd',
          uri    => 'lpd://192.168.2.105/binary_p1'
        }

        The command `lpinfo -m` lists all models available on the node.

      OR

        cups_queue { 'MinimalPPD':
          ensure => 'printer',
          ppd    => '/usr/share/cups/model/myprinter.ppd',
          uri    => 'lpd://192.168.2.105/binary_p1'
        }

      OR

        cups_queue { 'MinimalInterface':
          ensure    => 'printer',
          interface => '/usr/share/cups/model/myprinter.sh',
          uri       => 'lpd://192.168.2.105/binary_p1'
        }

    Classes: Providing only the mandatory attributes

        cups_queue { 'MinimalClass':
          ensure  => 'class',
          members => ['Office', 'Warehouse']
        }

    Note that configurable options of a class are those of its first member."

  validate do
    case should(:ensure)
    when :class
      raise('Please provide a non-empty array of member printers.') unless (should(:members).is_a? Array) && !should(:members).empty?
      raise('Classes do NOT support the following attributes: `model`, `ppd`, `interface`, `make_and_model`, `uri`') \
        if value(:model) || value(:ppd) || value(:interface) || should(:make_and_model) || should(:uri)
    when :printer
      raise('The attributes `interface`, `model` and `ppd` are mutually exclusive. Please specify at most one of them.') \
        if [value(:interface).nil?, value(:model).nil?, value(:ppd).nil?].count(false) > 1
      raise('Printers do not support the attribute `members`.') if should(:members)
    end
  end

  autorequire(:cups_queue) do
    should(:members)
  end

  autorequire(:file) do
    answer = ['lpoptions']
    answer << value(:interface) if value(:interface)
    answer << value(:ppd) if value(:ppd)
    answer
  end

  newproperty(:ensure) do
    desc '(mandatory) Specifies whether this queue should be a `class`, a `printer` or `absent`.'

    newvalue(:class) do
      provider.create_class unless provider.class_exists?
    end

    newvalue(:printer) do
      provider.create_printer unless provider.printer_exists?
    end

    newvalue(:absent) do
      provider.destroy
    end

    def change_to_s(currentvalue, newvalue)
      return "created a #{should_to_s(newvalue)}" if currentvalue == :absent || currentvalue.nil?
      return "removed a #{is_to_s(currentvalue)}" if newvalue == :absent
      return "changed from #{is_to_s(currentvalue)} to #{should_to_s(newvalue)}"
    rescue Puppet::Error, Puppet::DevError
      raise
    rescue => detail
      raise Puppet::DevError, "Could not convert change #{name} to string: #{detail}", detail.backtrace
    end
  end

  newparam(:name) do
    desc '(mandatory) CUPS queue names are case insensitive and may contain any printable character except SPACE, TAB, "/", or "#".'

    validate do |name|
      raise ArgumentError, 'CUPS queue names may NOT contain the characters SPACE, TAB, "/", or "#".' if name =~ %r{[\s/#]}
    end
  end

  newproperty(:accepting) do
    desc 'Boolean value specifying whether the queue should accept print jobs or reject them.'

    newvalues(:true, :false)
  end

  newproperty(:access) do
    desc 'Manages queue access control. Takes a hash with keys `policy` and `users`.' \
      ' The `allow` policy restricts access to the `users` provided,' \
      ' while the `deny` policy lets everybody except the specified `users` submit jobs.' \
      ' The `users` are provided as a non-empty array of Unix group names (prefixed with an `@`) and Unix user names.'

    validate do |value|
      raise ArgumentError, 'Please provide a hash value.' unless value.is_a?(Hash)
      raise ArgumentError, 'Please provide a hash with both keys `policy` and `users`.' unless value.keys.sort == %w(policy users).sort
      raise ArgumentError, "The value 'policy => #{value['policy']}' is unsupported. Valid values are 'allow' and 'deny'." \
        if value.key?('policy') && !%(allow, deny).include?(value['policy'])
      raise ArgumentError, 'Please provide a non-empty array of user names.' unless value['users'].is_a?(Array) && !value['users'].empty?
      value['users'].each do |name|
        raise ArgumentError, "The user or group name '#{name}' seems malformed" unless name =~ /\A@?[\w\-]+\Z/
      end
    end

    munge do |value|
      value['users'] = value['users'].sort.uniq
      value
    end
  end

  newproperty(:description) do
    desc 'A short informative description of the queue.'

    validate do |value|
      raise ArgumentError, "The 'description' must be a string." unless value.is_a? String
    end
  end

  newproperty(:enabled) do
    desc 'Boolean value specifying whether the queue should be running or stopped.'

    newvalues(:true, :false)
  end

  newproperty(:held) do
    desc 'A held queue will print all jobs in print or pending, but all new jobs will be held. Setting `false` will release them.'

    newvalues(:true, :false)
  end

  newparam(:interface) do
    desc '(printer-only) The absolute path to a System V interface script on the node.' \
      ' If the catalog contains a `file` resource with this path as title, it will automatically be required.'

    validate do |value|
      raise("The absolute local file path '#{value}' seems malformed.") unless Pathname(value).absolute?
    end
  end

  newproperty(:location) do
    desc 'A short information where to find the hardcopies.'

    validate do |value|
      raise ArgumentError, "The 'location' must be a string." unless value.is_a? String
    end
  end

  newproperty(:make_and_model) do
    desc '(printer-only) This value is used for driver updates and changes.' \
      " Matches the `NickName` (fallback `ModelName`) value from the printer's PPD file" \
      ' if the printer was installed using a PPD file or a model,' \
      ' and `Local System V Printer` or `Local Raw Printer` otherwise.'

    validate do |value|
      raise ArgumentError, "The 'make_and_model' must be a string." unless value.is_a? String
    end
  end

  newproperty(:members, array_matching: :all) do
    desc '(class-only, mandatory) A non-empty array with the names of CUPS queues.' \
      ' The class will be synced to contain only these members in the given order.' \
      ' If the catalog contains `cups_queue` resources for these queues, they will be required automatically.'

    validate do |value|
      raise ArgumentError, 'The list of members must not be empty.' if value.empty?
      raise ArgumentError, 'CUPS queue names may NOT contain the characters SPACE, TAB, "/", or "#".' if value =~ %r{[\s/#]}
    end
  end

  newparam(:model) do
    desc '(printer-only) A supported printer model. Use `lpinfo -m` on the node to list all models available.'

    validate do |value|
      raise ArgumentError, "The 'model' must be a string." unless value.is_a? String
    end
  end

  newproperty(:options) do
    desc 'A hash of options (as keys) and their target value.' \
      ' Use `lpoptions -p [queue_name] -l` on the node for a list of all options available for the queue and their supported values.'

    validate do |value|
      raise ArgumentError, 'Please provide a hash value.' unless value.is_a? Hash

      properties = {
        'printer-is-accepting-jobs' => 'accepting',
        'printer-info' => 'description',
        'printer-state' => 'enabled',
        'printer-location' => 'location',
        'printer-is-shared' => 'shared',
        'device-uri' => 'uri'
      }

      value.keys.each do |key|
        if properties.key? key
          raise ArgumentError, "Please use the `cups_queue` property '#{properties[value]}' instead of setting the option '#{value}'."
        end
      end
    end
  end

  newparam(:ppd) do
    desc '(printer-only) The absolute path to a PPD file on the node.' \
      ' If the catalog contains a `file` resource with this path as title, it will automatically be required.' \
      ' The recommended location for your PPD files is `/usr/share/cups/model/` or `/usr/local/share/cups/model/`.'

    validate do |value|
      raise("The absolute local file path '#{value}' seems malformed.") unless Pathname(value).absolute?
    end
  end

  newproperty(:shared) do
    desc 'Boolean value specifying whether to share this queue on the network. Default is `false`.'

    newvalues(:true, :false)
    defaultto(:false)
  end

  newproperty(:uri) do
    desc '(printer-only) The device URI of the printer. Use `lpinfo -v` on the node to scan for printer URIs.'

    validate do |value|
      raise ArgumentError, "The URI '#{value}' seems malformed." unless (value =~ URI.regexp) || Pathname(value).absolute?
    end
  end
end
