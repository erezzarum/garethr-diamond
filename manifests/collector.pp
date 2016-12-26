# == Define: diamond::collector
#
# A puppet wrapper for the collector files
#
# === Parameters
# [*options*]
#   Options for use the the collector template
#
# [*sections*]
#   Some collectors have multiple sections, for example the netapp and rabbitmq collectors
#   Each section can have its own options
define diamond::collector (
  $enabled  = true,
  $options  = undef,
  $sections = undef
) {
  include diamond

  $_enabled = $enabled ? {
    false   => 'False',
    default => 'True',
  }
  $_notify = $::diamond::restart_collectors ? {
    true    => Class['::diamond::service'],
    default => undef,
  }

  file { "/etc/diamond/collectors/${name}.conf":
    content => template('diamond/etc/diamond/collectors/collector.conf.erb'),
    require => Class['::diamond::config'],
    notify  => $_notify,
  }
}

