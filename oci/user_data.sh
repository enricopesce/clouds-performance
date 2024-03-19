#! /bin/bash
export OCI_CLI_AUTH=instance_principal
export TEST_MACHINE_NAME=$(oci-metadata --get TEST_MACHINE_NAME --value)
export TEST_ID=$(oci-metadata --get TEST_ID --value)

declare -xp

dnf -y install python36-oci-cli
rpm -i http://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y install sysbench

# stop cpu tasks
systemctl stop dnf-makecache.timer
systemctl stop dnf-system-upgrade.service
systemctl stop dnf-system-upgrade-cleanup.service
systemctl stop dnf-makecache.service

echo "$TEST_MACHINE_NAME-$(nproc),1,$(sysbench cpu --threads=1 run --time=60 --cpu-max-prime=1000 | sed -n 's/.*events per second: //p')" >> /$TEST_MACHINE_NAME-$(nproc).csv
echo "$TEST_MACHINE_NAME-$(nproc),2,$(sysbench cpu --threads=2 run --time=60 --cpu-max-prime=1000 | sed -n 's/.*events per second: //p')" >> /$TEST_MACHINE_NAME-$(nproc).csv
echo "$TEST_MACHINE_NAME-$(nproc),4,$(sysbench cpu --threads=4 run --time=60 --cpu-max-prime=1000 | sed -n 's/.*events per second: //p')" >> /$TEST_MACHINE_NAME-$(nproc).csv
echo "$TEST_MACHINE_NAME-$(nproc),8,$(sysbench cpu --threads=8 run --time=60 --cpu-max-prime=1000 | sed -n 's/.*events per second: //p')" >> /$TEST_MACHINE_NAME-$(nproc).csv
echo "$TEST_MACHINE_NAME-$(nproc),16,$(sysbench cpu --threads=16 run --time=60 --cpu-max-prime=1000 | sed -n 's/.*events per second: //p')" >> /$TEST_MACHINE_NAME-$(nproc).csv
echo "$TEST_MACHINE_NAME-$(nproc),24,$(sysbench cpu --threads=24 run --time=60 --cpu-max-prime=1000 | sed -n 's/.*events per second: //p')" >> /$TEST_MACHINE_NAME-$(nproc).csv
echo "$TEST_MACHINE_NAME-$(nproc),32,$(sysbench cpu --threads=32 run --time=60 --cpu-max-prime=1000 | sed -n 's/.*events per second: //p')" >> /$TEST_MACHINE_NAME-$(nproc).csv

oci os object put --force --bucket-name sysbench --file /$TEST_MACHINE_NAME-$(nproc).csv --name /$TEST_ID/$TEST_MACHINE_NAME-$(nproc).csv

oci compute instance action --instance-id $(oci-metadata --get id --value-only) --action SOFTSTOP