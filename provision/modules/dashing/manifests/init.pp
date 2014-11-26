class dashing (
  $dashing_dir = '/root/dash'
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
    require => Package['couchdb'] }

}
