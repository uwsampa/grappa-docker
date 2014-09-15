#!/bin/bash
################################################################
# Mount a Docker volume on the host machine.
#
# - On OSX/boot2docker, this runs and mounts a Samba file share
# - On Linux, it should just symlink the right directory
################################################################
if [ $# != 2 ]; then
  echo "Usage: $0 <image> <mount_point>"
  exit 0
fi

image=$1
mount_point=$2

case $(uname) in
  
  Darwin)
    
    # share /grappa with host via Samba
    docker run --rm -v /usr/local/bin/docker:/docker -v /var/run/docker.sock:/docker.sock svendowideit/samba $image

    # mount the Sampa share on the host
    mkdir -p $mount_point
    umount $mount_point 2>/dev/null || true
    mount -t smbfs //guest:@$(boot2docker ip 2>/dev/null)/grappa $mount_point
    
    ;;
  
  *)
    # else, Linux:
    ln -s $image/grappa $mount_point
    
    ;;
esac
