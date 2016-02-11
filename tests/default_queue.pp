class { '::cups':
  default_queue => 'Office',
}

# ... will fail unless the corresponding `cups_queue` is specified:

cups_queue { 'Office':
  ensure => 'printer',
  model  => 'drv:///sample.drv/generic.ppd',
  uri    => 'lpd://192.168.2.105/binary_p1'
}
