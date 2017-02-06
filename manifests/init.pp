# Class 'cups'
#
class cups (
  String        $package_ensure = 'present',
  Boolean       $package_manage = true,
  Array[String] $package_names          = $::cups::params::package_names,
  Boolean       $purge_unmanaged_queues = false,
  Array[String] $services               = $::cups::params::services,
  Optional[String]                    $default_queue = undef,
  Optional[Enum['merge', 'priority']] $hiera         = undef,
  Optional[String]                    $papersize     = undef,
  Optional[Hash]                      $resources     = undef,
) inherits cups::params {

  if ($package_manage) {
    package { $package_names :
      ensure  => $package_ensure,
    }
  }

  service { $services :
    ensure  => 'running',
    enable  => true,
    require => Package[$package_names],
  }

  unless ($papersize == undef) {
    class { '::cups::papersize':
      papersize => $papersize,
      require   => Package[$package_names],
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
