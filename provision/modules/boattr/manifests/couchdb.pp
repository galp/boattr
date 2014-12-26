class boattr::couchdb (
  $db_dir  = '/data/couchdb',
  $db_host = 'localhost'
)

{
  package { 'couchdb' : ensure => installed}
  package {'couchrest' : ensure   => installed, provider => gem }
  file {'/etc/couchdb/local.ini' : 
    ensure  => present,
    content => template("${module_name}/local.ini"),
    notify  => Service['couchdb'],
    require => Package['couchdb'],
  }
  file { $db_dir :
    ensure => directory,
    owner  => 'couchdb',
    group  => 'couchdb',
    }
  service {'couchdb' :
    ensure =>  running,
    require => [ Package['couchdb'],File[$db_dir]]
  }
}
