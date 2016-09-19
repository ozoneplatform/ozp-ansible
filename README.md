ozp-ansible
=====================

## Note
This is a fork of the ozp-ansible project from AML Development: https://github.com/aml-development/ozp-ansible.

This README only contains instructions for building the modified OZP SDK as well
as some important notes about this project and its Ansible build.  See the AML 
Development's ozp-ansible repository's README for a more thorough explanation of
Ansible, more options for running specific Ansible tasks, and basic notes about 
the ozp-ansible project.

## Deploying the OZP SDK
To deploy OZP, follw these steps:
* Install Virtualbox, Vagrant, and Ansible on your host (Ansible must be >= v2.0)
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

