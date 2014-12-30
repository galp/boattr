class boattr::packages (
  $devel = false
)
{
  require boattr::apt
  
  $packagelist = [ 'screen', 'mosh','iptables','curl' ]
  $devpackagelist = ['i2c-tools','emacs24-nox', 'puppet-el']

  package { $packagelist :
    ensure => installed,
  }
  
  case $devel {
    'true': {
      package { $devpackagelist :
        ensure => installed,
      }
    }
    'false' : { }
  }
}
