# Class: cups::papersize
#
# Sets the system's default `/etc/papersize`. See `man papersize` for supported values.
#
class cups::papersize (
  String $papersize
) {
  $papersize_e = shellquote($papersize)
  exec { "paperconfig -p ${papersize}":
    unless => "cat /etc/papersize | grep -w ${papersize_e}",
    path   => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
  }

}
