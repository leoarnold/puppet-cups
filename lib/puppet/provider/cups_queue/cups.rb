require_relative '../../../cups_helper.rb'

Puppet::Type.type(:cups_queue).provide(:cups) do
  @doc = 'Installs and manages CUPS printer queues.'

  commands(cupsaccept: 'cupsaccept')
  commands(cupsdisable: 'cupsdisable')
  commands(cupsenable: 'cupsenable')
  commands(cupsreject: 'cupsreject')
  commands(ipptool: 'ipptool') # Used in cups_helper. Declared here for Puppet's provider suitability mechanism
  commands(lpadmin: 'lpadmin')

  ### Static provider methods

  def self.instances
    providers = []
    Facter.value(:cups_classmembers).each do |classname, membernames|
      providers << new(name: classname, ensure: :class, members: membernames)
    end
    Facter.value(:cups_printers).each do |printername|
      providers << new(name: printername, ensure: :printer)
    end
    providers
  end

  def self.prefetch(specified)
    discovered = instances
    specified.keys.each do |name|
      provider = discovered.find { |instance| instance.name == name }
      specified[name].provider = provider if provider
    end
  end

  ### Existence

  def class_exists?
    Facter.value(:cups_classes).include? name
  end

  def printer_exists?
    Facter.value(:cups_printers).include? name
  end

  ### Creation and destruction

  def create_class
    resource.should(:members).each { |member| lpadmin('-E', '-p', member, '-c', name) }
    [:description, :location, :shared,
     :enabled, :accepting].each do |property|
      setter = (property.to_s + '=').to_sym
      value = resource.should(property)
      method(setter).call(value) if value
    end
  end

  def create_printer
    lpadmin('-E', '-p', name, '-m', resource.value(:model))
    [:uri,
     :description, :location, :shared,
     :enabled, :accepting].each do |property|
      setter = (property.to_s + '=').to_sym
      value = resource.should(property)
      method(setter).call(value) if value
    end
  end

  def destroy
    lpadmin('-E', '-x', name)
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
    value == :true ? cupsaccept('-E', name) : cupsreject('-E', name)
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
    value == :true ? cupsenable('-E', name) : cupsdisable('-E', name)
  end

  def location
    query('printer-location')
  end

  def location=(value)
    lpadmin('-E', '-p', name, '-L', value)
  end

  def members
    prefetched = @property_hash[:members]
    prefetched if prefetched
  end

  def members=(_value)
    destroy
    create_class
  end

  def shared
    query('printer-is-shared')
  end

  def shared=(value)
    lpadmin('-E', '-p', name, '-o', "printer-is-shared=#{value}")
  end

  def uri
    query('device-uri') if printer?
  end

  def uri=(value)
    lpadmin('-E', '-p', name, '-v', value)
  end

  private

  def class?
    self.ensure == :class
  end

  def printer?
    self.ensure == :printer
  end

  def query(property)
    Cups::Queue::Attribute.query(name, property)
  end
end
