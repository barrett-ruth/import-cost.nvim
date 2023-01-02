#!/bin/sh

[ "$1" ] || (echo 'Must provide node.js package manager' && exit)

git clone 'git@github.com:wix/import-cost.git' || (echo 'Failed to clone wix/import-cost' && exit)

cd import-cost || exit
$1 install
cd ..

cp index.js import-cost
