class boattr::packages (
  $devel = false
)
{
  require boattr::apt
  
  $packagelist     = [ 'screen', 'mosh','iptables','curl']
  $rubypackagelist = [ 'ruby','bundler','ruby-dev','rubygems']
  $devpackagelist  = ['i2c-tools','emacs24-nox', 'puppet-el']

  package { $packagelist :
    ensure => installed,
  }
  apt::force { $rubypackagelist:
    release     => 'testing',
  }

  package { $rubypackagelist :
    ensure => installed,
    require => Apt::Force[$rubypackagelist],
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
