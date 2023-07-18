#!/bin/bash
#get token
API=https://api.ocp.ibm.edu:6443
USER=ocadmin
PWD=ibmrhocp
oc login -u $USER -p $PWD $API
TOKEN=`oc whoami -t`
echo "TOKEN=$TOKEN"
