# Class 'cups::server'
#
# Manages the CUPS server configuration files.
#
class cups::server (
  $ensure         = 'present',
  $conf_directory = '/etc/cups',
  $file_device    = undef,
  $listen         = undef,
  $log_level      = undef,
  $port           = undef,
  $web_interface  = undef,
) {

  validate_absolute_path($conf_directory)

  unless ($file_device == undef) { validate_bool($file_device) }
  unless ($log_level == undef) { validate_re($log_level, '\b(none|emerg|alert|crit|error|warn|notice|info|debug|debug2)\b') }
  unless ($port == undef) { validate_integer($port) }
  unless ($web_interface == undef) { validate_bool($web_interface) }

  case $ensure {
    'present': {

      File {
        owner => 'root',
        group => 'lp'
      }

      file { $conf_directory:
        ensure => 'directory',
        mode   => '0755',
      }

      file { "${conf_directory}/lpoptions" :
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

    }

    'absent': {

      file { $conf_directory:
        ensure => 'absent',
        force  => true,
      }

    }

    default: {
      fail("Unsupported value in 'ensure => ${ensure}'.")
    }

  }

}
