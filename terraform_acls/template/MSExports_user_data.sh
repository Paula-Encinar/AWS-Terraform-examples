#!/bin/bash

set -ex
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo yum -y install jq
sudo systemctl enable docker --now
sudo usermod -a -G docker ec2-user

docker run -d --name=grafana -p 3000:3000  --restart=unless-stopped grafana/grafana 


