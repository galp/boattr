class boattr::dashing (
  $dashing_parent_dir = '/root',
  $name               = 'boattr-dash',
  $auth_token         = 'YOUR_AUTH_TOKEN'
)
{
  
  package {'dashing' :
    ensure   => installed,
    provider => gem,
    require  => Package['nodejs']
  }
  package {'nodejs' :
    ensure  => installed,
  }

  file {'/etc/init.d/dashing' : 
    ensure  => present,
    mode    => 0755,
    content => template("${module_name}/dashing-service.erb"),
    notify  => Service['dashing'],
  }
  service {'dashing' :
    ensure => running,
    require => [File['/etc/init.d/dashing'], Exec['install_dashing']],
  }

  exec {'install_dashing' :
    command  => "dashing new $name",
    path     => $path,
    cwd      => $dashing_parent_dir,
    creates  => "$dashing_parent_dir/$name",
    require  => Package['dashing'],
  }  
  exec {'bundle_dashing' :
    command  => 'bundle',
    path     => $path,
    cwd      => "${dashing_parent_dir}/${name}",
    creates  => "$dashing_parent_dir/$name",
    require  => Exec['install_dashing'],
    notify   => Service['dashing'],
  }  

  file { "$dashing_parent_dir/$name/dashboards/boattr.erb":
    ensure  => present,
    require => Exec['install_dashing']
  }
}
