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
    command => "/usr/sbin/cupsctl -E ${title}=${ensure}",
    unless  => "/usr/sbin/cupsctl | /bin/grep -i '${title}=${ensure}'"
  }
}