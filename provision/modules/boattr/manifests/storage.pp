class boattr::storage (
 $data_dir  = $::boattr::params::data_dir,
 $data_dev  = $::boattr::params::data_dev
) inherits boattr::params
{
  file { $data_dir : ensure => directory }
  case $::is_virtual {
    'false' : {
      mount { $data_dir : 
        device  => "UUID=${data_dev}",
        ensure  => mounted,
        atboot  => true,
        fstype  => auto,
        options => 'defaults,data=writeback,noatime,nodiratime',
        require => File[$data_dir],
      }
    }
    'true' : { }
  }
}
