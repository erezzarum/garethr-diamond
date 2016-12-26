class diamond::params {
  $version              = 'present'
  $service_enable       = true
  $service_start        = true
  $restart              = true
  $restart_collectors   = false
  $restart_handlers     = true
  $config_template      = "${module_name}/etc/diamond/diamond.conf.erb"
  $purge_collectors     = false
  $purge_handlers       = false
  $archive              = false
  $archive_handler      = 'archive.ArchiveHandler'
  $archive_log          = '/var/log/diamond/archive.log'
  $archive_days          = 2
  $graphite_handler     = 'graphite.GraphiteHandler'
  $graphite_host        = false
  $graphite_port        = '2003'
  $graphite_protocol    = 'TCP'
  $graphite_timeout     = 15
  $graphite_batchsize   = 1
  $graphite_pickle_port = '2004'
  $stats_host           = '127.0.0.1'
  $stats_port           = 8125
  $librato_user         = false
  $librato_apikey       = false
  $riemann_host         = false
  $interval             = 30
  $default_collectors   = true
  $logger_level         = 'WARNING'
  $rotate_level         = 'WARNING'
  $rotate_days          = 7
  $install_from_pip     = false

  case $::osfamily {
    'RedHat': {
      $enable_epel          =  false
      $package              = 'diamond'
      $pip_packages         = [ 'python-pip', 'python-configobj', 'gcc', 'python-devel' ]
      $librato_packages     = [ 'librato-metrics' ]
      $riemann_packages     = [ 'bernhard' ]
      if (versioncmp($::operatingsystemmajrelease, '7') >= 0) {
        $init_template = "${module_name}/systemd-diamond.erb"
      } elsif (versioncmp($::operatingsystemmajrelease, '7') < 0) {
        $init_template = "${module_name}/initd-diamond.erb"
      }
    }
    /^(Debian|Ubuntu)$/: {
      $package              = 'diamond'
      $pip_packages         = [ 'python-pip', 'python-configobj', 'gcc', 'python-dev' ]
      $librato_packages     = [ 'librato-metrics' ]
      $riemann_packages     = [ 'bernhard' ]
      $init_template        = "${module_name}/upstart-diamond.erb"
    }
    'Solaris': {
      case $::kernelrelease {
        '5.11': {
          $package          = 'diamond'
          $pip_packages     = [ 'pip', 'solarisstudio-122' ]
          $librato_packages = [ 'librato-metrics' ]
          $riemann_packages = [ 'bernhard' ]
        }
        default: {
          fail("${module_name} only support Solaris version 11")
        }
      }
    }
    default: {
      fail("${module_name} is not supported on ${::osfamily}")
    }
  }

}