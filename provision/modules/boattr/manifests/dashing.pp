class boattr::dashing (
  $basename               = $::boattr::params::basename,
  $dash_parent_dir         = $::boattr::params::dash_parent_dir,
  $dash_name               = $::boattr::params::dash_name,
  $dash_auth_token         = $::boattr::params::dash_auth,
) inherits boattr::params
{
  require boattr::apt
  $packages = ['nodejs','libv8-3.14.5','libssl-dev']
  package {'dashing' :
    ensure   => installed,
    provider => gem,
    require  => Package[$packages]
  }
  package { $packages :
    ensure  => installed,
  }
  file {'/etc/systemd/system/dashing.service' : 
    ensure  => present,
    mode    => '0755',
    content => template("${module_name}/dashing_service.erb"),
    notify  => Service['dashing'],
  }
  service {'dashing' :
    ensure => running,
    enable => true,
    require => [File['/etc/systemd/system/dashing.service'], Exec['install_dashing'],Package['nodejs']],
  }

  exec {'install_dashing' :
    command  => "dashing new ${dash_name}",
    path     => $path,
    cwd      => $dash_parent_dir,
    creates  => "${dash_parent_dir}/${dash_name}",
    require  => Package['dashing'],
    notify   => Exec['bundle_dashing'],
  }  
  exec {'bundle_dashing' :
    command  => 'bundle',
    path     => $path,
    cwd      => "${dash_parent_dir}/${dash_name}",
    creates  => "${dash_parent_dir}/${dash_name}/Gemfile.lock",
    require  => Exec['install_dashing'],
    notify   => Service['dashing'],
  }  

  file { "${dash_parent_dir}/${dash_name}/dashboards/${basename}.erb":
    ensure  => present,
    content => template("${module_name}/dashing_dash.erb"),
    require => Exec['install_dashing']
  }
  file { "${dash_parent_dir}/${dash_name}/config.ru":
    ensure  => present,
    content => template("${module_name}/dashing_config_ru.erb"),
    require => Exec['install_dashing']
  }

}
