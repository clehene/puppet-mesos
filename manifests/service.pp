# Define: mesos::service
#
# This module manages mesos services
#
# Parameters:
#  [*enable*] - enable service autostart
#  [*manage*] - whether puppet should ensure running/stopping services
#  [*force_provider*] - choose a service provider; default = undef = system default; 'none' does not create a service resource at all.
#
# Should not be called directly
#
define mesos::service(
  $enable         = false,
  $force_provider = undef,
  $manage         = true,
) {

  if $::osfamily == 'RedHat' and $::operatingsystemmajrelease >= 7 {
    notice("Installing mesos-${name} service")
    file { "/etc/systemd/system/mesos-${name}.service":
      path    => "/etc/systemd/system/mesos-${name}.service",
      content => template('mesos/service/systemd/mesos.service.erb'),
      backup  => false,
      ensure  => file,
      owner   => $owner,
      group   => $group,
      mode    => 755
    }->Exec["systemd_reload_${name}"]
  include ::mesos

    exec { "systemd_reload_${name}":
      command     => '/bin/systemctl daemon-reload',
    }
  }
  $zk = $mesos::zk
  if $manage {
    if $enable {
      $ensure_service = 'running'
    } else {
      $ensure_service = 'stopped'
    }
  } else {
    $ensure_service = undef
  }


  if ($force_provider != 'none') {
    service { "mesos-${name}":
      ensure     => $ensure_service,
      hasstatus  => true,
      hasrestart => true,
      enable     => $enable,
      provider   => $force_provider,
      subscribe  => [
        File[$mesos::conf_file],
        Package['mesos']
      ],
    }
  }
}
