# @summary Adds a ListenStream dependency to the CUPS socket systemd unit
#
# On some systemd based Linux distributions the Puppet run fails because
# during service restart systemd would prematurely yield back control to
# Puppet which would then fail to install print queues.
#
# This class makes the configured systemd unit for CUPS to listen on port 631
# before control is yielded back to Puppet thereby preventing the failure.
#
# Multiple CUPS service names (`$::cups::service_names`) are not supported,
# only the first one is considered.
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
  Pattern[/\.socket\Z/] $unit = 'cups.socket',
) {

  if ($::systemd) {

    include '::cups'

    $_dropin_file = systemd::dropin_file { 'wait_until_cups_listens_on_port_631.conf':
      ensure  => $ensure,
      unit    => $unit,
      content => template(
        'cups/_header.erb',
        'cups/systemd/wait_until_cups_listens_on_port_631.conf.erb'
      )
    }

    $_main_service_name = any2array($::cups::service_names)[0]
    $_safe_service_name = shell_escape($_main_service_name)
    $_safe_socket_name  = shell_escape($unit)

    $_socket_service = service { $unit:
      ensure  => $::cups::service_ensure,
      # Both units listen to port 631, however cups.service will play nice if
      # cups.socket is started first. See sd_listen_fds(3).
      start   => "systemctl stop ${_safe_service_name} && systemctl start ${_safe_socket_name}",
      restart => "systemctl stop ${_safe_service_name} && systemctl restart ${_safe_socket_name}",
    }

    $_dropin_file ~> [ Class['cups::server::services'], $_socket_service ]
    Class['systemd::systemctl::daemon_reload'] -> $_socket_service -> Class['cups::server::services']

  }

}
