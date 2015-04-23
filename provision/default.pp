node default {

  class { 'boattr::packages':  devel => false } -> class { 'boattr::ntp': } -> class { 'boattr::users': }
  -> class { 'boattr': } -> class { 'boattr::dashing': } -> class { 'boattr::couchdb': }
  -> class { 'boattr::udev': phone_mac => $phone_mac, wifi_mac => $wifi_mac }
  class { 'boattr::dnsmasq': }
 



}
node boattr-vagrant inherits default {

}
