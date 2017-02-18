# Class 'cups'
#
class cups (
  Optional[String]               $default_queue          = undef,
  Variant[String, Array[String]] $listen                 = ['localhost:631', '/var/run/cups/cups.sock'],
  String                         $package_ensure         = 'present',
  Boolean                        $package_manage         = true,
  Array[String]                  $package_names          = $::cups::params::package_names,
  Optional[String]               $papersize              = undef,
  Boolean                        $purge_unmanaged_queues = false,
  Optional[Hash]                 $resources              = undef,
  Boolean                        $service_enable         = true,
  String                         $service_ensure         = 'running',
  Boolean                        $service_manage         = true,
  String                         $service_name           = 'cups',
  Optional[Boolean]              $web_interface          = undef,
) inherits cups::params {

  contain cups::packages
  contain cups::server
  contain cups::queues

  Class[cups::packages]
  -> Class[cups::server]
  -> Class[cups::queues]

}
