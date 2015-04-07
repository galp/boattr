node default {
  $ip        = '192.168.8.1'
  $wifi_ssid = 'boattr'
  $wpa_psk   = 'c509d57e399416e0c5203a5023c65ad516bb4167632a8a24ba05c9e66b28ae09'
  $data_dev  = undef
  $phone_mac = undef # set with the tethered phone mac address.
  $wifi_mac  = undef # the mac of the wifi dongle. 

  
  class { 'boattr::packages':  devel => true } -> class { 'boattr::ntp': } -> class { 'boattr::users': }
  -> class { 'boattr':  lan_ip => $ip, wired_iface => $wired_iface, wifi_ssid => $wifi_ssid } -> class { 'boattr::dashing': }
  ->  class { 'boattr::udev': phone_mac => $phone_mac, wifi_mac => $wifi_mac }
  class { 'boattr::dnsmasq': }
  class { 'boattr::storage': } -> class { 'boattr::couchdb': }



}
node brain01 {
  $ip        = '192.168.8.1'
  $wifi_ssid = 'boat'
  $wpa_psk   = 'c509d57e399416e0c5203a5023c65ad516bb4167632a8a24ba05c9e66b28ae09'
  $data_dev  = 'c60fd6ce-2764-4713-aaf8-3bafbc7c5a89' # output from blkid 
  $phone_mac = undef # set with the tethered phone mac address.
  $wifi_mac  = undef # the mac of the wifi dongle. 
  class { 'ntp': iburst_enable => true }
  class { 'boattr::packages':  devel => true } -> class { 'boattr::users': } -> class { 'boattr': lan_ip => $ip,  wired_iface => $wired_iface} -> class { 'boattr::dashing': } ->  class { 'boattr::udev': phone_mac => $phone_mac, wifi_mac => $wifi_mac }
  class { 'boattr::dnsmasq': }
  class { 'boattr::storage': data_dev => $data_dev } -> class { 'boattr::couchdb': }
  
  
}

node brain02 {
  $ip     = '192.168.8.99'
  $lan_gw = '192.168.8.1'
  $data_dev = undef
  class { 'ntp': iburst_enable => true }
  class { 'boattr::packages':  devel => true } -> class { 'boattr::users': } -> class { 'boattr': lan_ip => $ip, wired_iface => $wired_iface} -> class { 'boattr::dashing': }
  class { 'boattr::dnsmasq': }
  class { 'boattr::storage': data_dev => $data_dev } -> class { 'boattr::couchdb': }

}
node boattr-vagrant {
  $ip          = '192.168.8.200'
  $lan_gw      = '192.168.8.1'
  $wired_iface = 'eth1'
  $wan_iface   = $wired_iface
  $wifi_ssid   = 'foo'
  class { 'boattr::packages': } -> class { 'boattr::users': devel => 'devel'} -> class { 'boattr': lan_ip => $ip, wired_iface => $wired_iface, wifi_ssid => $wifi_ssid }
  ->   class { 'boattr::storage':  } -> class { 'boattr::couchdb': } -> class { 'boattr::dashing': }
  class { 'boattr::dnsmasq': }

  
  
}
