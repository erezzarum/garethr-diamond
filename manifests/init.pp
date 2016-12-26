# == Class: diamond
#
# A basic module to manage diamond, stats collection daemon for Graphite
#
# === Parameters
# [*version*]
#   The package version to install
#
# [*enable_epel*]
#   Include the epel repository
#
# [*package*]
#   Package name
#
# [*enable*]
#   Should the service be enabled during boot time?
#
# [*start*]
#   Should the service be started by Puppet
#
# [*restart*]
#   Restart (notify) service on configuration changes?
#
# [*restart_collectors*]
#   Restart (notify) service on collectors changes?
#
# [*restart_handlers*]
#   Restart (notify) service on handlers changes?
#
# [*config_template*]
#   Configuration template
#
# [*init_template*]
#   init file template
#
# [*purge_collectors*]
#   Determine if we should purge collectors Puppet does not manage
#
# [*purge_handlers*]
#   Determine if we should purge handlers Puppet does not manage
#
# [*extra_handlers*]
#   Additional handlers to include in configuration
#
# [*handlers_path*]
#   Define optional handlers_path for custom handlers
#
# [*collectors_load_delay*]
#   Numer of seconds between each collector load
#
# [*metric_queue_size*]
#   Maximum number of metrics waiting to be processed by handlers
#
# [*collectors_reload_interval*]
#   Colectors reload interval
#
# [*archive*]
#   Enable the archive handler.
#
# [*archive_handler*]
#   Archive handler
#
# [*archive_log*]
#   Archive log path
#
# [*archive_days*]
#   Days of archive logs to keep
#
# [*graphite_handler*]
#   Which handler to use to talk with graphite server
#
# [*graphite_host*]
#   Where to find the graphite server
#
# [*graphite_port*]
#   What port to connect to the graphite server
#
# [*graphite_protocol*]
#   Which protocol to use to talk with graphite server
#
# [*graphite_timeout*]
#   Graphite server connection timeout
#
# [*graphite_batchsize*]
#   Graphite handler batchsize, also sets the pickle handler batchsize
#
# [*graphite_pickle_port*]
#   What port to connect to the graphite pickle server
#
# [*stats_host*]
#   Where to find the stats server
#
# [*stats_port*]
#   What port to connect to the stats server
#
# [*librato_user*]
#   Your Librato username
#
# [*librato_apikey*]
#   Your Librato apikey
#
# [*librato_packages*]
#   librato pip packages
#
# [*riemann_host*]
#   Where to find the riemann server
#
# [*riemann_packages*]
#   riemmann pip packages
#
# [*server_hostname*]
#   Hostname collector path
#
# [*hostname_method*]
#   Hostname calculation method
#
# [*path_prefix*]
#   Define optional path_prefix for storing metrics
#
# [*path_suffix*]
#   Define optional path_suffix for storing metrics
#
# [*instance_prefix*]
#   Define optional instance_prefix for storing instance metrics
#
# [*interval*]
#   How often should metrics be collected and sent to Graphite
#
# [*default_collectors*]
#   Enable the default collectors?
#
# [*logger_level*]
#   Logger level to use
#
# [*rotate_days*]
#   Number of days of rotate logs to keep
#
# [*install_from_pip*]
#   Determine if we should install diamond from python-pip
#
# [*pip_packages*]
#   pip packages to install
#

class diamond(
  $version                     = $::diamond::params::version,
  $enable_epel                 = $::diamond::params::enable_epel,
  $package                     = $::diamond::params::package,
  $service_enable              = $::diamond::params::service_enable,
  $service_start               = $::diamond::params::service_start,
  $restart                     = $::diamond::params::restart,
  $restart_collectors          = $::diamond::params::restart_collectors,
  $restart_handlers            = $::diamond::params::restart_handlers,
  $enable                      = $::diamond::service_enable,
  $start                       = $::diamond::service_start,
  $config_template             = $::diamond::params::config_template,
  $init_template               = $::diamond::params::init_template,
  $purge_collectors            = $::diamond::params::purge_collectors,
  $purge_handlers              = $::diamond::params::purge_handlers,
  $extra_handlers              = [],
  $handlers_path               = undef,
  $collectors_load_delay       = undef,
  $metric_queue_size           = undef,
  $collectors_reload_interval  = undef,
  $archive                     = $::diamond::params::archive,
  $archive_handler             = $::diamond::params::archive_handler,
  $archive_log                 = $::diamond::params::archive_log,
  $archive_days                = $::diamond::params::archive_days,
  $graphite_handler            = $::diamond::params::graphite_handler,
  $graphite_host               = $::diamond::params::graphite_host,
  $graphite_port               = $::diamond::params::graphite_port,
  $graphite_protocol           = $::diamond::params::graphite_protocol,
  $graphite_timeout            = $::diamond::params::graphite_timeout,
  $graphite_batchsize          = $::diamond::params::graphite_batchsize,
  $pickle_port                 = $::diamond::params::graphite_pickle_port,
  $graphite_pickle_port        = $::diamond::pickle_port,
  $stats_host                  = $::diamond::params::stats_host,
  $stats_port                  = $::diamond::params::stats_port,
  $librato_user                = $::diamond::params::librato_user,
  $librato_apikey              = $::diamond::params::librato_apikey,
  $librato_packages            = $::diamond::params::librato_packages,
  $riemann_host                = $::diamond::params::riemann_host,
  $riemann_packages            = $::diamond::params::riemann_packages,
  $server_hostname             = undef,
  $hostname_method             = undef,
  $path_prefix                 = undef,
  $path_suffix                 = undef,
  $instance_prefix             = undef,
  $interval                    = $::diamond::params::interval,
  $default_collectors          = $::diamond::params::default_collectors,
  $collectors                  = { },
  $handlers                    = { },
  $logger_level                = $::diamond::params::logger_level,
  $rotate_level                = $::diamond::params::rotate_level,
  $rotate_days                 = $::diamond::params::rotate_days,
  $install_from_pip            = $::diamond::params::install_from_pip,
  $pip_packages                = $::diamond::params::pip_packages,

) inherits diamond::params {
  class{ 'diamond::install': } ->
  class{ 'diamond::config': } ->
  class{ 'diamond::service': }

  if ($restart == true) {
    Class['diamond::config'] ~> Class['diamond::service']
  }

  if ($handlers != { }) {
    create_resources('::diamond::handler', $handlers)
  }
  if ($collectors != { }) {
    create_resources('::diamond::collector', $collectors)
  }
}
