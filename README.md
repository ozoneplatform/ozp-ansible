ozp-ansible
=====================
## Quickstart
If you're in a hurry and just want a Vagrant box running all the OZP things,
do this:
* Install the latest versions of Virtualbox and Vagrant on your host
* `mv group_vars/all/vault_unencrypted.yml group_vars/all/vault.yml`
* `vagrant up` in this directory (this will take about 35 minutes)
* Access Center from your host at `https://localhost:4433/center/`,
    API docs at `https://localhost:4433/docs/`
* Point a clone of ozp-center or ozp-hud to the backend running at localhost:4433 `API_URL="https://localhost:4433/" npm start` 

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
* Ensure the server or VM that you will deploy OZP to has at least 2GB of
    memory - you will get very strange and unhelpful errors otherwise

## Installing Ansible
See the official Ansible docs for details. Some problems that we've seen
installing Ansible on a Centos 6.6 box:
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
OZP core team's Jenkins instance. We do not make these public. If you are
a member of the core dev team, you can use the `--ask-vault-pass` command
line option to decrypt the vault file. Otherwise, simply copy the provided
`vault_unencrypted.yml` file over top of `vault.yml`. The only consequence of
this is that you won't be able to connect to our Jenkins build server
to retrieve pre-built artifacts

We haven't had a particular need for Ansible's Hosts or Groups features yet,
so you may notice random group names and ad hoc sets of hosts.

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
that doesn't require you to install Ansible on your host machine, but both
provisioners are useful.

## Ansible Use Cases
Before running anything Ansible, source the Ansible environment script
to put ansible commands on your PATH: `source /path/to/ansible/hacking/env-setup`
### Build Everything from GitHub using Vagrant
"A Vagrant box running all of the OZP things, built from scratch via the
latest code on GitHub"

See the Quickstart section at the top of this README
### Install OZP on a Real Server Using Latest on GitHub
1. Install Ansible on your host
2. `mv group_vars/all/vault_unencrypted.yml group_vars/all/vault.yml`
3. Set `server_fqdn` and `server_port` as necessary
4. Create a hosts file (see hosts_local for example) for your server
5. `ansible-playbook site.yml -i <my_hosts> -u <my_username> -k --ask-become-pass`

If you only want to provision the server with dependencies (nginx, postgres, etc),
just run the `provision.yml` playbook instead of `site.yml`. The same logic
applies to other playbooks, so you can deploy/redeploy at a very granular
level

### Install part of OZP on a Vagrant box from your host
Let's say you've already gone through the Quickstart section and have a
Vagrant box up and running. Now you want to update the backend with the latest
from the master branch on GitHub. To do this, simply use the instructions above,
but select `hosts_vagrant` as the hosts file, use the username `vagrant` and
password `vagrant`, and use the `ozp_deploy_backend.yml` playbook instead of
`site.yml`.

You could also use this method to fully provision a Vagrant box from your
host without using any of the Vagrant/Ansible integrations. Just remove
the Ansible provisioning bit at the bottom of the Vagrantfile, then
`vagrant up`. When the box is up, run
`ansible-playbook site.yml -i hosts_vagrant -u vagrant -k --ask-become-pass`,
using `vagrant` for both the username and password

### Offline Installation
The "offline" mode is useful for provisioning a system without Internet access.
That said, we do assume that you have the following:
* local yum mirrors
* local npm mirrors

1. Look at `roles/offline/files/README.md` and ensure all of the
necessary files are located in that directory
2. Set `offline: true` in `group_vars/all/all.yml`
3. For all ozp things, set `download_from` to "local" in
    `roles/<ozp_xyz>/vars/main.yml`

### Test a Pull Request
Assuming you already have a box runnning OZP (if not, just use Ansible as
described previously):
* update `roles/<role-for-PR>/vars/main.yml` and change `download_from` to
    `github` and set the branch name to that of the PR
* run the necessary playbook
* validate the PR

Cases where this may not work:
* change being tested requires transitive dependency update (in package.json,
    for example) that was not committed to the branch

### Developer Setup
Developers typically want to edit code on their host and deploy to a target.
Vagrant provides a "Synced Folders" capability that should support this
workflow, since it not only supports sharing directories between a host box
and Vagrant target, but also allows you to control ownership settings

* Center code (contents of `dist/`) -> /usr/local/ozp/frontend/center, owned by
    user `nginx`. Same idea for hud, webtop, iwc, and demo_apps. Be mindful of
    `OzoneConfig.js`
* Backend code -> /usr/local/ozp/backend, owned by user ozp (be mindful of
    `ozp/settings.py`)
