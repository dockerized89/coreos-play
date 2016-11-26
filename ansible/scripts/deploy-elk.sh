#!/usr/bin/env bash

. scripts/init.sh

if [[ -f ../envs ]]; then
    . ../envs
else
    echo "No environment file present..exiting"
    exit 1
fi

inventory=${INVENTORY:-${INVENTORY_DIR}/vagrant}
ansible-playbook -i ${inventory} ${PLAYBOOKS_DIR}/central-logging.yml "$@"
exit 0

echo ""
echo ">> The central-logging are up and running inside the swarm cluster"
echo ""
