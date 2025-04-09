#!/bin/bash
sudo apt update -y
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

