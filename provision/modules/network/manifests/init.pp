class network {
  class ap (
    $wifi_iface = 'wlan0',
    $ssid       = 'wireless',
    $channel    = '11')
  {
    $packages = ['hostapd', 'firmware-atheros']
    package {$packages : ensure => present }
    
    service { 'hostapd' : ensure  => running, require => Package[$packages] }
    
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
  class interfaces {
    $packages = ['bridge-utils']
    package {$packages : ensure => present }
    
    file {'/etc/network/interfaces' : 
      ensure  => present,
      content => template("${module_name}/interfaces"),
    }
  }
}
