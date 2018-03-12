#!/usr/bin/env bash
# ----------------------------------------------------------------------------
#
# Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# ----------------------------------------------------------------------------

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

set -e

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

echo ">> Sync time with NTP servers ..."
apt-get update
apt-get -y install ntp
service ntp restart

echo ">> Download and install puppet ..."
wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
dpkg -i puppetlabs-release-pc1-xenial.deb
apt-get update
apt-get -y install -f puppetmaster=3.8.5-2ubuntu0.1 puppetmaster-common=3.8.5-2ubuntu0.1
rm puppetlabs-release-pc1-xenial.deb
echo ">> Installed puppet version: $(puppet --version)"

echo "> Set hostname to puppetmaster"
hostname puppetmaster
echo $(hostname) >> /etc/hostname
echo "127.0.0.1 $(hostname)" >> /etc/hosts

echo ">> Update puppet.conf"
sed -i '/\[main\]/a dns_alt_names=puppetmaster,puppet\nenvironmentpath=$confdir/environments\nhiera_config=/etc/puppet/hiera.yaml' /etc/puppet/puppet.conf
sed -i '/\[master\]/a autosign=true' /etc/puppet/puppet.conf

echo ">> Clean all certificates"
puppet cert clean --all

echo ">> Restart puppet service"
service puppetmaster restart