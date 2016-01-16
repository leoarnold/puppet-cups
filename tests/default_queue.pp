class { '::cups::default_queue':
  queue => 'Office'
}

# ... automatically requires ...

cups_queue { 'Office':
  ensure => 'printer',
  model  => 'drv:///sample.drv/generic.ppd',
  uri    => 'lpd://192.168.2.105/binary_p1'
}
