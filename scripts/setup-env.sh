#!/usr/bin/env bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# Echoes all commands before executing.
set -o verbose

# This script setup environment for WSO2 product deployment
readonly OS=$(echo "$2" | awk '{print tolower($0)}')
readonly USERNAME=$(echo "$2" | awk '{print tolower($0)}')
readonly DB_ENGINE=$4
readonly WUM_USER=$6
readonly WUM_PASS=$8
readonly JDK=${10}
readonly LIB_DIR=/home/${USERNAME}/lib
readonly TMP_DIR=/tmp

install_wum() {

    echo "127.0.0.1 $(hostname)" >> /etc/hosts
    if [ $OS = "ubuntu" ]; then
        wget -P ${LIB_DIR} https://product-dist.wso2.com/downloads/wum/1.0.0/wum-1.0-linux-x64.tar.gz
    elif [ $OS = "centos" ]; then
        curl https://product-dist.wso2.com/downloads/wum/1.0.0/wum-1.0-linux-x64.tar.gz --output ${LIB_DIR}/wum-1.0-linux-x64.tar.gz
    fi
    cd /usr/local/
    tar -zxvf "${LIB_DIR}/wum-1.0-linux-x64.tar.gz"
    chown -R ${USERNAME} wum/

    echo ">> Adding WUM installation directory to PATH ..."
    if [ $OS = "ubuntu" ]; then
        if [ $(grep -r "usr/local/wum/bin" /etc/profile | wc -l  ) = 0 ]; then
            echo "export PATH=\$PATH:/usr/local/wum/bin" >> /etc/profile
        fi
        source /etc/profile
    elif [ $OS = "centos" ]; then
        if [ $(grep -r "usr/local/wum/bin" /etc/profile.d/env.sh | wc -l  ) = 0 ]; then
            echo "export PATH=\$PATH:/usr/local/wum/bin" >> /etc/profile.d/env.sh
        fi
        source /etc/profile.d/env.sh
    fi

    echo ">> Initializing WUM ..."
    sudo -u ${USERNAME} /usr/local/wum/bin/wum init -u ${WUM_USER} -p ${WUM_PASS}
}

get_java_home() {

    JAVA_HOME=${ORACLE_JDK8}
    if [[ ${JDK} = "ORACLE_JDK9" ]]; then
        JAVA_HOME=${ORACLE_JDK9}
    elif [[ ${JDK} = "ORACLE_JDK10" ]]; then
        JAVA_HOME=${ORACLE_JDK10}
    elif [[ ${JDK} = "OPEN_JDK8" ]]; then
        JAVA_HOME=${OPEN_JDK8}
    elif [[ ${JDK} = "OPEN_JDK9" ]]; then
        JAVA_HOME=${OPEN_JDK9}
    elif [[ ${JDK} = "OPEN_JDK10" ]]; then
        JAVA_HOME=${OPEN_JDK10}
    fi

    echo ${JAVA_HOME}
}

setup_java() {

    echo "Setting up java"
    #Default environment variable file is /etc/profile

    ENV_VAR_FILE=/etc/environment

    echo JDK_PARAM=${JDK} >> /home/ubuntu/java.txt
    echo ORACLE_JDK9=${ORACLE_JDK9} >> /home/ubuntu/java.txt

    if [[ $OS = "ubuntu" ]]; then
        source ${ENV_VAR_FILE}
        JAVA_HOME=$(get_java_home)
        echo "JAVA_HOME=$JAVA_HOME" >> ${ENV_VAR_FILE}
    elif [[ $OS = "centos" ]]; then
        ENV_VAR_FILE="/etc/profile.d/env.sh"
        source ${ENV_VAR_FILE}
        JAVA_HOME=$(get_java_home)
        echo "export JAVA_HOME=$JAVA_HOME" >> ${ENV_VAR_FILE}
    fi

    source ${ENV_VAR_FILE}
}

main() {
    mkdir -p ${LIB_DIR}
    install_wum
    setup_java
    echo "Done!"
}

main
