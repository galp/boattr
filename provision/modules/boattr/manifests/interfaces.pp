class boattr::interfaces (
  $lan_ip       = $::boattr::params::lan_ip,
  $wired_iface  = $::boattr::params::wired_iface,
  $lan_gw       = $::boattr::params::lan_gw,
  $lan_dns      = $::boattr::params::lan_dns,
  ) inherits boattr::params
{
  require boattr::apt
  $packages = ['bridge-utils']
  package {$packages : ensure => present }
  
  case $::is_virtual {
    'false' : {

      file {'/etc/network/interfaces' : 
        ensure  => present,
        content => template("${module_name}/interfaces"),
        require => Package[$packages],
      }
    }
    'true' : { }
  }
}
