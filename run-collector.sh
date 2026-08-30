#!/bin/bash

cd /home/rafi/exam-collector || exit 1

ENVIRONMENT="$1"

if [ "$ENVIRONMENT" = "home" ]; then
    INVENTORY="inventory-home.ini"
elif [ "$ENVIRONMENT" = "lab" ]; then
    INVENTORY="inventory.ini"
else
    echo "Usage: $0 {home|lab}"
    exit 1
fi


ansible-playbook -i "$INVENTORY" collect-exams.yml --vault-password-file .vault_pass
