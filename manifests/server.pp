# Class 'cups::server'
#
# Manages the CUPS server configuration files.
#
class cups::server (
  Enum['present', 'absent'] $ensure = 'present',
  String $conf_directory = '/etc/cups',
  Optional[Boolean] $file_device = undef,
  Optional[Variant[String, Array[String]]] $listen = undef,
  Optional[Enum['none', 'emerg', 'alert', 'crit', 'error', 'warn', 'notice', 'info', 'debug', 'debug2']] $log_level = undef,
  Optional[Variant[Integer[0, 65535], Array[Integer[0, 65535]]]] $port = undef,
  Optional[Boolean] $web_interface = undef,
) {

  validate_absolute_path($conf_directory)

  if ($ensure == 'present') {

    File {
      owner => 'root',
      group => 'lp'
    }

    file { $conf_directory:
      ensure => 'directory',
      mode   => '0755',
    }

    file { 'lpoptions' :
      path    => "${conf_directory}/lpoptions",
      ensure  => 'absent',
      require => File[$conf_directory],
    }

    file { "${conf_directory}/cupsd.conf":
      ensure  => 'file',
      mode    => '0640',
      content => template('cups/cupsd.conf.erb'),
      require => File[$conf_directory],
    }

    file { "${conf_directory}/cups-files.conf":
      ensure  => 'file',
      mode    => '0640',
      content => template('cups/cups-files.conf.erb'),
      require => File[$conf_directory],
    }

    file { ["${conf_directory}/interfaces", "${conf_directory}/ppd"]:
      ensure  => 'directory',
      mode    => '0755',
      require => File[$conf_directory],
    }

    file { "${conf_directory}/ssl":
      ensure  => 'directory',
      mode    => '0700',
      require => File[$conf_directory],
    }

    file { "${conf_directory}/ssl/server.crt":
      ensure  => 'link',
      target  => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
      require => File["${conf_directory}/ssl"],
    }

    file { "${conf_directory}/ssl/server.key":
      ensure  => 'link',
      target  => '/etc/ssl/private/ssl-cert-snakeoil.key',
      require => File["${conf_directory}/ssl"],
    }

  } elsif ($ensure == 'absent') {

    file { $conf_directory:
      ensure => 'absent',
      force  => true,
    }

  }

}
