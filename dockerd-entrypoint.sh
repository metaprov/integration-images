#!/bin/sh
set -e

# this is pretty much instantaneus becuase while container 
# is not committed to image sparse files works just fine
if [ ! -e /var-lib-docker.loopback.ext4 ]; then
  dd of=/var-lib-docker.loopback.ext4 bs=1 seek=15G count=0
  /sbin/mkfs.ext4 -q /var-lib-docker.loopback.ext4
fi

# TODO: create scripts to autoresize partition when docker:dind
#       is released, which has this bugfix included 
#       https://bugs.busybox.net/show_bug.cgi?id=11886

# trim ext4 image file to smaller length if special file is found
# if [ -e /trim-ext4-on-next-start.txt ]; then
#   export TRIM_GIGABYTES=$(cat /trim-ext4-on-next-start.txt)
#   fsck.ext4 -y -f /var-lib-docker.loopback.ext4
#   resize2fs /var-lib-docker.loopback.ext4 ${TRIM_GIGABYTES}G
#   truncate -s ${TRIM_GIGABYTES}G /var-lib-docker.loopback.ext4
#   rm -f /trim-ext4-on-next-start.txt
# fi  

# for some reason /etc/fstab entry didn't work
mount -t ext4 -o loop /var-lib-docker.loopback.ext4 /var-lib-docker

# no arguments passed
# or first arg is `-f` or `--some-option`
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
  # add our default arguments
  set -- dockerd \
    --data-root=/var-lib-docker \
    --host=unix:///var/run/docker.sock \
    --host=tcp://0.0.0.0:2375 \
    "$@"
fi

if [ "$1" = 'dockerd' ]; then

  # explicitly remove Docker's default PID file to ensure that it can start properly if it was stopped uncleanly (and thus didn't clean up the PID file)
  find /run /var/run -iname 'docker*.pid' -delete
fi

exec "$@"