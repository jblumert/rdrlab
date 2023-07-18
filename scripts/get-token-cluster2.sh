#!/bin/bash
#get token
API=https://api.ocp2.ibm.edu
USER=ocadmin
PWD=ibmrhocp
oc login -u $USER -p $PWD $API
TOKEN=`oc whoami -t`
echo "TOKEN=$TOKEN"
