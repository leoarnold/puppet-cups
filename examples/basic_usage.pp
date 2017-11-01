# Example usage of the class `cups`
#
# This class responsible for (amongst others):
# - installing the necessary packages
# - enabling and running the required services
# - setting the default queue
# - managing the CUPS web interface
#
# A typical usage example would be

class { '::cups':
  default_queue => 'Office',
}

# which does all of the above, using default values for packages and services.
# It is, however, mandatory to specify the corresponding `cups_queue` resource
# for your desired default queue in the same manifest (or at least the same catalog):

cups_queue { 'Office':
  ensure => 'printer',
  model  => 'drv:///sample.drv/generic.ppd',
  uri    => 'lpd://192.168.2.105/binary_p1'
}
