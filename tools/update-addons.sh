#!/bin/bash

set -e -x

export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm


node "$(readlink -f "$(dirname "$0")")/update-addons.js"
