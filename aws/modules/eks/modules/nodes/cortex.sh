#!/bin/bash
aws s3 cp s3://baton-central-dump/cortex-agent/Linux_850_rpm.tar.gz /home/ec2-user
tar -zvxf /home/ec2-user/Linux_850_rpm.tar.gz
sudo mkdir -p /etc/panw
sudo cp -r cortex.conf /etc/panw/
sudo yum install selinux-policy-devel -y
sudo yum install ./cortex-8.5.0.125392.rpm -y
sudo /opt/traps/bin/cytool endpoint_tags add ${cortex_tags}
sudo systemctl restart traps_pmd
sudo systemctl enable traps_pmd