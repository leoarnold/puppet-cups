# CUPS class example manifest
#
# In order to install printer queues you first need to make sure
# CUPS is installed and the service is running. This is achieved by:

include '::cups'

# To install a printer queue, any of the following methods will suffice.
# See README.md for a full list of all customizable attributes.

cups_queue { 'MinimalRaw':
  ensure => 'printer',
  uri    => 'lpd://192.168.2.105/binary_p1'
}

cups_queue { 'MinimalModel':
  ensure => 'printer',
  model  => 'drv:///sample.drv/generic.ppd',
  uri    => 'lpd://192.168.2.105/binary_p1'
}

cups_queue { 'MinimalPPD':
  ensure => 'printer',
  ppd    => '/usr/share/cups/model/myprinter.ppd',
  uri    => 'lpd://192.168.2.105/binary_p1'
}
