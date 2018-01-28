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

    Classes: Providing only the mandatory attributes

        cups_queue { 'MinimalClass':
          ensure  => 'class',
          members => ['Office', 'Warehouse']
        }

    Note that configurable options of a class are those of its first member."

  validate do
    case should(:ensure)
    when :class
      validate_class_attributes
      validate_class_members
    when :printer
      validate_printer_attributes
      validate_printer_creation
    end
  end

  def validate_class_attributes
    raise('Classes do NOT support the following attributes: `model`, `ppd`, `make_and_model`, `uri`') \
      if value(:model) || value(:ppd) || should(:make_and_model) || should(:uri)
  end
  private :validate_class_attributes

  def validate_class_members
    raise('Please provide a non-empty array of member printers.') unless (should(:members).is_a? Array) && !should(:members).empty?
  end
  private :validate_class_members

  def validate_printer_attributes
    raise('Printers do not support the attribute `members`.') if should(:members)
  end
  private :validate_printer_attributes

  def validate_printer_creation
    raise('The attributes `model` and `ppd` are mutually exclusive. Please specify at most one of them.') if value(:model) && value(:ppd)
  end
  private :validate_printer_creation

  autorequire(:cups_queue) do
    should(:members)
  end

  autorequire(:file) do
    answer = ['/etc/cups/lpoptions']
    answer << value(:ppd) if value(:ppd)
    answer << "/usr/share/cups/model/#{value(:model)}" if value(:model)
    answer
  end

  autorequire(:service) do
    'cups'
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
      provider.destroy if provider.queue_exists?
    end

    def change_to_s(currentvalue, newvalue)
      return "created a #{should_to_s(newvalue)}" if currentvalue == :absent || currentvalue.nil?
      return "#{is_to_s(currentvalue)} removed" if newvalue == :absent
      "changed from #{is_to_s(currentvalue)} to #{should_to_s(newvalue)}"
    end

    def is_to_s(value) # rubocop:disable Naming/PredicateName
      value.to_s
    end

    def should_to_s(value)
      value.to_s
    end
  end

  newparam(:name) do
    desc '(mandatory) Queue names may contain any printable character except SPACES, TABS, (BACK)SLASHES, QUOTES, COMMAS or "#".'

    validate do |name|
      raise ArgumentError, 'Queue names may NOT contain SPACES, TABS, (BACK)SLASHES, QUOTES, COMMAS or "#".' if name =~ %r{[\s\"\'\\,#/]}
    end
  end

  newproperty(:accepting) do
    desc 'Boolean value specifying whether the queue should accept print jobs or reject them.'

    newvalues(:true, :false)
  end

  newproperty(:access) do
    desc 'Manages queue access control. Takes a hash with keys `policy` and `users`.
      The `allow` policy restricts access to the `users` provided,
      while the `deny` policy lets everybody except the specified `users` submit jobs.
      The `users` are provided as a non-empty array of Unix group names (prefixed with an `@`) and Unix user names.'

    validate do |value|
      raise ArgumentError, 'Please provide a hash value.' unless value.is_a?(Hash)
      raise ArgumentError, 'Please provide a hash with both keys `policy` and `users`.' unless value.keys.sort == %w[policy users].sort
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

    def is_to_s(value) # rubocop:disable Naming/PredicateName
      value.to_s
    end

    def should_to_s(value)
      value.to_s
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

  newproperty(:location) do
    desc 'A short information where to find the hardcopies.'

    validate do |value|
      raise ArgumentError, "The 'location' must be a string." unless value.is_a? String
    end
  end

  newproperty(:make_and_model) do
    desc "(printer-only) This value is used for driver updates and changes.
      Matches the `NickName` (fallback `ModelName`) value from the printer's PPD file
      if the printer was installed using a PPD file or a model,
      and `Local System V Printer` or `Local Raw Printer` otherwise."

    validate do |value|
      raise ArgumentError, "The 'make_and_model' must be a string." unless value.is_a? String
    end
  end

  newproperty(:members, array_matching: :all) do
    desc '(class-only, mandatory) A non-empty array with the names of CUPS queues.
      The class will be synced to contain only these members in the given order.
      If the catalog contains `cups_queue` resources for these queues, they will be required automatically.'

    validate do |value|
      raise ArgumentError, 'The list of members must not be empty.' if value.empty?
      raise ArgumentError, 'CUPS queue names may NOT contain the characters SPACE, TAB, "/", or "#".' if value =~ %r{[\s/#]}
    end

    def is_to_s(value) # rubocop:disable Naming/PredicateName
      value.to_s
    end

    def should_to_s(value)
      value.to_s
    end
  end

  newparam(:model) do
    desc '(printer-only) A supported printer model. Use `lpinfo -m` on the node to list all models available.'

    validate do |value|
      raise ArgumentError, "The 'model' must be a string." unless value.is_a? String
    end
  end

  newproperty(:options) do
    desc 'A hash of options (as keys) and their target value. Almost every option you can set with
      `lpadmin -p [queue_name] -o key=value` is supported here. Use `puppet resource cups_queue [queue_name]`
      on the node for a list of all supported options for the given queue, and `lpoptions -p [queue_name] -l`
      to see a list of available values for the most commonly used printer specific options.'

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

      value.each_key do |key|
        if properties.key? key
          raise ArgumentError, "Please use the `cups_queue` property '#{properties[value]}' instead of setting the option '#{value}'."
        end
      end
    end

    def is_to_s(currentvalue) # rubocop:disable Naming/PredicateName
      currentvalue.sort.to_h.to_s
    end

    def should_to_s(newvalue)
      newvalue.sort.to_h.to_s
    end
  end

  newparam(:ppd) do
    desc '(printer-only) The absolute path to a PPD file on the node.
      If the catalog contains a `file` resource with this path as title, it will automatically be required.
      The recommended location for your PPD files is `/usr/share/cups/model/` or `/usr/local/share/cups/model/`.'

    validate do |value|
      raise ArgumentError, "The absolute local file path '#{value}' seems malformed." unless Pathname(value).absolute?
      raise ArgumentError, "Putting your PPD files into '/etc/cups/ppd/' is error prone. Please use '/usr/share/cups/model/' instead." \
        if Pathname(value).dirname.to_s =~ %r{\A/etc/cups/ppd}
    end
  end

  newproperty(:shared) do
    desc 'Boolean value specifying whether to share this queue on the network.'

    newvalues(:true, :false)
  end

  newproperty(:uri) do
    desc '(printer-only) The device URI of the printer. Use `lpinfo -v` on the node to scan for printer URIs.'

    validate do |value|
      raise ArgumentError, "The URI '#{value}' seems malformed." unless (value =~ URI::DEFAULT_PARSER.make_regexp) || Pathname(value).absolute?
    end
  end
end
