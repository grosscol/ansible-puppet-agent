#!/bin/bash

if [[ -z $1 || $1 = "-h" || $1 = "--help" ]]
then
  echo "Useage:"
  echo "  wrapper.sh path/to/inventory/file [... other ansible args]"
  exit 1
fi

INVENTORY_FILE=$1
shift

# Set up a temporary home for ansible related files and control paths.
#  AFS in the umich setup causes significant problems for running as a regular user.

ANSIBLE_TMP_HOME=/tmp/${USER}-ansible
mkdir -p /tmp/${USER}-ansible/control-paths

export ANSIBLE_LOCAL_TMP=${ANSIBLE_TMP_HOME}
export ANSIBLE_REMOTE_USER=root

# Will be supported config option in 2.3.0
export ANSIBLE_SSH_CONTROL_PATH_DIR=${ANSIBLE_TMP_HOME}/control-paths

export HOME=${ANSIBLE_TMP_HOME}

# Pass the inventory file in as the first arguement
ansible-playbook -i ${INVENTORY_FILE} agent.playbook.yml "$@"
