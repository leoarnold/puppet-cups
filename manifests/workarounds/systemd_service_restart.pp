# @summary Adds a ListenStream dependency to the CUPS socket systemd unit
#
# On some systemd based Linux distributions the Puppet run fails because
# during service restart systemd would prematurely yield back control to
# Puppet which would then fail to install print queues.
#
# This class makes the configured systemd unit for CUPS to listen on port 631
# before control is yielded back to Puppet thereby preventing the failure.
#
# @param ensure Enable or disable this workaround
# @param unit The name of the systemd unit which should wait for CUPS to listen on port 631
#
# @author Thomas Equeter
# @since 2.1.1
#
# @example The default inclusion
#   include '::cups::workarounds::systemd_service_restart'
#
# @example Adding the ListenStream to a different unit
#   class { '::cups::workarounds::systemd_service_restart':
#     unit => 'mycups.socket'
#   }
#
# @see https://bugzilla.redhat.com/show_bug.cgi?id=1088918
#
class cups::workarounds::systemd_service_restart (
  Enum['present', 'absent'] $ensure = 'present',
  String $unit = 'cups.socket',
) {

  if ($::systemd) {

    include '::cups'

    systemd::dropin_file { 'wait_until_cups_listens_on_port_631.conf':
      ensure  => $ensure,
      unit    => $unit,
      content => template(
        'cups/_header.erb',
        'cups/systemd/wait_until_cups_listens_on_port_631.conf.erb'
      )
    }

    Systemd::Dropin_file['wait_until_cups_listens_on_port_631.conf'] ~> Class['cups::server::services']

  }

}
