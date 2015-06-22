class boattr::packages (
  $devel = $::boattr::params::devel,
  ) inherits boattr::params
{
  require boattr::apt

  $packagelist       = [ 'screen', 'mosh','iptables','curl','bridge-utils','wireless-tools','locales','usb-modeswitch','i2c-tools','dbus','git','wpasupplicant','usbutils']
  $rubypackagelist   = [ 'ruby','bundler','ruby-dev','zlib1g-dev','rubygems','build-essential','libc6-dev']
  $devpackagelist    = ['emacs24-nox', 'puppet-el']
  $puppetpackagelist = ['puppet','hiera']

  
  package { $puppetpackagelist: ensure => installed }
  package { $rubypackagelist: ensure => installed }
  package { $packagelist: ensure => installed }


  case $devel {
    true: {
      notice('With some handy  packages')
      package { $devpackagelist: ensure => installed }
    }
    false: {
      package { $devpackagelist :
        ensure => absent,
      }
    }
    default: {}
  }
}
