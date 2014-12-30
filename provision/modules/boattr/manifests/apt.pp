class boattr::apt {
  
  class { '::apt::release':
    release_id => 'wheezy',
  }
  class { '::apt': purge_sources_list => true }
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
    include_deb       => true
  }
  apt::source { 'debian_stable':
    comment           => 'uk debian stable mirror',
    location          => 'http://ftp.uk.debian.org/debian/ ',
    release           => 'stable',
    repos             => 'main contrib non-free',
    include_deb       => true
  }
  apt::source { 'security':
    comment           => 'debian security',
    location          => 'http://security.debian.org/',
    release           => 'wheezy/updates',
    repos             => 'main contrib non-free',
    required_packages => 'debian-keyring debian-archive-keyring',
    include_deb       => true
  }

}
