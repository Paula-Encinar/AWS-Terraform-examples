#!/bin/bash

set -ex
WORKDIR=/home/ec2-user
ENVIRONMENT={ENVIRONMENT}
PROXY_HOST={PROXY_HOST}
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo yum -y install jq
sudo service docker start
sudo usermod -a -G docker ec2-user

