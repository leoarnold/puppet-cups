require_relative '../../../puppet_x/cups/instances'
require_relative '../../../puppet_x/cups/queue'

Puppet::Type.type(:cups_queue).provide(:cups) do
  @doc = 'Installs and manages CUPS queues.'

  commands(cupsaccept: 'cupsaccept')
  commands(cupsdisable: 'cupsdisable')
  commands(cupsenable: 'cupsenable')
  commands(cupsreject: 'cupsreject')
  commands(ipptool: 'ipptool') # Used in PuppetX::Cups::Ipp module. Declared here for Puppet's provider suitability mechanism
  commands(lpadmin: 'lpadmin')
  commands(lpoptions: 'lpoptions')

  ### Static provider methods

  def self.instances
    providers = []
    # Discover class instances
    PuppetX::Cups::Instances.classmembers.each do |classname, membernames|
      providers << new(name: classname, ensure: :class, members: membernames)
    end
    # Discover printer instances
    PuppetX::Cups::Instances.printers.each do |printername|
      providers << new(name: printername, ensure: :printer)
    end
    providers
  end

  def self.prefetch(specified)
    discovered = instances
    specified.each_key do |name|
      provider = discovered.find { |instance| instance.name == name }
      specified[name].provider = provider if provider
    end
  end

  ### Existence

  def class_exists?
    @property_hash[:ensure] == :class
  end

  def printer_exists?
    @property_hash[:ensure] == :printer
  end

  def queue_exists?
    class_exists? || printer_exists?
  end

  ### Creation and destruction

  def create_class
    # The queue might be present as a printer
    destroy

    resource.should(:members).each do |member|
      lpadmin('-E', '-p', member, '-c', name)
    end

    run_property_setter(:access, :description, :location, :options, :shared,
                        :enabled, :held, :accepting)
  end

  def create_printer
    # The queue might be present as a class
    destroy

    # Create a minimal raw queue first, then adapt it
    lpadmin('-E', '-p', name, '-v', 'file:///dev/null')

    run_parameter_setter(:model, :ppd)

    run_property_setter(:uri,
                        :access, :description, :location, :options, :shared,
                        :enabled, :held, :accepting)

    check_make_and_model
  end

  def run_parameter_setter(*parameters)
    parameters.each do |parameter|
      run_attribute_setter(parameter, resource.value(parameter))
    end
  end
  private :run_parameter_setter

  def run_property_setter(*properties)
    properties.each do |property|
      run_attribute_setter(property, resource.should(property))
    end
  end
  private :run_property_setter

  def run_attribute_setter(attribute, target_value)
    method(attribute.to_s + '=').call(target_value) if target_value
  end
  private :run_attribute_setter

  def destroy
    lpadmin('-E', '-x', name) if queue_exists?
  end

  ### Property getters and setters

  def ensure
    prefetched = @property_hash[:ensure]
    prefetched ? prefetched : :absent
  end

  def accepting
    query('printer-is-accepting-jobs')
  end

  def accepting=(value)
    if value == :true
      cupsaccept('-E', name)
    else
      cupsreject('-E', name)
    end
  end

  def access
    policy = (query_users('denied').empty? ? 'allow' : 'deny')

    { 'policy' => policy, 'users' => users_is }
  end

  def access=(value)
    lpadmin('-E', '-p', name, '-u', value['policy'] + ':' + value['users'].join(','))
  end

  def description
    query('printer-info')
  end

  def description=(value)
    lpadmin('-E', '-p', name, '-D', value)
  end

  def enabled
    query('printer-state') == 'stopped' ? :false : :true
  end

  def enabled=(value)
    if value == :true
      while_root_allowed { cupsenable('-E', name) }
    else
      cupsdisable('-E', name)
    end
  end

  def held
    query('printer-state-reasons') =~ /hold-new-jobs/ ? :true : :false
  end

  def held=(value)
    if value == :true
      cupsdisable('-E', '--hold', name)
    else
      cupsenable('-E', '--release', name)
    end
  end

  def location
    query('printer-location')
  end

  def location=(value)
    lpadmin('-E', '-p', name, '-L', value)
  end

  def make_and_model
    query('printer-make-and-model') if printer_exists?
  end

  def make_and_model=(_value)
    create_printer
    check_make_and_model
  end

  def model=(value)
    lpadmin('-E', '-p', name, '-m', value)
  end

  def members
    prefetched = @property_hash[:members]
    prefetched if prefetched
  end

  def members=(_value)
    create_class
  end

  def options
    options_should = resource.should(:options)
    options_should.nil? ? supported_options_is : specified_options_is(options_should)
  end

  def options=(options_should)
    options_should.each do |key, value|
      lpadmin('-E', '-p', name, '-o', "#{key}=#{value}")
    end
  end

  def ppd=(value)
    lpadmin('-E', '-p', name, '-P', value)
  end

  def shared
    query('printer-is-shared')
  end

  def shared=(value)
    lpadmin('-E', '-p', name, '-o', "printer-is-shared=#{value}")
  end

  def uri
    query('device-uri') if printer_exists?
  end

  def uri=(value)
    lpadmin('-E', '-p', name, '-v', value)
  end

  private

  def query(property)
    PuppetX::Cups::Queue.attribute(name, property)
  end

  def check_make_and_model
    actual = query('printer-make-and-model')
    expected = resource.should(:make_and_model)

    raise "Cannot set make_and_model to '#{expected}' for queue '#{name}'. Please revise the value you provided for 'model' or 'ppd'." \
      if expected && (actual != expected)
  end

  ### Helper functions for #options

  # @private
  #
  # Extracts the values of the specified options from {supported_options_is}
  #
  # @param options_should [Hash] A hash of queue options and their target values
  #
  # @return [Hash] A hash of queue options and their current values
  #
  # @raise Raises an error when an unsupported option was specified
  def specified_options_is(options_should)
    answer = {}

    options_should.each_key do |key|
      raise("Managing the option '#{key}' is unsupported.") unless supported_options_is.key? key
      answer[key] = supported_options_is[key]
    end

    answer
  end

  # @private
  #
  # Merges the hashes {native_options_is} and {vendor_options_is}
  #
  # @return [Hash] A hash of all supported options and their current values
  def supported_options_is
    native_options_is.merge(vendor_options_is)
  end

  # @private
  #
  # All options provided to every queue by CUPS
  #
  # @return [Hash] A hash of all native CUPS queue options and their current values
  def native_options_is
    answer = {}

    options = %w[
      auth-info-required job-k-limit job-page-limit job-quota-period
      job-sheets-default port-monitor printer-error-policy printer-op-policy
    ]

    options.each { |option| answer[option] = query_native_option(option) }

    answer
  end

  # @private
  #
  # Queries the native option and sanitizes the result where necessary
  #
  # @return [String] The sanitized option value
  def query_native_option(option)
    value = query(option)

    if option == 'auth-info-required'
      # Related issue: https://github.com/apple/cups/issues/4958
      value = 'none' if value.empty?
    end

    value
  end

  # @private
  #
  # Parses the output of `lpoptions -p [queue_name] -l`
  #
  # @return [Hash] All vendor options and their current values
  def vendor_options_is
    answer = {}

    lpoptions('-E', '-p', name, '-l').each_line do |line|
      result = %r{\A(?<key>\w+)/(.*):(.*)\*(?<value>\w+)}.match(line)
      answer[result[:key]] = result[:value] if result
    end

    answer
  end

  ### Helper functions for #access

  # @private
  #
  # Determines the names of users and groups currently allowed / denied to use the queue.
  # The result is only meaningful in conjuntion with {access} policy,
  #
  # @return [Array] The names of all groups (prefixed by `@`) and users currently allowed / denied to use the queue.
  def users_is
    users_allowed = query_users('allowed')
    users_denied = query_users('denied')

    if !users_allowed.empty?
      users_allowed
    elsif !users_denied.empty?
      users_denied
    else
      ['all']
    end
  end

  # @private
  #
  # Queries the names of users and groups currently allowed or denied to use the queue.
  #
  # @param [String] `allowed` or `denied`
  #
  # @return [Array] The names of all groups (prefixed by `@`) and users currently allowed / denied to use the queue.
  def query_users(status)
    names = query("requesting-user-name-#{status}")
    names.gsub(/[\'\"]/, '').split(',').sort.uniq if names
  end

  # @private
  #
  # Determines the names of users and groups which should be allowed / denied to use the queue.
  #
  # @return [Array] The names of all groups (prefixed by `@`) and users which should allowed / denied to use the queue.
  def users_should
    resource.should(:access).nil? ? [] : resource.should(:access)['users']
  end

  # @private
  #
  # Sometimes the `root` user is not considered a privileged user in CUPS
  # This shim temporarily grants `root` access to the given queue
  # and then (re)establishes the desired access control.
  #
  # @see https://github.com/apple/cups/issues/4781
  #
  # @yield The command to be executed as root user
  def while_root_allowed
    acl = (resource.should(:access) ? resource.should(:access) : access)
    debug("CUPS #4781: Temporarily allowing 'root' user to access the queue.")
    self.access = { 'policy' => 'allow', 'users' => ['root'] }
    yield
    debug('CUPS #4781: (Re)establishing desired access control.')
    self.access = acl
  end
end
