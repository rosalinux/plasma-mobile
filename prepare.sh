# !/bin/bash
tar --exclude='./.git' --exclude='./rpm' -czf ./rpm/plasma-ayya-5.23.5.tar.gz .
mv plasma-ayya-5.23.5.tar.gz ./rpm/