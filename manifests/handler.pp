# == Define: diamond::handler
#
# A puppet wrapper for the handler config files
#
# === Parameters
# [*options*]
#   Options for use the the handler template
#
# [*sections*]
#   Some handlers have multiple sections,
#   Each section can have its own options
define diamond::handler (
  $options  = undef,
  $sections = undef
) {
  include diamond

  $_notify = $::diamond::restart_handlers ? {
    true    => Class['::diamond::service'],
    default => undef,
  }

  file { "/etc/diamond/handlers/${name}.conf":
    content => template('diamond/etc/diamond/handlers/handler.conf.erb'),
    require => Class['::diamond::config'],
    notify  => $_notify,
  }
}
