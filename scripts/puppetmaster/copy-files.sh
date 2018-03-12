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

#readonly WSO2_IS_DISTRIBUTION_FILE="$(find downloads -type f -name wso2is*)"
readonly WSO2_IS_DISTRIBUTION_FILE="$(find artifacts -type d -name wso2is* -printf "%f\n")"
readonly JDK_FILE="$(find downloads/jdk -type f -name jdk*)"
readonly JDBC_FILE="$(find downloads/jdbc -type f -name *.jar)"

echo ">> Copy WSO2 IS Distribution to /etc/puppet/environments/production/modules/wso2is/files"
mv artifacts/${WSO2_IS_DISTRIBUTION_FILE} artifacts/wso2is-5.4.0
cd artifacts
zip -r wso2is-5.4.0.zip wso2is-5.4.0/
cd ..
cp artifacts/wso2is-5.4.0.zip /etc/puppet/environments/production/modules/wso2is/files
echo ">> Copy JDK to /etc/puppet/environments/production/modules/wso2base/files"
cp $JDK_FILE /etc/puppet/environments/production/modules/wso2base/files
echo ">> Copy JDBC to /etc/puppet/environments/production/modules/wso2is/files/configs/repository/components/lib"
cp $JDBC_FILE /etc/puppet/environments/production/modules/wso2is/files/configs/repository/components/lib