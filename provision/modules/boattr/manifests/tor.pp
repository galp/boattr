class boattr::tor (
  $tor_gateway        = $::boattr::params::tor_gateway,
  $tor_hidden_service = $::boattr::params::tor_hidden_service,
  $basename           = $::boattr::params::basename,
  $lan_ip             = $::boattr::params::lan_ip
  ) inherits boattr::params
{
  $packagelist = ['tor','tor-geoipdb']
  package { $packagelist :
    ensure => latest,
  }
  file { '/etc/tor/torrc':
    ensure  => present,
    content => template("${module_name}/boattr_torrc.erb"),
    require => Package[$packagelist],
  }
  if $tor_hidden_service {
    file { "/var/lib/tor/${basename}" :
      ensure  => directory,
      owner   => debian-tor,
      group   => debian-tor,
      notify  => Service['tor'],
    }
  }
  service { 'tor' :
    ensure => running,
    require => File['/etc/tor/torrc'],
  }
}
