class boattr::storage (
  $data_dir      = $::boattr::params::data_dir,
  $data_dev      = $::boattr::params::data_dev,
  $data_fs_type  = $::boattr::params::data_fs_type,
) inherits boattr::params
{
  file { $data_dir : ensure => directory }
  if $data_dev {
    notice("Using ${data_dev} as storage")
    mount { $data_dir :
      ensure  => mounted,
      device  => "UUID=${data_dev}",
      atboot  => true,
      fstype  => $data_fs_type,
      options => 'defaults,data=writeback,noatime,nodiratime',
      require => File[$data_dir],
    }
  }
  else {
    notice('Using internal storage')
  }
}
