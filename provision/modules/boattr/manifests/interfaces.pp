class boattr::interfaces {
  $packages = ['bridge-utils']
  package {$packages : ensure => present }
  
  file {'/etc/network/interfaces' : 
    ensure  => present,
    content => template("${module_name}/interfaces"),
  }
}
