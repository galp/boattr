class boattr (
  $boattr_dir = '/root/boattr',
)
{
  vcsrepo { $boattr_dir:
      ensure   => present,
      provider => git,
      source   => "git://github.com/galp/boattr.git",
    }
}
