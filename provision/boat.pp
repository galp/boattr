
class packages {
  $packagelist = [ 'screen', 'emacs23-nox', 'curl' ]
  package { $packagelist : ensure => installed}
}

class couchdb {
  package { 'couchdb' : ensure => installed}
}

class storage (
 $datadir = '/data',
 $device  = '/dev/sdb1' )
{
  file { $datadir : ensure => directory }
  mount { $datadir : 
   device  => $device,
   ensure  => mounted,
   atboot  => true,
   fstype  => ext4,
   options => 'defaults,data=writeback,noatime,nodiratime',
   require => File[$datadir],
  }
}

class wireless (
  $ssid = 'boat',
  $channel = '8')
{
  $packages = ['hostapd', 'firmware-atheros']
  package {$packages : ensure => present }

  service { hostapd : ensure  => running, require => Package[$packages] }

  file {'/etc/hostapd/hostapd.conf' : 
   ensure  => present,
   content => template("teplates/hostapd/hostapd.conf"),
   notify  => Service['hostap'],
   }
}

class network {
  #
}
include storage
include packages
include couchdb