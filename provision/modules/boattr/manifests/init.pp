class boattr (
  $boattr_dir = '/root/boattr',
)
{
  vcsrepo { $boattr_dir:
    ensure   => present,
    provider => git,
    source   => "git://github.com/galp/boattr.git",
  }
  cron { 'boattr_run':
    command => "ruby ${boattr_dir}/${name}.rb >  /run/{$name}.log  2>&1",
    user    => root,
    hour    => '*',
    minute  => '*/1'
  }
  file {"${boattr_dir}/config.yml":
    ensure  => present,
    content => template("${module_name}/boattr_config.yml"),
    require => Vcsrepo[$boattr_dir],
  }
}
