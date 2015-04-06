class boattr (
  $boattr_dir    = $::boattr::params::boattr_dir,
  $boattr_repo   = $::boattr::params::boattr_repo,
  $basename      = $::boattr::params::basename,
  $description   = $::boattr::params::description,
  $i2cBus        = $::boattr::params::i2cBus,
  $i2cAdcAddress = $::boattr::params::i2cAdcAddress,
  $db_host       = $::boattr::params::db_host,
  $db_dir        = $::boattr::params::db_dir,
  $dash_dir      = $::boattr::params::dash_dir,
  $dash_host     = $::boattr::params::dash_host,
  $dash_auth     = $::boattr::params::dash_auth,
  $graph_host    = $::boattr::params::graph_host,
  $cape_slots    = $::boattr::params::cape_slots,
  $lan_iface     = $::boattr::params::lan_iface,
  $lan_ip        = $::boattr::params::lan_ip,
  $wan_iface     = $::boattr::params::wan_iface,
  $tor_gateway   = $::boattr::params::tor_gateway,
  $bin_dir       = $::boattr::params::bin_dir,
  $masq_script   = $::boattr::params::masq_script,
  $with_tor      = $::boattr::params::with_tor,
  ) inherits boattr::params
{
  require boattr::packages
  if $with_tor {
    class { 'boattr::tor': lan_ip => $lan_ip }
    notice('tor gateway is enabled')
  }

  vcsrepo { $boattr_dir:
    ensure   => present,
    provider => git,
    source   => $boattr_repo
  }
  exec {'bundle_boattr' :
    command  => 'bundle',
    path     => $::path,
    cwd      => $boattr_dir,
    creates  => "${boattr_dir}/Gemfile.lock",
    require  => Vcsrepo[$boattr_dir],
    #notify   => Service['dashing'],
  }

  file {"${boattr_dir}/config.yml":
    ensure  => present,
    replace => 'no',
    content => template("${module_name}/boattr_config.yml"),
    require => Vcsrepo[$boattr_dir],
  }
  file {'/lib/firmware/BB-W1-00A0.dtbo': #FIXME beaglebone only
    ensure => present,
    source => 'puppet:///modules/boattr/BB-W1-00A0.dtbo'
  }
  file {"${bin_dir}/${masq_script}":
    ensure  => present,
    content => template("${module_name}/boattr_masq_sh.erb"),
    mode    => '0755',
  }
  exec {'masq_sh_script' :
    command     => "${bin_dir}/${masq_script} ${lan_iface} ${wan_iface}",
    refreshonly => true,
    require     => File["${bin_dir}/${masq_script}"],
    }
    file {'/etc/rc.local':
      ensure  => present,
      content => template("${module_name}/boattr_rc_local.erb"),
      require => [File['/lib/firmware/BB-W1-00A0.dtbo'],File["${bin_dir}/${masq_script}"]],
    }
    file {"${boattr_dir}/run":
      ensure  => directory,
      require => Vcsrepo[$boattr_dir],
    }
}
