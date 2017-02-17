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
    content => template('cups/cupsd.conf.erb'),
  }

  if ($::cups::papersize) {
    exec { 'cups::papersize':
      command => "paperconfig -p ${::cups::papersize}",
      unless  => "cat /etc/papersize | grep -w ${::cups::papersize}",
      path    => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
    }
  }

}
