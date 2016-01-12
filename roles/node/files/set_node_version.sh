#!/bin/bash

# Script to set the version of node. Tools like nvm and n did not always work,
# so this is a brute-force approach

# Usage:
# Pass in the node version to use: source ./set_node_version 0.12.7 to
# use the given node version in your shell

# To add a new node install:

# cd $NODE_INSTALLS/
# mkdir 0.10.36; cd 0.10.36/
# wget https://nodejs.org/download/release/v0.10.36/node-v0.10.36-linux-x64.tar.gz
# tar -xzvf node-v0.10.36-linux-x64.tar.gz --strip 1

NODE_INSTALLS=/usr/local/node_versions
NODE_VERSION=$1
export NPM_CONFIG_PREFIX=$NODE_INSTALLS/$NODE_VERSION
export PATH=$NODE_INSTALLS/$NODE_VERSION/bin:$PATH:$HOME/bin
echo "Setting node version to $1"
