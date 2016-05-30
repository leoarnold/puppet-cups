# Class: cups::papersize
#
# Sets the system's default `/etc/papersize`. See `man papersize` for supported values.
#
class cups::papersize (
  $papersize # String
) {
  validate_string($papersize)

  exec { "paperconfig -p ${papersize}":
    unless => "cat /etc/papersize | grep -w ${papersize}",
    path   => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
  }
}
