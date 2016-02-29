# Defined type `::cups::directive`
#
# Wrapper for the `cupsctl` command.
#
# String :: title
# String :: value
#
define cups::directive (
  $value
) {
  assert_private("The defined type 'cups::directive' is private. Please use the corresponding attribute of the '::cups' class.")

  validate_string($value)

  exec { "cupsctl-${title}":
    command => "/usr/sbin/cupsctl ${title}=${value}",
    unless  => "/usr/sbin/cupsctl | /bin/grep -i '${title}=${value}'"
  }
}