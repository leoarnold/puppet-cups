# Private class
#
# @summary Encapsulates all configuration of the CUPS server
#
# This class inherits the several attributes from the public {cups} class.
#
# @author Leo Arnold
# @since 2.0.0
#
# @example This class is implicitly declared e.g. through
#   class { '::cups':
#     listen        => 'localhost:631',
#     papersize     => 'A4',
#     web_interface => true
#   }
#
class cups::server::config inherits cups::server {

  File {
    owner => 'root',
    group => 'lp'
  }

  file { '/etc/cups/lpoptions':
    ensure => 'absent',
  }

  file { '/etc/cups/cupsd.conf':
    ensure  => 'file',
    mode    => '0640',
    content => template('cups/header.erb', 'cups/cupsd.conf.erb'),
  }

  if ($::cups::papersize) {
    exec { 'cups::papersize':
      command => "paperconfig -p ${::cups::papersize}",
      unless  => "cat /etc/papersize | grep -w ${::cups::papersize}",
      path    => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
    }
  }

}
