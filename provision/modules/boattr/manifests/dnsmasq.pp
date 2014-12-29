class boattr::dnsmasq (
  $lan_subnet    = $::boattr::params::lan_subnet,
  $lan_iface     = $::boattr::params::lan_iface,
  $domain        = $::boattr::params::domain,
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
