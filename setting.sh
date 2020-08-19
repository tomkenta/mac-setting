#!/bin/bash

## conform to ghq path setting
ANSIBLE_PATH=~/work/src/github.com/tomkenta/mac-setting

## install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

## install ansible
brew install ansible

## clone repo
git clone https://github.com/tomkenta/mac-setting.git ${ANSIBLE_PATH}

## ansible
cd ${ANSIBLE_PATH}
ansible-playbook -i inventory/localhost localhost.yml
