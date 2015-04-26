class boattr::packages (
  $devel = $::boattr::params::devel,
  ) inherits boattr::params
{
  require boattr::apt

  $packagelist       = [ 'screen', 'mosh','iptables','curl','bridge-utils','wireless-tools','locales']
  $rubypackagelist   = [ 'ruby','bundler','ruby-dev','zlib1g-dev','rubygems','build-essential','libc6-dev']
  $devpackagelist    = ['i2c-tools','emacs24-nox', 'puppet-el']
  $puppetpackagelist = ['puppet']

  
  apt::force { $puppetpackagelist: release => 'testing' }
  apt::force { $rubypackagelist: release => 'testing' }
  apt::force { $packagelist: release => 'testing' }


  case $devel {
    true: {
      notice('With some handy  packages')
      apt::force { $devpackagelist: release => 'testing' }
    }
    false: {
      package { $devpackagelist :
        ensure => absent,
      }
    }
    default: {}
  }
}
