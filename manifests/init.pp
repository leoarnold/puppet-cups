# @summary Installs, configures, and manages the CUPS service.
#
# All resources in this module require the CUPS daemon to be installed and configured in a certain way.
# To ensure these preconditions you should include the main `cups` class wherever you use this module.
#
# @author Leo Arnold
# @since 0.0.1
#
# @example Install and run the CUPS server using default values
#   include '::cups'
#
# @example Additionally set the default printer
#   class { '::cups':
#     default_queue => 'Office'
#   }
#
# @example Install HP PPD files before managing any printer queue
#   package { 'hplip':
#     ensure => present
#   }
#
#   class { '::cups':
#     require => Package['hplip']
#   }
#
# @param access_log_level Sets the `AccessLogLevel` directive of the CUPS server.
# @param browse_dnssd_subtypes Sets the `BrowseDNSSDSubTypes` directive of the CUPS server.
#   Accepts a string or an array of supported subtypes without leading underscore, e.g. `['cups', 'print']`.
# @param browse_local_protocols Sets the `BrowseLocalProtocols` directive of the CUPS server.
#   Accepts a string or an array of supported protocols.
# @param browse_web_if Boolean value for the `BrowseWebIF` directive of the CUPS server.
# @param browsing Boolean value for the `Browsing` directive of the CUPS server.
# @param default_queue The name of the default destination for all print jobs.
#   Requires the catalog to contain a `cups_queue` resource with the same name.
# @param listen Which addresses to the CUPS daemon should listen to.
#   Accepts (an array of) strings.
#   Note that the `cupsd.conf` directive `Port 631` is equivalent to `Listen *:631`.
#   *Warning*: For this module to work, it is *mandatory* that CUPS is listening on `localhost:631`.
# @param location Sets the access control lists for the CUPS web interface. Restricts access to localhost by default.
# @param log_debug_history Sets the `LogDebugHistory` directive of the CUPS server.
# @param log_level Sets the `LogLevel` directive of the CUPS server.
# @param log_time_format Sets the `LogTimeFormat` directive of the CUPS server.
# @param max_clients Specifies the maximum number of simultaneous clients to support.
# @param max_clients_per_host Specifies the maximum number of simultaneous clients to support from a single address.
# @param max_log_size Sets the `MaxLogSize` directive of the CUPS server.
# @param max_request_size Specifies the maximum request/file size in bytes.
# @param package_ensure Whether CUPS packages should be `present` or `absent`.
# @param package_manage Whether to manage package installation at all.
# @param package_names A name or an array of names of all packages needed to be installed
#   in order to run CUPS and provide `ipptool`. OS dependent defaults apply.
# @param page_log_format Sets the `PageLogFormat` directive of the CUPS server.
# @param papersize Sets the system's default `/etc/papersize`. See `man papersize` for supported values.
# @param policies Sets the access policies for the CUPS server to use.
# @param purge_unmanaged_queues Setting `true` will remove all queues from the node
#   which do not match a `cups_queue` resource in the current catalog.
# @param resources This attribute is intended for use with Hiera or any other ENC.
# @param server_alias Sets the `ServerAlias` directive of the CUPS server.
# @param server_name Sets the `ServerName` directive of the CUPS server.
# @param service_enable Whether the CUPS services should be enabled to run at boot.
# @param service_ensure Whether the CUPS services should be `running` or `stopped`.
# @param service_manage Whether to manage services at all.
# @param service_names A name or an array of names of all CUPS services to be managed.
# @param web_interface Boolean value to enable or disable the server's web interface.
#
class cups (
  Optional[String]                         $access_log_level       = undef,
  Optional[Variant[String, Array[String]]] $browse_dnssd_subtypes  = undef,
  Optional[Variant[String, Array[String]]] $browse_local_protocols = undef,
  Optional[Boolean]                        $browse_web_if          = undef,
  Boolean                                  $browsing               = false,
  Optional[String]                         $default_queue          = undef,
  Variant[String, Array[String]]           $listen                 = ['localhost:631', '/var/run/cups/cups.sock'],
  Optional[Variant[String, Hash]]          $location               = undef,
  Optional[Integer]                        $log_debug_history      = undef,
  Optional[String]                         $log_level              = undef,
  Optional[String]                         $log_time_format        = undef,
  Optional[Integer]                        $max_clients            = undef,
  Optional[Integer]                        $max_clients_per_host   = undef,
  Optional[Variant[Integer, String]]       $max_log_size           = undef,
  Optional[Integer]                        $max_request_size       = undef,
  String                                   $package_ensure         = 'present',
  Boolean                                  $package_manage         = true,
  Variant[String, Array[String]]           $package_names          = $::cups::params::package_names,
  Optional[String]                         $page_log_format        = undef,
  Optional[String]                         $papersize              = undef,
  Optional[Hash]                           $policies               = undef,
  Boolean                                  $purge_unmanaged_queues = false,
  Optional[Hash]                           $resources              = undef,
  Optional[Variant[String, Array[String]]] $server_alias           = undef,
  Optional[String]                         $server_name            = undef,
  Boolean                                  $service_enable         = true,
  String                                   $service_ensure         = 'running',
  Boolean                                  $service_manage         = true,
  Variant[String, Array[String]]           $service_names          = 'cups',
  Optional[Boolean]                        $web_interface          = undef,
) inherits cups::params {

  contain cups::packages
  contain cups::server
  contain cups::queues

  Class[cups::packages]
  -> Class[cups::server]
  -> Class[cups::queues]

}
