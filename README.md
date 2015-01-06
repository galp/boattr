#boattr 
Some sort of project to manage off-grid systems

More details [here](http://ag.kiben.net/blog/2014/06/21/boattr/)


#provisioning

Lets ssh to the  Beagle Bone Black that has  debian wheezy already installed and become root. 
Make sure there is internet connectivity.

##change the hostname 
replace name in /etc/hostname and /etc/hosts

##Install puppet and git

```
apt-get update
apt-get install puppet git
```

##Install some puppet modules we need
```
puppet module install puppetlabs/apt
puppet module install puppetlabs/ntp
puppet module install puppetlabs/vcsrepo 
```
clone the  repo
``` 
cd /root/
git clone git://github.com/galp/boattr.git
cd boattr
```
edit  provision/default.pp 

##run puppet to provision all the components
```

puppet apply --modulepath="/root/boattr/provision/modules/:/etc/puppet/modules/"  --verbose  provision/default.pp
```
