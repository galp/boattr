class boattr::apt {
  class { 'apt::release':
      release_id => 'wheezy',
    }

  apt::source { 'debian_unstable':
    comment           => 'uk debian unstable mirror',
    location          => 'http://ftp.uk.debian.org/debian/ ',
    release           => 'unstable',
    repos             => 'main contrib non-free',
    required_packages => 'debian-keyring debian-archive-keyring',
    key               => '8B48AD6246925553',
    key_server        => 'subkeys.pgp.net',
    pin               => '-10',
    include_deb       => true
  }
  apt::source { 'debian_stable':
    comment           => 'uk debian stable mirror',
    location          => 'http://ftp.uk.debian.org/debian/ ',
    release           => 'stable',
    repos             => 'main contrib non-free',
    required_packages => 'debian-keyring debian-archive-keyring',
    include_deb       => true
  }

}
