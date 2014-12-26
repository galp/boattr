class boattr::ap (
  $wifi_iface = 'wlan0',
  $ssid       = 'wireless',
  $password   = 'testing',
  $channel    = '11')
{
  $packages = ['hostapd', 'firmware-atheros', 'haveged']
  package {$packages : ensure => present }
  
  service { 'hostapd' : ensure  => running, require => Package[$packages] }
  service { 'haveged' : ensure  => running, require => Package[$packages] }

  file {'/etc/hostapd/hostapd.conf' : 
    ensure  => present,
    content => template("${module_name}/hostapd.conf"),
    notify  => Service['hostapd'],
    require => Package[$packages],
  }
  file {'/etc/default/hostapd' : 
    ensure  => present,
    content => template("${module_name}/hostapd"),
    notify  => Service['hostapd'],
    require => Package[$packages],
  }
}

