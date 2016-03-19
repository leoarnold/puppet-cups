# Example usage of the class `cups::default_queue`
#
# The following manifest sets the default queue by executing
#   lpadmin -d Office
# unless the correct value is already in place.

class { '::cups::default_queue':
  queue => 'Office',
}

# It is, however, mandatory to specify the corresponding `cups_queue` resource
# in the same manifest (or at least the same catalog):

cups_queue { 'Office':
  ensure => 'printer',
  model  => 'drv:///sample.drv/generic.ppd',
  uri    => 'lpd://192.168.2.105/binary_p1'
}
