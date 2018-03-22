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

main() {
    mkdir -p ${LIB_DIR}
    install_wum
    echo "Done!"
}

main
