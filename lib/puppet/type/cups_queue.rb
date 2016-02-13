require 'uri'

Puppet::Type.newtype(:cups_queue) do
  @doc = "Installs and manages CUPS queues.

    Printers: Providing only the mandatory attributes

        cups_queue { 'MinimalPrinter':
          ensure => 'printer',
          model  => 'drv:///sample.drv/generic.ppd'
        }

    The command `lpinfo -m` lists all models available on the node.

    Classes: Providing only the mandatory attributes

        cups_queue { 'MinimalClass':
          ensure  => 'class',
          members => ['Office', 'Warehouse']
        }

    Note that configurable options of a class are those of its first member."

  validate do
    case should(:ensure)
    when :class
      fail('Please provide a non-empty array of member printers.') unless (should(:members).is_a? Array) && !should(:members).empty?
      fail('Classes do NOT support the following attributes: `model`, `uri`') if value(:model) || should(:uri)
    when :printer
      fail('Please provide a printer model.') unless value(:model)
      fail('Printers do not support the parameter `members`.') if should(:members)
    end
  end

  autorequire(:class) do
    'cups'
  end

  autorequire(:package) do
    ['cups', 'cups-ipptool']
  end

  autorequire(:service) do
    'cups'
  end

  autorequire(:cups_queue) do
    should(:members)
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

    newvalue(:unspecified) do
      fail("Please specify a value for 'ensure'.")
    end

    defaultto(:unspecified)

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
      fail ArgumentError, 'CUPS queue names may NOT contain the characters SPACE, TAB, "/", or "#".' if name =~ %r{[\s/#]}
    end
  end

  newproperty(:accepting) do
    desc 'Boolean value specifying whether the queue should accept print jobs or reject them. Default is `true`.'

    newvalues(:true, :false)
    defaultto(:true)
  end

  newproperty(:description) do
    desc 'A short informative description of the queue.'

    validate do |value|
      fail ArgumentError, "The 'description' must be a string." unless value.is_a? String
    end
  end

  newproperty(:enabled) do
    desc 'Boolean value specifying whether the queue should be running or stopped. Default is `true`.'

    newvalues(:true, :false)
    defaultto(:true)
  end

  newproperty(:location) do
    desc 'A short information where to find the hardcopies.'

    validate do |value|
      fail ArgumentError, "The 'location' must be a string." unless value.is_a? String
    end
  end

  newproperty(:members, array_matching: :all) do
    desc '(class-only, mandatory) A non-empty array with the names of CUPS queues.' \
      ' The class will be synced to contain only these members in the given order.' \
      ' If the catalog contains `cups_queue` resources for these queues, they will be required automatically.'

    validate do |value|
      fail ArgumentError, 'The list of members must not be empty.' if value.length == 0
      fail ArgumentError, 'CUPS queue names may NOT contain the characters SPACE, TAB, "/", or "#".' if value =~ %r{[\s/#]}
    end

    def should_to_s(newvalue)
      is_to_s(newvalue)
    end
  end

  newparam(:model) do
    desc '(printer-only, mandatory) A supported printer model. Use `lpinfo -m` on the node to list all models available.'

    validate do |value|
      fail ArgumentError, "The 'model' must be a string." unless value.is_a? String
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
      fail ArgumentError, "The URI '#{value}' seems malformed." unless (value =~ URI.regexp) || (value == URI(value).path)
    end
  end
end
