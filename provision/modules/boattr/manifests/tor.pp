class boattr::tor (
  $tor_gateway        = $::boattr::params::tor_gateway,
  $tor_hidden_service = $::boattr::params::tor_hidden_service,
  $basename           = $::boattr::params::basename,
  $lan_ip             = $::boattr::params::lan_ip
  ) inherits boattr::params
{
  
  $packagelist = ['tor','tor-geoipdb']
  package { $packagelist :
    ensure  => latest,
    require => Apt::Force['tor']
  }

  apt::source { 'tor_apt_repo':
    location   => 'http://deb.torproject.org/torproject.org',
    repos      => 'main',
    key        => '886DDD89',
  }
  apt::force { 'tor':
    release     => 'testing',
    require => Apt::Source['tor_apt_repo']
  }

  file { '/etc/tor/torrc':
    ensure  => present,
    content => template("${module_name}/boattr_torrc.erb"),
    require => Package[$packagelist],
    notify  => Service['tor'],
  }
  if $tor_hidden_service {
    file { "/var/lib/tor/${basename}" :
      ensure  => directory,
      owner   => debian-tor,
      group   => debian-tor,
      notify  => Service['tor'],
      require => Package['tor'],
    }
  }
  service { 'tor' :
    ensure => running,
    require => File['/etc/tor/torrc'],
  }
}
