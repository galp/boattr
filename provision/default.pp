node default {

  class { 'boattr::packages':  devel => false } -> class { 'boattr::ntp': } -> class { 'boattr::users': }
  -> class { 'boattr': } -> class { 'boattr::dashing': } -> class { 'boattr::couchdb': }
  class { 'boattr::dnsmasq': }
}
