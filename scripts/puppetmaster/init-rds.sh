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

readonly DB_HOST=$2
readonly DB_PORT=$4
readonly DB_ENGINE=$6
readonly DB_VERSION=$8
readonly DB_USERNAME=${10}
readonly DB_PASSWORD=${12}

readonly DB_SCRIPTS_PATH="$(find artifacts -type d -name wso2is*)/dbscripts"

# databases
readonly UM_DB="WSO2_USER_DB"
readonly GOV_REG_DB="WSO2_GOV_REG_DB"
readonly CONFIG_REG_DB="WSO2_CONFIG_REG_DB"
readonly IDENTITY_DB="WSO2_IDENTITY_DB"
readonly BPS_DB="WSO2_BPS_DB"
readonly METRICS_DB="WSO2_METRICS_DB"
readonly POSTGRES_DB="wso2db"

function init_mysql_rds() {

    echo ">> Setting up MySQL databases ..."
    echo ">> Creating databases..."
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS $UM_DB; DROP DATABASE IF
    EXISTS $GOV_REG_DB; DROP DATABASE IF EXISTS $CONFIG_REG_DB; DROP DATABASE IF EXISTS $IDENTITY_DB; DROP DATABASE
    IF EXISTS $BPS_DB; DROP DATABASE IF EXISTS $METRICS_DB; CREATE DATABASE $UM_DB; CREATE DATABASE $GOV_REG_DB;
    CREATE DATABASE $CONFIG_REG_DB; CREATE DATABASE $IDENTITY_DB; CREATE DATABASE $BPS_DB; CREATE DATABASE $METRICS_DB;"
    echo ">> Databases created!"

    echo ">> Creating tables..."
    if [[ $DB_VERSION == "5.7*" ]]; then
        mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD -e "USE $UM_DB; SOURCE $DB_SCRIPTS_PATH/mysql5.7.sql;
        USE $GOV_REG_DB; SOURCE $DB_SCRIPTS_PATH/mysql5.7.sql; USE $CONFIG_REG_DB; SOURCE $DB_SCRIPTS_PATH/mysql5.7.sql;
        USE $IDENTITY_DB; SOURCE $DB_SCRIPTS_PATH/identity/mysql-5.7.sql; USE $BPS_DB; SOURCE $DB_SCRIPTS_PATH/bps/bpel/create/mysql5.7.sql;
        USE $METRICS_DB; SOURCE $DB_SCRIPTS_PATH/metrics/mysql.sql;"
    else
        mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD -e "USE $UM_DB; SOURCE $DB_SCRIPTS_PATH/mysql.sql;
        USE $GOV_REG_DB; SOURCE $DB_SCRIPTS_PATH/mysql.sql; USE $CONFIG_REG_DB; SOURCE $DB_SCRIPTS_PATH/mysql.sql;
        USE $IDENTITY_DB; SOURCE $DB_SCRIPTS_PATH/identity/mysql.sql; USE $BPS_DB; SOURCE $DB_SCRIPTS_PATH/bps/bpel/create/mysql.sql;
        USE $METRICS_DB; SOURCE $DB_SCRIPTS_PATH/metrics/mysql.sql;"
    fi
    echo ">> Tables created!"
}

function init_postgres_rds() {
    export PGPASSWORD=$DB_PASSWORD
    echo ">> Setting up Postgres databases ..."
    echo ">> Creating databases..."
    psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $POSTGRES_DB -c "DROP DATABASE IF EXISTS $UM_DB;"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $POSTGRES_DB -c "DROP DATABASE IF EXISTS $GOV_REG_DB;"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $POSTGRES_DB -c "DROP DATABASE IF EXISTS $CONFIG_REG_DB;"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $POSTGRES_DB -c "DROP DATABASE IF EXISTS $IDENTITY_DB;"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $POSTGRES_DB -c "DROP DATABASE IF EXISTS $BPS_DB;"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $POSTGRES_DB -c "DROP DATABASE IF EXISTS $METRICS_DB;"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $POSTGRES_DB -c "CREATE DATABASE $UM_DB;"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $POSTGRES_DB -c "CREATE DATABASE $GOV_REG_DB;"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $POSTGRES_DB -c "CREATE DATABASE $CONFIG_REG_DB;"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $POSTGRES_DB -c "CREATE DATABASE $IDENTITY_DB;"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $POSTGRES_DB -c "CREATE DATABASE $BPS_DB;"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USERNAME -d $POSTGRES_DB -c "CREATE DATABASE $METRICS_DB;"
    echo ">> Databases created!"

    echo ">> Creating tables..."
    psql -h $DB_HOST -p $DB_PORT -U $POSTGRES_USERNAME -d $UM_DB -f $DB_SCRIPTS_PATH/postgresql.sql
    psql -h $DB_HOST -p $DB_PORT -U $POSTGRES_USERNAME -d $GOV_REG_DB -f $DB_SCRIPTS_PATH/postgresql.sql
    psql -h $DB_HOST -p $DB_PORT -U $POSTGRES_USERNAME -d $CONFIG_REG_DB -f $DB_SCRIPTS_PATH/postgresql.sql
    psql -h $DB_HOST -p $DB_PORT -U $POSTGRES_USERNAME -d $IDENTITY_DB -f $DB_SCRIPTS_PATH/postgresql.sql
    psql -h $DB_HOST -p $DB_PORT -U $POSTGRES_USERNAME -d $BPS_DB -f $DB_SCRIPTS_PATH/postgresql.sql
    psql -h $DB_HOST -p $DB_PORT -U $POSTGRES_USERNAME -d $METRICS_DB -f $DB_SCRIPTS_PATH/postgresql.sql

    echo ">> Tables created!"
}

if [ $DB_ENGINE == "mysql" ]; then
    init_mysql_rds
else 
    init_postgres_rds
fi
