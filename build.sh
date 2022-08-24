# !/bin/bash

cd ./rpm/
rm -rf BUILD BUILDROOT RPMS SRPMS plasma-*.tar.* *.buildlog
cd ./../
rsync -av --exclude='.git' --exclude='rpm' ./ ./plasma-phone-components-5.25.3
tar  -czf ./rpm/plasma-phone-components-5.25.3.tar.gz plasma-phone-components-5.25.3
rm -rf ./plasma-phone-components-5.25.3
cd ./rpm/
dnf builddep plasma-mobile.spec
abb build --nodeps --target=aarch64-openmandriva-linux
cd ./../