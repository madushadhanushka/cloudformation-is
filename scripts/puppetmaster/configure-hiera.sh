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
readonly IS_HOST=$4
readonly DB_HOST=$6
readonly DB_PORT=$8
readonly DB_ENGINE=${10}
readonly DB_USERNAME=${12}
readonly DB_PASSWORD=${14}

readonly ACCESS_ID=${16}
readonly ACCESS_SECRET=${18}
readonly SECURITY_GROUP=${20}
readonly REGION=${22}

# databases
readonly UM_DB="WSO2_USER_DB"
readonly GOV_REG_DB="WSO2_GOV_REG_DB"
readonly CONFIG_REG_DB="WSO2_CONFIG_REG_DB"
readonly IDENTITY_DB="WSO2_IDENTITY_DB"
readonly BPS_DB="WSO2_BPS_DB"
readonly METRICS_DB="WSO2_METRICS_DB"

function get_database_driver_class() {

    local database_driver_class=""
    if [ $DB_ENGINE = "postgres" ]; then
        database_driver_class="org.postgresql.Driver"
    elif [ $DB_ENGINE = "mysql" ]; then
        database_driver_class="com.mysql.jdbc.Driver"
    elif [ $DB_ENGINE = "oracle-se" ]; then
        database_driver_class="oracle.jdbc.OracleDriver"
    elif [ $DB_ENGINE = "sqlserver-ex" ]; then
        database_driver_class="com.microsoft.sqlserver.jdbc.SQLServerDriver"
    elif [ $DB_ENGINE = "mariadb" ]; then
        database_driver_class="org.mariadb.jdbc.Driver"
    fi
    echo $database_driver_class
}

function get_jdbc_url_prefix() {

    local url_prefix=""
    if [ $DB_ENGINE = "postgres" ]; then
        url_prefix="postgresql"
    elif [ $DB_ENGINE = "mysql" ]; then
        url_prefix="mysql"
    elif [ $DB_ENGINE = "oracle-se" ]; then
        url_prefix="oracle:thin"
    elif [ $DB_ENGINE = "sqlserver-ex" ]; then
        url_prefix="sqlserver"
    elif [ $DB_ENGINE = "mariadb" ]; then
        url_prefix="mariadb"
    fi
    echo $url_prefix
}

function escape_special_characters() {

    local escaped="$1"

    # escape all backslashes
    escaped="${escaped//\\/\\\\}"
    # escape slashes
    escaped="${escaped//\//\\/}"
    # escape asterisks
    escaped="${escaped//\*/\\*}"
    # escape full stops
    escaped="${escaped//./\\.}"
    # escape [ and ]
    escaped="${escaped//\[/\\[}"
    escaped="${escaped//\[/\\]}"
    # escape ^ and $
    escaped="${escaped//^/\\^}"
    escaped="${escaped//\$/\\\$}"
    # remove newlines
    escaped="${escaped//[$'\n']/}"

    echo $escaped
}

function configure_hostname_configs() {

    echo ">> Configuring hostname related configurations ..."
    sed -i 's/^\(wso2::hostname:[[:space:]]*\).*$/\1'${IS_HOST}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\(wso2::mgt_hostname:[[:space:]]*\).*$/\1'${IS_HOST}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*sso_service_url:[[:space:]]*\).*$/\1https:\/\/'${IS_HOST}':443\/samlsso/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*consumer_service_url:[[:space:]]*\).*$/\1https:\/\/'${IS_HOST}':443\/acs/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
}

function configure_datasource_configs() {

    local db_driver_class=$(get_database_driver_class)
    local db_url_prefix=$(get_jdbc_url_prefix)
    local db_driver_binary="$(find downloads/jdbc/ -type f -name *.jar -printf "%f\n")"

    echo ">> Configuring datasource related configurations ..."
    sed -i 's/^\([[:space:]]*driver_class_name:[[:space:]]*\).*$/\1'${db_driver_class}'/g' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*username:[[:space:]]*\).*$/\1'${DB_USERNAME}'/g' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*password:[[:space:]]*\).*$/\1'${DB_PASSWORD}'/g' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*url:[[:space:]]*\).*WSO2_CONFIG_REG_DB.*$/\1jdbc:'${db_url_prefix}':\/\/'${DB_HOST}':'${DB_PORT}'\/'${CONFIG_REG_DB}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*url:[[:space:]]*\).*WSO2_GOV_REG_DB.*$/\1jdbc:'${db_url_prefix}':\/\/'${DB_HOST}':'${DB_PORT}'\/'${GOV_REG_DB}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*url:[[:space:]]*\).*WSO2_IDENTITY_DB.*$/\1jdbc:'${db_url_prefix}':\/\/'${DB_HOST}':'${DB_PORT}'\/'${IDENTITY_DB}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*url:[[:space:]]*\).*WSO2_USER_DB.*$/\1jdbc:'${db_url_prefix}':\/\/'${DB_HOST}':'${DB_PORT}'\/'${UM_DB}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*url:[[:space:]]*\).*WSO2_BPS_DB.*$/\1jdbc:'${db_url_prefix}':\/\/'${DB_HOST}':'${DB_PORT}'\/'${BPS_DB}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*url:[[:space:]]*\).*WSO2METRICS_DB.*$/\1jdbc:'${db_url_prefix}':\/\/'${DB_HOST}':'${DB_PORT}'\/'${METRICS_DB}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*-.*repository\/components\/lib\/\).*$/\1'${db_driver_binary}'\"/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
}

function configure_clustering_configs() {

    local access_id_esc=$(escape_special_characters ${ACCESS_ID})
    local access_secret_esc=$(escape_special_characters ${ACCESS_SECRET})

    echo ">> Configuring clustering related configurations ..."
    sed -i '/^[[:space:]]*membership_scheme: wka$/,+8 s/^/#/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i '/^.*membership_scheme: aws$/,+9 s/^#[[:space:]]//' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*access_key:[[:space:]]*\).*$/\1'${access_id_esc}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*secret_key:[[:space:]]*\).*$/\1'${access_secret_esc}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*security_group:[[:space:]]*\).*$/\1'${SECURITY_GROUP}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*host_header:[[:space:]]*.*\).*$/# \1/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*region:[[:space:]]*\).*$/\1'${REGION}'/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*tag_key:[[:space:]]*\).*$/\1name/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*tag_value:[[:space:]]*\).*$/\1is.wso2.domain/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml
    sed -i 's/^\([[:space:]]*local_member_port:[[:space:]]*\).*$/\15701/' /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml

    # Comment out hostheader optional parameter from template
    sed -i 's/^\(.*name="hostHeader".*\).*$/<!--\1-->/' /etc/puppet/environments/production/modules/wso2base/templates/clustering/aws.erb
   }

function configure() {

    echo ">> Configuring /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml"
    configure_hostname_configs
    configure_datasource_configs

    if [ $PATTERN = "pattern-2" ]; then
        configure_clustering_configs
    fi

    echo ">> Completed configuring /etc/puppet/hieradata/production/wso2/wso2is/${PATTERN}/default.yaml"
}


configure


