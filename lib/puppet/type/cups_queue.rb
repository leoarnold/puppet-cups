require 'uri'

Puppet::Type.newtype(:cups_queue) do
  @doc = "Installs and manages CUPS queues.

    Printers: Using a minimal manifest

        cups_queue { 'MinimalRaw':
          ensure => 'printer',
          uri    => 'lpd://192.168.2.105/binary_p1' # Replace with your printer's URI
        }

      OR

        cups_queue { 'MinimalModel':
          ensure => 'printer',
          model  => 'drv:///sample.drv/generic.ppd',
          uri    => 'lpd://192.168.2.105/binary_p1' # Replace with your printer's URI
        }

        The command `lpinfo -m` lists all models available on the node.

      OR

        cups_queue { 'MinimalPPD':
          ensure => 'printer',
          ppd    => '/usr/share/cups/model/myprinter.ppd',
          uri    => 'lpd://192.168.2.105/binary_p1' # Replace with your printer's URI
        }

      OR

        cups_queue { 'MinimalInterface':
          ensure    => 'printer',
          interface => '/usr/share/cups/model/myprinter.sh',
          uri       => 'lpd://192.168.2.105/binary_p1' # Replace with your printer's URI
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
      fail('Please provide a non-empty array of member printers.') unless (should(:members).is_a? Array) && !should(:members).empty?
      fail('Classes do NOT support the following attributes: `model`, `ppd`, `interface`, `uri`') \
        if value(:model) || value(:ppd) || value(:interface) || should(:make_and_model) || should(:uri)
    when :printer
      fail("The attributes 'interface', 'model' and 'ppd' are mutually exclusive. Please specify at most one of them.") \
        if [value(:interface).nil?, value(:model).nil?, value(:ppd).nil?].count(false) > 1
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

  autorequire(:file) do
    answer = ['/etc/cups/lpoptions']
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
    desc 'Boolean value specifying whether the queue should accept print jobs or reject them.'

    newvalues(:true, :false)
  end

  newproperty(:description) do
    desc 'A short informative description of the queue.'

    validate do |value|
      fail ArgumentError, "The 'description' must be a string." unless value.is_a? String
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
      fail("The absolute local file path '#{value}' seems malformed.") unless URI(value).path == value
    end
  end

  newproperty(:location) do
    desc 'A short information where to find the hardcopies.'

    validate do |value|
      fail ArgumentError, "The 'location' must be a string." unless value.is_a? String
    end
  end

  newproperty(:make_and_model) do
    desc '(printer-only) This value is used for driver updates and changes.' \
      " Matches the `NickName` (fallback `ModelName`) value from the printer's PPD file" \
      ' if the printer was installed using a PPD file or a model,' \
      ' and `Local System V Printer` or `Local Raw Printer` otherwise.'

    validate do |value|
      fail ArgumentError, "The 'make_and_model' must be a string." unless value.is_a? String
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
  end

  newparam(:model) do
    desc '(printer-only) A supported printer model. Use `lpinfo -m` on the node to list all models available.'

    validate do |value|
      fail ArgumentError, "The 'model' must be a string." unless value.is_a? String
    end
  end

  newproperty(:options) do
    desc 'A hash of options (as keys) and their target value.' \
      ' Use `lpoptions -p [queue_name] -l` on the node for a list of all options available for the queue and their supported values.'

    validate do |value|
      fail ArgumentError, 'Please provide a hash value.' unless value.is_a? Hash

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
          fail ArgumentError, "Please use the `cups_queue` property '#{properties[value]}' instead of setting the option '#{value}'."
        end
      end
    end
  end

  newparam(:ppd) do
    desc '(printer-only) The absolute path to a PPD file on the node.' \
      ' If the catalog contains a `file` resource with this path as title, it will automatically be required.' \
      ' The recommended location for your PPD files is `/usr/share/cups/model/` or `/usr/local/share/cups/model/`.'

    validate do |value|
      fail("The absolute local file path '#{value}' seems malformed.") unless URI(value).path == value
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
