# Defined type `::cups::ctl`
#
# Wrapper for the `cupsctl` command.
#
# String :: title
# String :: ensure
#
define cups::ctl (
  $ensure
) {
  validate_string($ensure)

  exec { "cupsctl-${title}":
    command => "cupsctl -E ${title}=${ensure}",
    unless  => "cupsctl -E | grep -iw '${title}=${ensure}'",
    path    => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
  }
}
