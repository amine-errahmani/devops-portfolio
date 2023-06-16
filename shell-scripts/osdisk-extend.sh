#!/bin/bash

do_partition() {
    _disk=${1}
    _type=${2}
    if [ -z "${_type}" ]; then
        # default to Linux partition type (ie, ext3/xfs/xfs)
        _type=83
    fi
    echo "d
2
n
p



w"| sudo fdisk "${_disk}"
}

do_partition "/dev/sda"
sudo partprobe
sudo xfs_growfs /
