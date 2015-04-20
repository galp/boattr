class boattr::ap (
  $wifi_iface = $::boattr::params::wifi_iface,
  $wifi_ssid  = $::boattr::params::wifi_ssid,
  $wpa_psk    = $::boattr::params::wpa_psk,
  $channel    = $::boattr::params::wifi_channel
  ) inherits boattr::params
{
  require boattr::apt
  
  $packages = ['hostapd', 'firmware-atheros', 'haveged']
  package {$packages : ensure => present }
  
  service { 'hostapd' :
    ensure  => running,
    enable  => true,
    require => Package[$packages]
  }
  service { 'haveged' :
    ensure  => running,
    enable  => true,
    require => Package[$packages]
  }
  file {'/etc/hostapd/hostapd.conf' : 
    ensure  => present,
    content => template("${module_name}/hostapd.conf"),
    notify  => Service['hostapd'],
    require => Package[$packages],
  }
  file {'/etc/default/hostapd' : 
    ensure  => present,
    content => 'DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"'
    notify  => Service['hostapd'],
    require => Package[$packages],
  }

}

