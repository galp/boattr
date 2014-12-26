class boattr::storage (
 $datadir = '/data',
 $device  = '/dev/sdb1')
{
  file { $datadir : ensure => directory }
  case $::is_virtual {
    'false' : {
      mount { $datadir : 
        device  => $device,
        ensure  => mounted,
        atboot  => true,
        fstype  => ext2,
        options => 'defaults,data=writeback,noatime,nodiratime',
        require => File[$datadir],
      }
    }
    'true' : { }
  }
}
