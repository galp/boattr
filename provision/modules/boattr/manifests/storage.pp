class boattr::storage (
  $data_dir  = $::boattr::params::data_dir,
  $data_dev  = $::boattr::params::data_dev,
) inherits boattr::params
{
  file { $data_dir : ensure => directory }
  if $data_dev {
      mount { $data_dir :
        ensure  => mounted,
        device  => "UUID=${data_dev}",
        atboot  => true,
        fstype  => auto,
        options => 'defaults,data=writeback,noatime,nodiratime',
        require => File[$data_dir],
      }
  }
  else {
    notice('Using internal storage')
  }
}
