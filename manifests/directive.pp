# Defined type `::cups::directive`
#
# Manages the CUPS directive by the same title in the configuration file specified.
#
define cups::directive (
  $ensure,                # String
  $file,                  # String
  $confdir = '/etc/cups', # String
) {
  validate_string($ensure)
  validate_string($confdir)
  validate_string($file)

  augeas { "${file}/${title} ${ensure}":
    context => "/files${confdir}/${file}",
    changes => [
      "set directive[ . = \"${title}\" ] \"${title}\"",
      "set directive[ . = \"${title}\" ]/arg \"${ensure}\""
    ]
  }
}
