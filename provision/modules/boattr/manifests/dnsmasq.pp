class boattr::dnsmasq (
  $subnet    = $::boattr::params::lan_subnet,
  $interface = $::boattr::params::lan_iface
  ) inherits boattr::params
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
