#boattr 
Some sort of project to manage off-grid systems

More details [here](http://ag.kiben.net/blog/2014/06/21/boattr/)


#provisioning

At the moment we need a BeagleBone Black (BBB) with debian. Recent
revisions (the ones with 4GB eMMC ) come with debian as default. If
you have an older one you will have to install it yourself.

Connect to the BBB with ssh. We assume You have debian wheezy already installed. For the following steps you have to be root. 
Make sure there is internet connectivity as well.

##change the hostname 
replace name in /etc/hostname and /etc/hosts. A restart is required after this step or before running puppet below.

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
##clone the  repo

``` 
cd /root/
git clone git://github.com/galp/boattr.git
cd boattr
```
##customise puppet

Have a look in provision/default.pp. You can either modify the
'default' node definition in this file or copy one of the blocks that looks more
suitable to a different file called $HOSTNAME.pp in the same directory.  Change
the node name in the file along with anything else required.
Make sure the fully quilified  dns names much.

##run puppet to provision all the components

Run puppet like below pointing to the right file.
```
puppet apply --modulepath="/root/boattr/provision/modules/:/etc/puppet/modules/"  --hiera_config="/root/boattr/hiera/hiera.yaml" --verbose  provision/default.pp
```
It might take a few runs until all dependencies are resolved and you should have all the components installed.

# boattr setup
## config file
Boattr in this context is the ruby program that runs every minute
collecting data from sensors, analyzing and sending to db and
dashboard among other things.

There is a configuration file that we need to edit. This file is
located at /root/boattr/config.yml. By default it does not exists so
we can use the config_sample.yml as a starting point.

```cp /root/boattr/config_sample.yml /root/boattr/config.yml```

