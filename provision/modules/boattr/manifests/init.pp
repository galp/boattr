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
  $lan_gw        = $::boattr::params::lan_gw,
  $lan_dns       = $::boattr::params::lan_dns,
  $wired_iface   = $::boattr::params::wired_iface,
  $wan_iface     = $::boattr::params::wan_iface,
  
  $bin_dir       = $::boattr::params::bin_dir,
  $masq_script   = $::boattr::params::masq_script,
  $with_tor      = $::boattr::params::with_tor,
  $wifi_ssid     = $::boattr::params::wifi_ssid,
  $wifi_mac     = $::boattr::params::wifi_mac,
  $data_dev      = $::boattr::params::data_dev,
  $wpa_psk       = $::boattr::params::wpa_psk,
  $internet_devices_mac = '',
  ) inherits boattr::params
{
  $bridge_ports    = "${wired_iface} ${usb_iface}"
  require boattr::packages
  if $with_tor == false {
    notice('tor gateway is disabled')
  }
  else {
    notice('tor gateway is enabled')
    class {'tor': ip => $lan_ip}
  }
  if $wifi_ssid == 'unset' {
    notice('wireless AP is disabled')
  }
  else {
    class { 'boattr::ap': wpa_psk => $wpa_psk, wifi_ssid => $wifi_ssid }
    notice('wireless AP is enabled')
  }
  if $data_dev == 'unset' {
    class { 'boattr::storage': }
  }
  else {
    class { 'boattr::storage': data_dev => $data_dev }
  }

  file {'/etc/network/interfaces' :
    ensure  => present,
    content => template("${module_name}/boattr_interfaces.erb"),
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
    file {"${firmware_dir}":
      ensure  => directory,
    }
  
  file {"${firmware_dir}/BB-W1-00A0.dtbo": #FIXME beaglebone only
    ensure  => present,
    source  => 'puppet:///modules/boattr/BB-W1-00A0.dtbo',
    require => File[$firmware_dir],
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
    service { 'puppet' :
      ensure  => stopped,
      enable  => false,
  }

  service { 'udev' :
    ensure  => running,
    enable  => true,
  }
  service { 'boattr' :
    ensure  => running,
    enable  => true,
    require => File['/etc/systemd/system/boattr.service'],
  }
  file {'/etc/systemd/system/boattr.service' :
    ensure  => present,
    content => template("${module_name}/boattr_service.erb"),
    notify  => Service['boattr']
  }

  file {'/etc/udev/rules.d/10-boattr.rules' :
    ensure  => present,
    content => template("${module_name}/boattr_udev_rules.erb"),
    notify  => Service['udev']
  }

}
