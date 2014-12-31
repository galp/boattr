class boattr (
  $boattr_dir    = $::boattr::params::boattr_dir,
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
  if $with_tor {
    class { 'boattr::tor': lan_ip => $lan_ip }
  }
  
  vcsrepo { $boattr_dir:
    ensure   => present,
    provider => git,
    source   => "git://github.com/galp/boattr.git",
  }
  exec {'bundle_boattr' :
    command  => 'bundle',
    path     => $path,
    cwd      => $boattr_dir,
    creates  => "${boattr_dir}/Gemfile.lock",
    require  => Vcsrepo[$boattr_dir],
    #notify   => Service['dashing'],
  }  

  cron { 'boattr_run':
    command => "ruby ${boattr_dir}/${boattr_run}.rb >  /run/${basename}.log  2>&1",
    user    => root,
    hour    => '*',
    minute  => '*/1'
  }

  file {"${boattr_dir}/config.yml":
    ensure  => present,
    content => template("${module_name}/boattr_config.yml"),
    require => Vcsrepo[$boattr_dir],
  }
  file {"/lib/firmware/BB-W1-00A0.dtbo":
    ensure => present,
    source => 'puppet:///modules/boattr/BB-W1-00A0.dtbo'
  }
  file {"${bin_dir}/${masq_script}":
    ensure => present,
    content => template("${module_name}/boattr_masq_sh.erb"),
    mode   => '0755',
    notify => Exec['masq_sh_script']
  }
  exec {'masq_sh_script' :
    command     => "${bin_dir}/${masq_script} ${lan_iface} ${wan_iface}",
    refreshonly => true,
    require     => File["${bin_dir}/${masq_script}"],
    }
  file_line { 'load_one_wire_device_tree' :
    ensure  => present,
    line    => "echo BB-W1-00A0 > $cape_slots",
    path    => '/etc/rc.local',
    require => [File["/lib/firmware/BB-W1-00A0.dtbo"],File_line['remove_exit']],
  }

  file_line { 'remove_exit' :
    ensure  => absent,
    line    => 'exit 0',
    path    => '/etc/rc.local',
  }
  file_line { 'start_masq_sh_on_boot' :
    ensure  => present,
    line    => "${bin_dir}/${masq_script} ${lan_iface} ${wan_iface}",
    path    => '/etc/rc.local',
    require => [File["/lib/firmware/BB-W1-00A0.dtbo"],File["${bin_dir}/${masq_script}"],File_line['remove_exit']],
    }

}
