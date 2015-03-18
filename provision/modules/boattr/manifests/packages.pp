class boattr::packages (
  $devel = $::boattr::params::devel,
  ) inherits boattr::params
{
  require boattr::apt

  $packagelist     = [ 'screen', 'mosh','iptables','curl']
  $rubypackagelist = [ 'ruby','bundler','ruby-dev','zlib1g-dev','rubygems','build-essential','libc6-dev']
  $devpackagelist  = ['i2c-tools','emacs24-nox', 'puppet-el']

  apt::force { $rubypackagelist: release => 'testing' }
  package { $packagelist : ensure => installed }

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
