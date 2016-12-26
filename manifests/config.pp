# == Class: diamond::config
#
# The configuration of the Diamond daemon
#
class diamond::config {
  if !defined(Class['::diamond']) {
    fail("You must include the diamond base class before using ${module_name}")
  }

  file { '/etc/diamond/diamond.conf':
    ensure  => present,
    content => template($::diamond::config_template)
  }
}
