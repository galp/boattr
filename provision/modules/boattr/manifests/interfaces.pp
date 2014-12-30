class boattr::interfaces (
  $lan_ip       = $::boattr::params::lan_ip,
  $wired_iface  = $::boattr::params::wired_iface
) inherits boattr::params
{
  $packages = ['bridge-utils']
  package {$packages : ensure => present }
  
  case $::is_virtual {
    'false' : {

      file {'/etc/network/interfaces' : 
        ensure  => present,
        content => template("${module_name}/interfaces"),
      }
    }
    'true' : { }
  }
}
