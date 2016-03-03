# Class: cups
#
# String       :: default_queue
# String/Array :: packages
# String/Array :: services
# Hiera_hash   :: queues
# boolean      :: webinterface
#
class cups (
  $default_queue = undef,
  $packages = $::cups::params::packages,
  $services = $::cups::params::services,
  $queues = undef,
  $webinterface = undef,
) inherits cups::params {

  if ($packages == undef) {
    fail('Please provide the name(s) of the CUPS package(s) for your operating system to Class[::cups] or set `packages => []` to disable CUPS package management.')
  } else {
    package { $packages :
      ensure  => 'present',
    }
  }

  if ($services == undef) {
    fail('Please provide the name(s) of the CUPS service(s) for your operating system to Class[::cups] or set `services => []` to disable CUPS service management.')
  } else {
    service { $services :
      ensure  => 'running',
      enable  => true,
      require => Package[$packages],
    }
  }

  file { $::cups::lpoptions_file :
    ensure  => 'absent',
    require => Package[$packages],
  }

  unless ($queues == undef) {
    create_resources('cups_queue', $queues)
  }

  unless ($default_queue == undef) {
    class { '::cups::default_queue' :
      queue   => $default_queue,
      require => Service[$services],
    }
  }

  unless ($webinterface == undef) {
    validate_bool($webinterface)

    cups::directive { 'WebInterface' :
      value   => bool2str($webinterface, 'Yes', 'No'),
      require => Service[$services],
    }
  }

}
