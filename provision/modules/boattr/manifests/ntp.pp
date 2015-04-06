class boattr::ntp {

  require boattr::packages
  
  $packagelist = ['ntp']
  package { $packagelist :
    ensure  => latest,
  }
  
  file { '/etc/default/ntp':
    ensure  => present,
    content => 'NTPD_OPTS=\'-g -x\'',
    require => Package[$packagelist],
  }
  file { '/etc/ntp.conf':
    ensure  => present,
    content => template("${module_name}/boattr_ntp_conf.erb"),
    require => Package[$packagelist],
    notify  => Service['ntp'],
  }
  service { 'ntp' :
    ensure  => running,
    enable  => true,
    require => [File['/etc/ntp.conf'], File['/etc/default/ntp']],
  }
}
  
