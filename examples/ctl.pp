# Example usage of the class `cups::ctl`
#
# This class is a convenience wrapper for the `cupsctl` command line utility.
#
# The following manifest executes the command
#   cupsctl WebInterface=Yes
# unless the correct value is already in place.

cups::ctl { 'WebInterface' :
  ensure => 'Yes',
}
