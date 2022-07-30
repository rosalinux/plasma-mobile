# !/bin/bash

cd ./rpm/
rm -rf BUILD BUILDROOT RPMS SRPMS plasma-*.tar.* *.buildlog
cd ./../
rsync -av --exclude='.git' --exclude='rpm' ./ ./plasma-phone-components-5.23.5
tar  -czf ./rpm/plasma-phone-components-5.23.5.tar.gz plasma-phone-components-5.23.5
rm -rf ./plasma-phone-components-5.23.5
cd ./rpm/
dnf builddep plasma-phone-components.spec
abb build --nodeps --target=aarch64-openmandriva-linux
cd ./../

