# Defined type `::cups::ctl`
#
# Wrapper for the `cupsctl` command.
#
define cups::ctl (
  $ensure # String
) {
  validate_string($ensure)

  exec { "cupsctl -E ${title}=${ensure}":
    unless => "cupsctl -E | grep -iw '${title}=${ensure}'",
    path   => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
  }
}
