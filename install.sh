#!/bin/sh

if [ ! "$1" ]; then
    echo 'Must provide node.js package manager'
    exit
fi

git clone 'https://github.com/wix/import-cost.git' || (echo 'Failed to clone wix/import-cost' && exit)

cd import-cost || exit
$1 install
cd ..

cp index.js import-cost/index.js
