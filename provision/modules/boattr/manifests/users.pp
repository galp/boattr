class boattr::users (
  $devel       = $::boattr::params::devel,
  $boattr_user = $::boattr::params::boattr_user
  ) inherits boattr::params
{
  case $devel {
    true: {
      ssh_authorized_key { 'mykey' :
        ensure => present,
        user   => root,
        type   => 'ssh-rsa',
        key    => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAlbfVzsjc6/n+nN6dTpihPNLJNVDgM1g5E+OcAj9ZSfS7eivAAzW5mEo0XrwBfeIGNxEOP9IiCXRyMTcQjilC1H0qQb3j6k3fFX+s+35bqAWuxWXbCLHHumgYAxHhEJxORl9L5ZKPWg125OKuk5UJmV6D2qE0SncbwymzAMqjFcxlhp6s3I+uvfa7Hp4s1ynaZYxW89vSMG1cG3j6Dv8+dsdHJH1mvkVP5NgyczC3d2j9u09TMqB/ugZJ5b8W/PGqvfeajFgROOVrQQNA/QrbY4SbtQsSy6sSjuQLHSjlc7sZ9E5XIwTeLVlZWfpMihAfBV7gicrYgcDi78uS8xSDCw==',
      }
    }
    false : { }
  }
  @user { boattr: ensure => present }
  user { debian: ensure => absent }
  file { "${boattr_user}/.gemrc" :
    ensure   => file,
    content  => 'gem: --no-ri --no-rdoc',
  }
}

