# == Class: diamond::service
#
# Class representing the Diamond service
#
class diamond::service {
  if !defined(Class['::diamond']) {
    fail("You must include the diamond base class before using ${module_name}")
  }

  $ensure = $::diamond::start ?{
    true    => running,
    default => stopped
  }
  $service_name   = $::osfamily ? {
    'Solaris'  => 'network/diamond',
    default   => 'diamond',
  }
  $manifest = $::osfamily ? {
    'Solaris' => '/lib/svc/manifest/network/diamond.xml',
    default   => undef,
  }

  if (versioncmp($::operatingsystemmajrelease, '7') >= 0) {
    file { '/etc/init.d/diamond':
      ensure => absent,
    } ->
    file { '/usr/lib/systemd/system/diamond.service':
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template($::diamond::init_template),
    }
    $_require = File['/usr/lib/systemd/system/diamond.service']
  } elsif (versioncmp($::operatingsystemmajrelease, '7') < 0) {
    file { '/etc/init.d/diamond':
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => template($::diamond::init_template),
    }
    $_require = File['/etc/init.d/diamond']
  } else {
    $_require = undef
  }

  service { 'diamond':
    ensure     => $ensure,
    name       => $service_name,
    enable     => $::diamond::enable,
    hasstatus  => true,
    hasrestart => true,
    manifest   => $manifest,
    require    => $_require,
  }
}

