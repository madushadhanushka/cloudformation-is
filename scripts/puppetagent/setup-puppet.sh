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

readonly PATTERN=$2

echo ">> Copy run.sh to /opt path"
cp scripts/puppetagent/run.sh /opt/

cd /opt
cat > deployment.conf <<EOF
product_name=wso2is
product_version=5.4.0
product_profile=default
environment=production
use_hieradata=true
platform=default
pattern=${PATTERN}
EOF

sleep 300

echo ">> Run puppet agent"
./run.sh

tryCount=1
while [  $tryCount -lt 5 ]; do
    puppet_state=$(../workspace/scripts/puppetagent/check-puppet.sh)
    echo "Puppet execution state: $puppet_state"
    if [ "$puppet_state" = "RUNNING" ]; then
        sleep 30
        printf "."
        continue
    elif [[ ("$puppet_state" = "FATAL" || "$puppet_state" = "FAILURE" || "$puppet_state" = "UNKNOWN") ]]; then
        echo ">> Puppet execution failed or status unknown."
        if [ $tryCount -lt 5 ]; then
            echo ">> retrying .."
        else
           echo ">> Tried for maximum no of attempts."
           break
        fi
    elif [ "$puppet_state" = "SUCCESS" ]; then
        echo ">> Puppet execution is success."
        break
    fi

    sleep 180
    echo ">> Run puppet agent"
    ./run.sh
    let tryCount=tryCount+1
done



