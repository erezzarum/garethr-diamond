# == Class: diamond::install
#
# Class to install Diamond from packages.
# Also installed dependencies for collectors
#
class diamond::install {
  if !defined(Class['::diamond']) {
    fail("You must include the diamond base class before using ${module_name}")
  }

  if $diamond::install_from_pip {
    case $::osfamily {
      'RedHat': {
        if $::diamond::enable_epel {
          include epel
          $_require_epel = Yumrepo['epel']
        } else {
          $_require_epel = undef
        }
        ensure_resource('package', $::diamond::pip_packages, {
          'ensure' => 'present',
          'before' => Package['diamond'],
          'require' => $_require_epel,
        })
      }
      /^(Debian|Ubuntu)$/: {
        ensure_resource('package', $::diamond::pip_packages, {
          'ensure' => 'present',
          'before' => Package['diamond'],
        })
      }
      'Solaris': {
        case $::kernelrelease {
          '5.11': {
            ensure_resource('package', $::diamond::pip_packages, {
              'ensure' => 'present',
              'before' => Package['diamond'],
            })
            file { ['/ws', '/ws/on11update-tools', '/ws/on11update-tools/SUNWspro']: ensure => directory, }
            file { '/ws/on11update-tools/SUNWspro/sunstudio12.1':
              ensure  => symlink,
              force   => true,
              target  => '/opt/solstudio12.2',
              before  => Package['diamond'],
              require => Package['solarisstudio-122'],
            }
          }
          default: {
            fail('Module only supports version 11 when used on Solaris')
          }
        }
      }
      default: { fail('Unrecognized operating system') }
    }
    package { 'diamond':
      name     => $::diamond::package,
      ensure   => present,
      provider => pip,
    }
    if $::osfamily == 'Solaris' {
    # This should eventually go upstream
      file { '/lib/svc/method/diamond':
        source  => 'puppet:///modules/diamond/solaris/method/diamond',
        mode    => '0755',
        owner   => 'root',
        group   => 'bin',
        require => Package['diamond'],
      }
      file { '/lib/svc/manifest/network/diamond.xml':
        source  => 'puppet:///modules/diamond/solaris/manifest/diamond.xml',
        mode    => '0444',
        owner   => 'root',
        group   => 'sys',
        require => [Package['diamond'],File['/lib/svc/method/diamond']],
      }
    }
    file { '/var/log/diamond':
      ensure => directory,
    }
  } else {
    package { 'diamond':
      ensure  => $::diamond::version,
      name    => $::diamond::package,
    }
  }

  file { '/var/run/diamond':
    ensure => directory,
  }

  file { '/etc/diamond':
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755',
  }

  file { '/etc/diamond/collectors':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    purge   => $::diamond::purge_collectors,
    recurse => true,
    require => File['/etc/diamond'],
  }

  file { '/etc/diamond/handlers':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    purge   => $::diamond::purge_handlers,
    recurse => true,
    require => File['/etc/diamond'],
  }

  if $diamond::librato_user and $diamond::librato_apikey {
    ensure_packages(['python-pip'])
    ensure_resource('package', $::diamond::librato_packages, {
      'ensure' => 'present',
      'provider' => pip,
      'before' => Package['python-pip'],
    })
  }

  if $diamond::riemann_host {
    ensure_packages(['python-pip'])
    ensure_resource('package', $::diamond::riemann_packages, {
      'ensure' => 'present',
      'provider' => pip,
      'before' => Package['python-pip'],
    })
  }

}
