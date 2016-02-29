# Class: cups
#
# String     :: default_queue
# Hiera_hash :: queues
# boolean    :: webinterface
#
class cups (
  $default_queue = undef,
  $queues = undef,
  $webinterface = undef,
) inherits ::cups::params {

  package { $::cups::packages :
    ensure  => 'present',
  }

  service { $::cups::services :
    ensure  => 'running',
    enable  => true,
    require => Package[$::cups::packages],
  }

  file { $::cups::lpoptions_file :
    ensure  => 'absent',
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

  unless ($webinterface == undef) {
    validate_bool($webinterface)

    cups::directive { 'WebInterface' :
      value   => bool2str($webinterface, 'Yes', 'No'),
      require => Service[$::cups::services],
    }
  }

}
