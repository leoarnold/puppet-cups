# Class 'cups'
#
class cups (
  Array[String] $packages               = $::cups::params::packages,
  Boolean       $purge_unmanaged_queues = false,
  Array[String] $services               = $::cups::params::services,
  Optional[String]                    $default_queue = undef,
  Optional[Enum['merge', 'priority']] $hiera         = undef,
  Optional[String]                    $papersize     = undef,
  Optional[Hash]                      $resources     = undef,
) inherits cups::params {

  package { $packages :
    ensure  => 'present',
  }

  service { $services :
    ensure  => 'running',
    enable  => true,
    require => Package[$packages],
  }

  unless ($papersize == undef) {
    class { '::cups::papersize':
      papersize => $papersize,
      require   => Package[$packages],
      notify    => Service[$services],
    }
  }

  ## Manage `cups_queue` resources

  if ($hiera == 'priority') {
    create_resources('cups_queue', hiera('cups_queue'))
  } elsif ($hiera == 'merge') {
    create_resources('cups_queue', hiera_hash('cups_queue'))
  }

  unless ($resources == undef) {
    create_resources('cups_queue', $resources)
  }

  unless ($default_queue == undef) {
    class { '::cups::default_queue' :
      queue   => $default_queue,
      require => File['lpoptions'],
    }
  }

  resources { 'cups_queue':
    purge   => $purge_unmanaged_queues,
    require => Service[$services],
  }

}
