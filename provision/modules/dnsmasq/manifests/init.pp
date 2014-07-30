class dnsmasq (
  $subnet    = '192.168.100',
  $interface = 'br0'
  )
{

  $packages  = ['dnsmasq']
  package {$packages : ensure => present }
  service { 'dnsmasq' : ensure  => running,
    require => Package[$packages]
  }
  file {'/etc/dnsmasq.conf' : 
    ensure  => present,
    content => template("${module_name}/dnsmasq.conf"),
    notify  => Service['dnsmasq'],
  }
  
}
