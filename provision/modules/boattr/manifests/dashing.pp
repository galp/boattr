class boattr::dashing (
  $dash_parent_dir         = $::boattr::params::dash_parent_dir,
  $dash_name               = $::boattr::params::dash_name,
  $dash_auth_token         = $::boattr::params::dash_auth_token,
)
{
  require boattr::apt
  $packages = ['nodejs','libv8-3.14.5','libc6-dev','libssl-dev','zlib1g-dev']
  package {'dashing' :
    ensure   => installed,
    provider => gem,
    require  => Package[$packages]
  }
  package { $packages :
    ensure  => installed,
    require => Apt::Force['libc6']
  }
  apt::force { 'libc6':
    release     => 'testing',
    #require => Apt::Source['debian_unstable'],
  }
  file {'/etc/init.d/dashing' : 
    ensure  => present,
    mode    => 0755,
    content => template("${module_name}/dashing-service.erb"),
    notify  => Service['dashing'],
  }
  service {'dashing' :
    ensure => running,
    require => [File['/etc/init.d/dashing'], Exec['install_dashing'],Package['nodejs']],
  }

  exec {'install_dashing' :
    command  => "dashing new ${dash_name}",
    path     => $path,
    cwd      => $dash_parent_dir,
    creates  => "${dash_parent_dir}/${dash_name}",
    require  => Package['dashing'],
  }  
  exec {'bundle_dashing' :
    command  => 'bundle',
    path     => $path,
    cwd      => "${dash_parent_dir}/${dash_name}",
    creates  => "${dash_parent_dir}/${dash_name}",
    require  => Exec['install_dashing'],
    notify   => Service['dashing'],
  }  

  file { "${dash_parent_dir}/${dash_name}/dashboards/boattr.erb":
    ensure  => present,
    content => template("${module_name}/dashing_dash.erb"),
    require => Exec['install_dashing']
  }
}
