#! /bin/bash
export OCI_CLI_AUTH=instance_principal
export TEST_MACHINE_NAME=$(oci-metadata --get TEST_MACHINE_NAME --value)
export TEST_ID=$(oci-metadata --get TEST_ID --value)

declare -xp

dnf -y install python36-oci-cli

# stop cpu tasks
systemctl stop dnf-makecache.timer
systemctl stop dnf-system-upgrade.service
systemctl stop dnf-system-upgrade-cleanup.service
systemctl stop dnf-makecache.service

curl -sL yabs.sh | bash -s -- -i -f -6 -n -w /$TEST_MACHINE_NAME-$(nproc).json

oci os object put --force --bucket-name phoronix --file /$TEST_MACHINE_NAME-$(nproc).json --name /$TEST_ID/$TEST_MACHINE_NAME-$(nproc).json

oci compute instance action --instance-id $(oci-metadata --get id --value-only) --action SOFTSTOP