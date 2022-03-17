echo 'Changing docker data root...'
mkdir -p /var-lib-docker
cp /dockerd-entrypoint.sh /usr/local/bin/dockerd-entrypoint.sh
docker kill $(docker ps -q)
supervisorctl stop dockerd
supervisorctl start dockerd

#!/bin/sh
set -e


# if [ ! -e /var-lib-docker.loopback.ext4 ]; then
#   dd of=/var-lib-docker.loopback.ext4 bs=1 seek=15G count=0
#   /sbin/mkfs.ext4 -q /var-lib-docker.loopback.ext4
# fi

# if [ -e /trim-ext4-on-next-start.txt ]; then
#   export TRIM_GIGABYTES=$(cat /trim-ext4-on-next-start.txt)
#   fsck.ext4 -y -f /var-lib-docker.loopback.ext4
#   resize2fs /var-lib-docker.loopback.ext4 ${TRIM_GIGABYTES}G
#   truncate -s ${TRIM_GIGABYTES}G /var-lib-docker.loopback.ext4
#   rm -f /trim-ext4-on-next-start.txt
# fi  

# mount -t ext4 -o loop /var-lib-docker.loopback.ext4 /var-lib-docker
# cp /dockerd-entrypoint.sh /usr/local/bin/dockerd-entrypoint.sh
# supervisorctl start dockerd
# #dockerd --data-root=/var-lib-docker --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 --storage-driver=overlay2 &
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do kubectl get pods --all-namespaces && break || sleep 5; done
