class boattr::couchdb (
  $db_dir   = $::boattr::params::db_dir,
  $db_host  = $::boattr::params::db_host,
  $basename = $::boattr::params::basename
  ) inherits boattr::params
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
  cron { 'compact_couchdb_cron':
    command => "curl -H \"Content-Type: application/json\" -X POST  http://${db_host}:5984/${basename}-sensors/_compact",
    user    => root,
    hour    => '3',
    minute  => '0'
  }
}
