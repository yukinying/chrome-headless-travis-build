#!/bin/bash

set -e

STEP=$1
SSH_CONFIG=$2
HOST=$3
BUILD=$4
COMMAND=`awk "NR==$STEP+1" chrome_build.sh`

## Make sure this is the only build running in the box.
echo "[ -f chrome.$BUILD ] && echo 'Previous job failed. Halting...' && exit 1 || touch chrome.$BUILD" | ssh -T -F $SSH_CONFIG $HOST
echo ">>> Run from remote machine: $COMMAND"
echo "======================================="
echo "cd ~/chromium/src && $COMMAND" | ssh -T -F $SSH_CONFIG $HOST
## Release the build lock
echo "rm chrome.$BUILD" | ssh -T -F $SSH_CONFIG $HOST
