# Class: cups
#
# String :: confdir
# String :: default_queue
# String :: hiera
# String/Array :: packages
# String/Array :: services
# boolean :: webinterface
#
class cups (
  $confdir = $::cups::params::confdir,
  $default_queue = undef,
  $hiera = undef,
  $packages = $::cups::params::packages,
  $services = $::cups::params::services,
  $webinterface = undef,
) inherits cups::params {

  if ($packages == undef) {
    fail('Please provide the name(s) of the CUPS package(s) for your operating system to Class[::cups] or set `packages => []` to disable CUPS package management.')
  } else {
    validate_array($packages)

    package { $packages :
      ensure  => 'present',
    }
  }

  if ($services == undef) {
    fail('Please provide the name(s) of the CUPS service(s) for your operating system to Class[::cups] or set `services => []` to disable CUPS service management.')
  } else {
    validate_array($services)

    service { $services :
      ensure  => 'running',
      enable  => true,
      require => Package[$packages],
    }
  }

  unless ($confdir == undef) {
    validate_absolute_path($confdir)

    file { 'lpoptions' :
      ensure  => 'absent',
      path    => "${confdir}/lpoptions",
      require => Service[$services],
    }
  }

  unless ($hiera == undef) {
    validate_string($hiera)

    case $hiera {
      'priority': { create_resources('cups_queue', hiera('cups_queue')) }
      'merge': { create_resources('cups_queue', hiera_hash('cups_queue')) }
      default: { fail("Unsupported value 'hiera => ${hiera}'.") }
    }
  }

  unless ($default_queue == undef) {
    class { '::cups::default_queue' :
      queue   => $default_queue,
      require => File['lpoptions'],
    }
  }

  unless ($webinterface == undef) {
    validate_bool($webinterface)

    cups::ctl { 'WebInterface' :
      ensure  => bool2str($webinterface, 'Yes', 'No'),
      require => Service[$services],
    }
  }

}
