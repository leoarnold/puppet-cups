include '::cups'

cups_queue { 'MinimalPrinter':
  ensure => 'printer',
  model  => 'drv:///sample.drv/generic.ppd',
}
