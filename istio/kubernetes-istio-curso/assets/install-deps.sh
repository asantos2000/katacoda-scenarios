#!/bin/bash
apt -y update
apt -y install httpie
wget https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64
chmod +x stern_linux_amd64
mv stern_linux_amd64 /usr/local/bin/stern