#!/bin/sh

git clone 'git@github.com:wix/import-cost.git' || (echo 'Failed to clone wix/import-cost' && exit)

echo 'Install import-cost with which package manager? [npm/yarn]'
read -r installer

if [ "$installer" != 'npm' ] && [ "$installer" != 'yarn' ]; then
    echo "Please enter either 'npm' or 'yarn'"
    exit
fi

cd import-cost || exit
eval "$installer install"
cd ..

cp src/index.js import-cost
