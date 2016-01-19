ozp-ansible
=====================
## Quickstart
If you're in a hurry and just want a Vagrant box running all the OZP things,
do this:
* Install the latest versions of Virtualbox and Vagrant on your host
* `mv group_vars/all/vault_unencrypted.yml group_vars/all/vault.yml`
* `vagrant up` in this directory (this will take about 45 minutes)
* Access Center from your host at `https://localhost:4433/center/`,
    API docs at `https://localhost:4433/docs/`

## Introduction
Ansible is a simple IT automation tool that we are using for lots of things,
including:
* provision new staging/production/CI servers
* automatically redeploy our code on CI boxes after a new build
* provision Vagrant boxes for demos ("build and install the latest OZP things")
* provision Vagrant boxes for developers ("build and install some version
    of OZP things, and allow for easy redeployment of code from host machine")

Ansible is typically installed and executed on a host machine. Ansible then
uses SSH to execute a set of given instructions on one or more target machines.
It is also possible to install and run Ansible directly on a target machine.
The OZP team makes use of both techniques depending on the task at hand.

## Prerequisits
Although it depends on your use case, you will probably want to have the
following installed on your host machine:
* updated version of VirtualBox (other VM providers should work too, but
    VirtualBox is what the core team tests with)
* updated version of Vagrant

## Installing Ansible
See the official Ansible docs for details. We recommend using the latest
version of Ansible from their Git repository (as opposed to using a package
manager to install it). Some problems that we've seen installing Ansible
on a Centos 6.6 box:
* needed to remove `python-yaml` package and install PyYAML instead (got a
* weird 'dispose' error otherwise)
* `ansible-vault` kept complaining about an old version of pycrypto. Uninstalled
    both `pycrypto` and `pycrypto2.6` (via both yum and pip), then installed
    `pycrypto2.6` from its Python source. After doing so, had to add global
    read and execute permissions to `/usr/lib64/python2.6/site-packages/Crypto`.
    Finally, I had to `pip uninstall cryptography`. YMMV.

## General Notes About ozp-ansible
There are many top-level Ansible playbooks, making it easier to do what you
want:
* site - provision a box and deploy all the ozp things
  * provision - install ozp prereqs
    * nginx
    * postgres
    * python
    * ...
  * ozp_deploy - install and launch all ozp things
    * ozp_backend
    * ozp_center
    * ozp_webtop
    * ...

Any one of the above playbooks can be run by itself, making it easy to do things
like deploy ozp-center, or provision a server without installing OZP code.

`group_vars/all/vault.yml` is an encrypted file containing credentials for the
OZP core team's Jenkins instance. We do not make these public. This file
will need to be removed before running Ansible, else you will get errors
about it.

We haven't had a particular need for Ansible's Hosts or Groups features yet...

## Ansible Variables
* group_vars/all/all.yml
  * `server_fqdn`: localhost, unless this is a real server
  * `server_port`: typically 443 for real servers, or whatever port you're
    forwarding to port 443 on the guest VM
  * `offline` - if true, Ansible won't try to download stuff from the interwebs
  * jenkins stuff - items relevant to the OZP team's Jenkins instance. Not
    made public

* ozp variables (in most of the ozp_xyz roles)
  * `download_from` - download code from Jenkins (core team only), GitHub, or
    use a local tar file
  * `git_tag_or_branch_name` - as described
  * `reset_database` (ozp_backend only) - if true, flush the database

## Vagrant and Ansible
We typically use Vagrant to run VMs and Ansible to provision them. Vagrant
supports Ansible out of the box via two provisioners: Ansible remote
provisioner and Andible local provisioner.

It's easier to get started using the Ansible local provisioner, since
that doesn't require you to install Ansible on your host machine.

## Ansible Use Cases
### Build Everything from GitHub using Vagrant
"A Vagrant box running all of the OZP things, built from scratch via the
latest code on GitHub"

See the Quickstart section at the top of this README
### Install OZP on a Real Server Using Latest on GitHub
1. Install Ansible on your host
2.


### Provision a Vagrant box for OZP

### Reinstall ozp-center on Vagrant Box



Ansible files for setting up boxes to build and/or deploy OZP

roles:
* common (EPEL repo, vim)
* build-base (development tools, git)
* python-3
* postgres
* node
* nginx
* mysql
* php
* ozp-dir (create ozp user and /ozp dir)
* ozp-ssl-certs
* ozp-authorization
* ozp-backend
* ozp-center
* ozp-hud
* ozp-webtop
* ozp-iwc
* ozp-help
* ozp-demo-apps
* metrics

roles for build box (like Jenkins Slave):
* common (EPEL repo, vim)
* build-base (development tools, git)
* python-3
* postgres
* node
* nginx
* mysql
* php

roles for deploy box:
* all of them

Running a playbook:
If using ansible from source, just update the git repo and `source ./hacking/env-setup` before running any ansible commands

`ansible-playbook buildservers.yml -i ~/ozp/not-in-git/hosts_ci -u alan.ward -k --ask-become-pass`
