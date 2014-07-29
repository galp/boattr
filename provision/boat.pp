
class packages {
  $packagelist = [ 'screen', 'emacs23-nox', 'puppet-el','curl','python-couchdb', 'python-smbus',' build-essential' ]
  $devpackagelist = ['i2c-tools]']
  
  package { $packagelist :
    ensure => installed,
  }
}
class dashboard {
  $rubypackages=['ruby1.9.1-dev','rubygems','bundler', 'nodejs']
  package { $rubypackages : ensure => installed
}
  package {'dashing' :
    ensure   => installed,
    provider => gem,
    require  => Package[$rubypackages],    
  }
  file  {'/root/.gemrc' :
    ensure  => file,
    content => 'gem: --no-ri --no-rdoc',
    }
}
class couchdb {
  package { 'couchdb' : ensure => installed}
  package {'couchrest' : ensure   => installed, provider => gem }

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
  class ap {
    
    $packages = ['hostapd', 'firmware-atheros']
    package {$packages : ensure => present }
    
    service { hostapd : ensure  => running, require => Package[$packages] }
    
    file {'/etc/hostapd/hostapd.conf' : 
      ensure  => present,
      content => template("teplates/hostapd/hostapd.conf"),
      notify  => Service['hostap'],
    }
  }
  class client {
    ###
  }
    
}

class users {
  ssh_authorized_key { 'mykey' :
    ensure => present,
    user   => root,
    type   => 'ssh-rsa',
    key    => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAlbfVzsjc6/n+nN6dTpihPNLJNVDgM1g5E+OcAj9ZSfS7eivAAzW5mEo0XrwBfeIGNxEOP9IiCXRyMTcQjilC1H0qQb3j6k3fFX+s+35bqAWuxWXbCLHHumgYAxHhEJxORl9L5ZKPWg125OKuk5UJmV6D2qE0SncbwymzAMqjFcxlhp6s3I+uvfa7Hp4s1ynaZYxW89vSMG1cG3j6Dv8+dsdHJH1mvkVP5NgyczC3d2j9u09TMqB/ugZJ5b8W/PGqvfeajFgROOVrQQNA/QrbY4SbtQsSy6sSjuQLHSjlc7sZ9E5XIwTeLVlZWfpMihAfBV7gicrYgcDi78uS8xSDCw==',
  }
}
class network {
  #
}
class dnsmasq {
  $subnet    = '192.168.100'
  $domain    = 'camp.dev'
  $interface = 'br0'
  $packages  = ['dnsmasq']

  package {$packages : ensure => present }
  service { 'dnsmasq' : ensure  => running,
    require => Package[$packages]
  }
  file {'/etc/dnsmasq.conf' : 
    ensure  => present,
    content => template("teplates/dnsmasq/dnsmasq.conf"),
    notify  => Service['dnsmasq'],
    }

  file 
  }
class boattr {
  package {'i2c' :
    ensure   => installed,
    provider => gem,
    #require  => Package[$rubypackages],    
  }
  
}

include users
#include storage
include packages
include couchdb
include boattr
