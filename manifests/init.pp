# Class: cups
#
# Installs, configures, and manages the CUPS service and related files.
#
class cups (
  $default_queue = undef,
  $queues = undef
) inherits ::cups::params {

  package { $::cups::packages :
    ensure  => 'present',
  }

  service { $::cups::services :
    ensure  => 'running',
    enable  => true,
    require => Package[$::cups::packages],
  }

  unless ($queues == undef) {
    create_resources('cups_queue', $queues)
  }

  unless ($default_queue == undef) {
    class { '::cups::default_queue' :
      queue   => $default_queue,
      require => Service[$::cups::services],
    }
  }

}
