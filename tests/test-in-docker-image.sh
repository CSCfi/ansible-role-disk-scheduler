#!/usr/bin/env bash

SOURCE="${BASH_SOURCE[0]}"
RDIR="$( dirname "$SOURCE" )"
SUDO=`which sudo 2> /dev/null`
SUDO_OPTION=""
#SUDO_OPTION="--sudo"
OS_TYPE=${1:-}
OS_VERSION=${2:-}
ANSIBLE_VERSION=${3:-}

ANSIBLE_VAR=""
ANSIBLE_INVENTORY="tests/inventory"
ANSIBLE_PLAYBOOk="tests/test.yml"
#ANSIBLE_LOG_LEVEL=""
ANSIBLE_LOG_LEVEL="-v"
APACHE_CTL="apache2ctl"

if [ "$OS_TYPE" == "latest" ]; then
    echo "TEST: latest"
    export LATEST=1
fi

# if there wasn't sudo then ansible couldn't use it
if [ "x$SUDO" == "x" ];then
    SUDO_OPTION=""
fi

if [ "${OS_TYPE}" == "centos" ];then
    APACHE_CTL="apachectl"
    if [ "${OS_VERSION}" == "7" ];then
        ANSIBLE_VAR="apache_use_service=False"
    fi
fi

ANSIBLE_EXTRA_VARS=""
if [ "${ANSIBLE_VAR}x" == "x" ];then
    ANSIBLE_EXTRA_VARS=" -e \"${ANSIBLE_VAR}\" "
fi


cd $RDIR/..
printf "[defaults]\nroles_path = ../:roles\ncallback_whitelist = profile_tasks" > ansible.cfg
printf "" > ssh.config

function show_version() {

echo "TEST: show versions"
ansible --version
id
systemctl --no-pager
proc1comm=$(cat /proc/1/comm)
echo "TEST: proc1s comm is $proc1comm"

}

function tree_list() {

tree

}
function test_ansible_setup(){
    echo "TEST: ansible -m setup -i ${ANSIBLE_INVENTORY} --connection=local localhost"

    ansible -m setup -i ${ANSIBLE_INVENTORY} --connection=local localhost

}


function test_install_requirements(){
    if [ "$OS_TYPE" == "latest" ]; then

      echo "TEST: grep -v version: requirements.yml > requirements2.yml"
      grep -v version: requirements.yml > requirements2.yml
      echo "TEST: grep -A4 ansible-role-users requirements2.yml"
      grep -A4 ansible-role-users requirements2.yml

      echo "TEST: ansible-galaxy install -r requirements2.yml --force"
      ansible-galaxy install -r requirements2.yml --force ||(echo "requirements install failed" && exit 2 )

    else
      echo "TEST: grep -A4 ansible-role-users requirements.yml"
      grep -A4 ansible-role-users requirements.yml

      echo "TEST: ansible-galaxy install -r requirements.yml --force"
      ansible-galaxy install -r requirements.yml --force ||(echo "requirements install failed" && exit 2 )
    fi

}

function test_playbook_syntax(){
    echo "TEST: ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} --syntax-check"

    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} --syntax-check ||(echo "ansible playbook syntax check was failed" && exit 2 )
}

function test_playbook_check(){
    echo "TEST: ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} --check"

    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} --check ||(echo "playbook check failed" && exit 2 )

}

function test_playbook(){
    echo "TEST: ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS}"
    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} ||(echo "first ansible run failed" && exit 2 )

    echo "TEST: idempotence test! Same as previous but now grep for changed=0.*failed=0"
    ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOk} ${ANSIBLE_LOG_LEVEL} --connection=local ${SUDO_OPTION} ${ANSIBLE_EXTRA_VARS} || grep -q 'changed=0.*failed=0' && (echo 'Idempotence test: pass' ) || (echo 'Idempotence test: fail' && exit 1)
}
function extra_tests(){

    echo "TEST: cat /tmp/singularity/singularity.conf"
    cat /tmp/singularity/singularity.conf
}


set -e
function main(){
    show_version
#    tree_list
#    test_install_requirements
    test_ansible_setup
    test_playbook_syntax
    test_playbook
    test_playbook_check
    extra_tests

}

################ run #########################
main
