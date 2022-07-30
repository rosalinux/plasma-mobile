# !/bin/bash
rm -rf BUILD BUILDROOT RPMS SRPMS plasma-*.tar.* *.buildlog
tar --exclude='./.git' --exclude='./rpm' -czf plasma-ayya-5.23.5.tar.gz ./../.
B