class boattr::apt (
  $board    = $::boattr::params::board,
)
{
  apt::conf { 'release':
    content  => 'APT::Default-Release "jessie";',
    priority => '01',
  }
  class { '::apt': purge => { 'sources.list' => true} }
  
  file { '/etc/apt/apt.conf.d/50no_install_recommends':
    ensure => present,
    content => 'APT::Install-Recommends "0";',
  }
  apt::source { 'debian_testing':
    comment           => 'uk debian testing mirror',
    location          => 'http://ftp.uk.debian.org/debian/ ',
    release           => 'testing',
    repos             => 'main contrib non-free',
    required_packages => 'debian-keyring debian-archive-keyring',
    include           => { 'deb' => true }
  }
  apt::source { 'debian_unstable':
    comment           => 'uk debian unstable mirror',
    location          => 'http://ftp.uk.debian.org/debian/ ',
    release           => 'unstable',
    repos             => 'main contrib non-free',
    required_packages => 'debian-keyring debian-archive-keyring',
    include           => { 'deb' => true }
  }

  apt::source { 'debian_stable':
    comment           => 'uk debian stable mirror',
    location          => 'http://ftp.uk.debian.org/debian/ ',
    release           => $::lsbdistcodename,
    repos             => 'main contrib non-free',
    include           => { 'deb' => true }
  }
  apt::source { "${::lsbdistcodename}_updates":
    comment           => 'debian updates',
    location          => 'http://ftp.uk.debian.org/debian/ ',
    release           => "${::lsbdistcodename}-updates",
    repos             => 'main contrib non-free',
    include           => { 'deb' => true }
  }

  apt::source { 'security':
    comment           => 'debian security',
    location          => 'http://security.debian.org/',
    release           => "${::lsbdistcodename}/updates",
    repos             => 'main contrib non-free',
    include           => { 'deb' => true }
  }

  case $board {
    'BeagleBoneBlack': {
      apt::source { 'beaglebone_debian':
        comment           => 'beaglebone debian',
        location          => '[arch=armhf] http://repos.rcn-ee.net/debian/',
        release           => "${::lsbdistcodename}",
        repos             => 'main',
        include           => { 'deb' => true }
      }
    }
    default: {}
  }
}
