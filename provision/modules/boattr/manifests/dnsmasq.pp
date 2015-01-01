class boattr::dnsmasq (
  $lan_subnet    = $::boattr::params::lan_subnet,
  $lan_iface     = $::boattr::params::lan_iface,
  $domain        = $::boattr::params::domain,
  $dhcp_auth     = $::boattr::params::dhcp_auth,
  ) inherits boattr::params
{
  require boattr::apt
  $packages  = ['dnsmasq']
  package {$packages : ensure => present }
  service { 'dnsmasq' :
    ensure  => running,
    enable  => true,
    require => Package[$packages]
  }

  file {'/etc/dnsmasq.conf' : 
    ensure  => present,
    content => template("${module_name}/dnsmasq.conf"),
    notify  => Service['dnsmasq'],
  }
  
}
