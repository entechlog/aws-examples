#!/bin/bash
# Install required tools
sudo yum update -y
sudo yum install git -y

sudo yum -y groupinstall base "Development tools" -- \ setopt=group_package_types=mandatory,default,optional
sudo yum install openssl-devel -y
sudo yum install libcurl-devel -y

# Download, build and install cmake *unless cmake exists*
cd /home/ec2-user
wget https://cmake.org/files/v3.18/cmake-3.18.0.tar.gz
tar -xvzf cmake-3.18.0.tar.gz
cd cmake-3.18.0
./bootstrap
make
sudo make install

# Install kafkacat
git clone https://github.com/edenhill/kafkacat.git
cd kafkacat/
./bootstrap.sh
./kcat -h