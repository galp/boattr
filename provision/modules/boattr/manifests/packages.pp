class boattr::packages (
  $devel = false
)
{
  
  $packagelist = [ 'screen', 'mosh','iptables','curl' ]
  $devpackagelist = ['i2c-tools','emacs24-nox', 'puppet-el',' build-essential']

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
