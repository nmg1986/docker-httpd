#!/bin/bash

set -ex

REPO_PATH=$(env | grep REPO_PATH | cut -d= -f2)
BRANCH=$(env | grep BRANCH | cut -d= -f2)
ROOT_PATH=$(env | grep ROOT_PATH | cut -d= -f2)
APP_ENV=$(env | grep APP_ENV | cut -d= -f2)
SSH_KEY=$(env | grep SSH_KEY | cut -d= -f2)
LOG_FILE="/opt/start.log"

if [ -z "${REPO_PATH}" -o "${REPO_PATH}" == " " ];then 
    echo "REPO-PATH is NULL" >> $LOG_FILE
    return 
fi

if [ -z "${BRANCH}" -o "${BRANCH}" == " " ];then
    echo "BRANCH is NULL" >> $LOG_FILE
    return
fi

inject_ssh_key()
{
    echo "Inject ssh key" >> $LOG_FILE
    ssh_dir="/root/.ssh" 
    if [ ! -d $ssh_dir ];then
       mkdir -p $ssh_dir 
    fi
    authorized_keys_file="${ssh_dir}/authorized_keys"
    echo "${SSH_KEY}" >> ${authorized_keys_file}
    rsa_pub="${ssh_dir}/id_rsa.pub"
    echo "${SSH_KEY}" >> ${rsa_pub}
    echo "Done" >> $LOG_FILE
}

copy_code()
{
    echo "Copy code" >> $LOG_FILE
    cd /mnt
    #hg clone $REPO_PATH
    #repo_name=$(basename $REPO_PATH)
    #cd $repo_name 
    #hg update $BRANCH
    case $APP_ENV in
        config-dev)
            mv config-dev config
            ;;
        config-qa)
            mv config-qa config
            ;;
        config-st)
            mv config-st config
            ;;
        config-pub)
            mv config-pub config
            ;;
        config-prod)
            mv config-prod config
            ;;
        *)
            break 
            ;;
    esac
    cd ..
    rm -rf $ROOT_PATH
    cp -rf /mnt $ROOT_PATH
    echo "Done" >> $LOG_FILE
}

main()
{
    if [ -d $ROOT_PATH ];then
        inject_ssh_key
        copy_code
    fi
}

echo "Start Main APP" >> $LOG_FILE
main && /usr/bin/supervisord 
echo "Done" >> $LOG_FILE
