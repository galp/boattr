class boattr::apt (
  $board    = $::boattr::params::board,
)
{
  apt::conf { 'release':
    content  => 'APT::Default-Release "jessie";',
    priority => '01',
  }
  apt::conf { 'no_install_recommends':
    content  => 'APT::Install-Recommends "0";',
    priority => '50',
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
