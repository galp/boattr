class boattr::dashing (
  $dashing_parent_dir = '/root',
  $dashing_name       = 'boattr',
)
{
  
  package {'dashing' :
    ensure   => installed,
    provider => gem,
    require  => File['/etc/init.d/dashing']
  }
  file {'/etc/init.d/dashing' : 
    ensure  => present,
    mode    => 0755,
    content => template("${module_name}/dashing-service.erb"),
    notify  => Service['dashing'],
  }
  service {'dashing' :
    ensure => running,
    require => File['/etc/init.d/dashing'] }

  exec {'install_dashing' :
    command  => "dashing new $dashing_name",
    cwd      => $dashing_dir,
    creates  => $dashing_name,
    require  => Package['dashing'],
    notify   => Service['dashing'],
  }
  file { "$dashing_parent_dir/$dashing_name/dashboards/boattr.erb":
    ensure  => present,
    require => Exec['install_dashing']
  }
}
