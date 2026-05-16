#!/bin/sh
set -e

if [ ! -f .nvm-prev ]; then
  echo "No saved version found (.nvm-prev)."
  exit 1
fi

VERSION=$(cat .nvm-prev)
rm .nvm-prev

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi

nvm use "$VERSION"
