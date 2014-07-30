class dnsmasq (
  $subnet    = '192.168.100',
  $ensure    = 'stopped',
  $interface = 'br0'
  )
{

  $packages  = ['dnsmasq']
  package {$packages : ensure => present }
  service { 'dnsmasq' : ensure  => running,
    require => Package[$packages]
  }
  file {'/etc/dnsmasq.conf' : 
    ensure  => $ensured,
    content => template('teplates/dnsmasq.conf'),
    notify  => Service['dnsmasq'],
  }
  
}
