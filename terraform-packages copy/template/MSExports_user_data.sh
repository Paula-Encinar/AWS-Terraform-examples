Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash

set -ex
WORKDIR=/home/ec2-user
sudo yum update -y
sudo yum install docker -y
sudo yum -y install jq
sudo service docker start
sudo usermod -a -G docker ec2-user

if [[ "$(sudo docker ps -a)" ]]; then
    echo "Removing existing containers..."
    sudo docker stop $(sudo docker ps -aq) || true
    sudo docker rm -f $(sudo docker ps -aq) || true
else
    echo "No containers to remove."
fi

sudo docker run nginx

--//