Ansible
=====================

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
