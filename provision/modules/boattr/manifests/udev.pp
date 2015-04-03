class boattr::udev (
  $phone_mac    = $::boattr::params::phone_mac,
  $wifi_mac     = $::boattr::params::wifi_mac,

  ) inherits boattr::params
{
  require boattr::apt
  $packages = ['udev']
  package {$packages : ensure => present }

  service { 'udev' :
    ensure  => running,
    enable  => true,
  }

  file {'/etc/udev/rules.d/10-boattr.rules' :
    ensure  => present,
    content => template("${module_name}/boattr_udev_rules.erb"),
    notify  => Service['udev']
  }

}
