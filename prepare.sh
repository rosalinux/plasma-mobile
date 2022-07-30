# !/bin/bash

rsync -av --exclude='.git' --exclude='rpm' ./ ./plasma-phone-components-5.23.5
tar  -czf ./rpm/plasma-phone-components-5.23.5.tar.gz plasma-phone-components-5.23.5
rm -rf ./plasma-phone-components-5.23.5
