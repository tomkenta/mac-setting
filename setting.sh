#!/bin/bash

## conform to ghq path setting
ANSIBLE_PATH=~/work/src/github.com/tomkenta/mac-setting

## install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

## clone repo
git clone https://github.com/tomkenta/mac-setting.git ${ANSIBLE_PATH}

## ansible
cd ${ANSIBLE_PATH}

## install apps (ansible) by brew
brew bundle

ansible-playbook -i inventory/localhost localhost.yml
