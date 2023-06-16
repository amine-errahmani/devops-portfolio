#!/bin/bash
blobfuse /mnt/ENVcbuae --tmp-path=/mnt/resource/blobfusetmp -o allow_other -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 --config-file=/home/user/blobfuse.cfg