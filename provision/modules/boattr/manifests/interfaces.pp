class boattr::interfaces {
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
