# Class 'cups'
#
class cups (
  $confdir                = '/etc/cups',
  $default_queue          = undef,
  $hiera                  = undef,
  $packages               = $::cups::params::packages,
  $papersize              = undef,
  $purge_unmanaged_queues = false,
  $resources              = undef,
  $services               = $::cups::params::services,
) inherits cups::params {

  ## Package installation

  if ($packages == undef) {
    fail('Please provide the name(s) of the CUPS package(s) for your operating system to Class[::cups] or set `packages => []` to disable CUPS package management.') # lint:ignore:140chars
  } else {
    validate_array($packages)

    package { $packages :
      ensure  => 'present',
    }
  }

  ## Service installation and configuration

  if ($services == undef) {
    fail('Please provide the name(s) of the CUPS service(s) for your operating system to Class[::cups] or set `services => []` to disable CUPS service management.') # lint:ignore:140chars
  } else {
    validate_array($services)

    service { $services :
      ensure  => 'running',
      enable  => true,
      require => Package[$packages],
    }
  }

  unless ($papersize == undef) {
    class { '::cups::papersize':
      papersize => $papersize,
      require   => Package[$packages],
      notify    => Service[$services],
    }
  }

  ## Remove special file with default settings for localhost jobs

  validate_absolute_path($confdir)
  file { 'lpoptions' :
    ensure  => 'absent',
    path    => "${confdir}/lpoptions",
    require => Service[$services],
  }

  ## Manage `cups_queue` resources

  unless ($hiera == undef) {
    validate_string($hiera)

    case $hiera {
      'priority': { create_resources('cups_queue', hiera('cups_queue')) }
      'merge': { create_resources('cups_queue', hiera_hash('cups_queue')) }
      default: { fail("Unsupported value 'hiera => ${hiera}'.") }
    }
  }

  unless ($resources == undef) {
    validate_hash($resources)

    create_resources('cups_queue', $resources)
  }

  unless ($default_queue == undef) {
    class { '::cups::default_queue' :
      queue   => $default_queue,
      require => File['lpoptions'],
    }
  }

  validate_bool($purge_unmanaged_queues)
  resources { 'cups_queue':
    purge   => $purge_unmanaged_queues,
    require => Service[$services],
  }

}
