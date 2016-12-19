ozp-ansible
=====================

## Note
This is a fork of the ozp-ansible project from AML Development: https://github.com/ozoneplatform/ozp-ansible.

This README only contains instructions for building the modified OZP SDK as well
as some important notes about this project and its Ansible build.  See the AML
Development's ozp-ansible repository's README for a more thorough explanation of
Ansible, more options for running specific Ansible tasks, and basic notes about
the ozp-ansible project.

## Deploying the OZP SDK
See the bottom of this README for detailed instructions on installing
Vagrant, Ansible, and Virtualbox

To deploy OZP, follw these steps:
* Install Vagrant, Ansible, and Virtualbox on your host (Ansible must be >= v2.0)
* `git clone` this repository to your host
* Update `roles/cas/vars/main.yml` with the correct values for the local Active Directory installation (optional if not using AD)
* Update `group_vars/all/all.yml` with the correct `git_host` URL pointing to your OZP module repositories
* `vagrant up` in this directory (this will take about 35-45 minutes)
* Access Center from your host at `https://localhost:4440/center/`, API docs at `https://localhost:4440/docs/`
* Note: You may need to first navigate directly to CAS `(https://localhost:8443/cas/login)` to accept the certificate

## Ansible Variables
* inventory variables
  * `site_fqdn` - entry point to the site
  * `db_fqdn` - database server fqdn
  * `auth_fqdn` - authorization server fqdn
  * `image_fqdn` - image server fqdn

* group_vars/all/all.yml
  * `git_host` - the host URL for the OZP repositories
  * `site_port`: typically 443 for real servers, or whatever port you're
    forwarding to port 443 on the guest VM
  * `offline` - if true, Ansible won't try to download stuff from the interwebs
  * `pki_login` - if true, requires client certificate to login, else use
    BasicAuth (username/password)
  * jenkins stuff - items relevant to the OZP team's Jenkins instance. Not
    made public

* ozp variables (in most of the ozp_xyz roles)
  * `download_from` - download code from Jenkins (core team only), GitHub, or
    use a local tar file
  * `git_tag_or_branch_name` - as described
  * `reset_database` (ozp_backend only) - if true, flush the database

*NOTE*: Any variables defined in `group_vars/all/all.yml` (or any group for
that matter) will take precedence over variables defined in Inventory files.

## Sample Users
The following users are included in the CAS configuration provided in the OZP SDK.

Below are usernames that are part of our sample data (defined in
`ozp-backend/ozpcenter/scripts/sample_data_generator.py`) (password for all users is `password`):

**Users:**
- aaronson (miniluv)
- jones (minitrue)
- rutherford (miniplenty)
- syme (minipax)
- tparsons (minipax, miniluv)
- charrington (minipax, miniluv, minitrue)

**Org Stewards:**
- wsmith (minitrue, stewarded_orgs: minitrue)
- julia (minitrue, stewarded_orgs: minitrue, miniluv)
- obrien (minipax, stewarded_orgs: minipax, miniplenty)

**Admins:**
- bigbrother (minipax)
- bigbrother2 (minitrue)

## Other Notes
If you get an ssh error, you may need to add/set `host_key_checking = false`
in your Ansible config, typically located at `/etc/ansible/ansible.cfg`

## Installing Vagrant, Ansible, and Virtualbox
The following steps were applied on CentOS 6.8 VM in BAH environment.

**Vagrant Installation**

[root@OZP-CentOS home]# cd /srv

[root@OZP-CentOS srv]# ls

[root@OZP-CentOS srv]# wget https://releases.hashicorp.com/vagrant/1.8.4/vagrant_1.8.4_x86_64.rpm

[root@OZP-CentOS srv]# rpm -ivh vagrant_1.8.4_x86_64.rpm


**Ansible Installation**

[root@OZP-CentOS yum.repos.d]# yum install epel-release

[root@OZP-CentOS yum.repos.d]# yum install ansible


**Virtualbox Installation**

[root@OZP-CentOS srv]# cd /etc/yum.repos.d/

[root@OZP-CentOS yum.repos.d]# wget http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo

Output of following commands version numbers should match:

[root@OZP-CentOS yum.repos.d]# rpm -qa kernel |sort -V |tail -n 1

kernel-2.6.32-642.3.1.el6.x86_64

[root@OZP-CentOS yum.repos.d]# uname -r 2.6.32-642.3.1.el6.x86_64

[root@OZP-CentOS yum.repos.d]# rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm

[root@OZP-CentOS yum.repos.d]# yum install binutils gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel dkms

[root@OZP-CentOS yum.repos.d]# yum install VirtualBox-5.0

[root@OZP-CentOS yum.repos.d]# service vboxdrv setup

[root@OZP-CentOS yum.repos.d]# usermod -a -G vboxusers username

[root@OZP-CentOS yum.repos.d]# VirtualBox
