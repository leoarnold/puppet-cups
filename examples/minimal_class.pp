# CUPS class example manifest
#
# Assuming you already have some printer queues installed on the node,
# e.g. because you chose to manage them via Puppet aswell:

cups_queue { 'Office':
  ensure => 'printer',
  model  => 'drv:///sample.drv/generic.ppd',
  uri    => 'lpd://192.168.2.105/binary_p1'
}

cups_queue { 'Warehouse':
  ensure => 'printer',
  model  => 'drv:///sample.drv/laserjet.ppd',
  uri    => 'socket://warehouse.initech.com'
}

# and you want to install a CUPS class containing both of them,
# then all you need to specify is:

include '::cups'

cups_queue { 'MinimalClass':
  ensure  => 'class',
  members => ['Office', 'Warehouse']
}

# which will autorequire its `members` to ensure correct order of installation.
