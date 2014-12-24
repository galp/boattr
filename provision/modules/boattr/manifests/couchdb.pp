class boattr::couchdb (
  $db_dir  = '/var/lib/couchdb/1.2.0',
  $db_host = 'localhost'
)

{
  package { 'couchdb' : ensure => installed}
  package {'couchrest' : ensure   => installed, provider => gem }
  file {'/etc/couchdb/local.ini' : 
    ensure  => present,
    content => template("${module_name}/local.ini"),
    notify  => Service['couchdb'],
  }
  service {'couchdb' : ensure => running, require => Package['couchdb'] }
}
