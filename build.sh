# !/bin/bash

cd ./rpm/
dnf builddep plasma-phone-components.spec
abb build --nodeps --target=aarch64-openmandriva-linux
cd ./../

