class boattr::packages (
  $devel = false
)
{
  
  $packagelist = [ 'screen', 'mosh' ]
  $devpackagelist = ['i2c-tools','emacs24-nox', 'puppet-el','curl',' build-essential']

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
