class boattr (
  $boattr_dir = $::boattr::params::boattr_dir,
  $basename   = $::boattr::params::basename,
  $description   = $::boattr::params::description,
  $basename   = $::boattr::params::basename,
  $i2cBus   = $::boattr::params::i2cBus,
  $i2cAdcAddress   = $::boattr::params::i2cAdcAddress,
  $db_host   = $::boattr::params::db_host,
  $db_dir   = $::boattr::params::db_dir,
  $dash_dir   = $::boattr::params::dash_dir,
  $dash_host   = $::boattr::params::dash_host,
  $dash_auth   = $::boattr::params::dash_auth,
  $graph_host   = $::boattr::params::graph_host,
) inherits boattr::params
{
  vcsrepo { $boattr_dir:
    ensure   => present,
    provider => git,
    source   => "git://github.com/galp/boattr.git",
  }
  cron { 'boattr_run':
    command => "ruby ${boattr_dir}/${basename}.rb >  /run/{$basename}.log  2>&1",
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
