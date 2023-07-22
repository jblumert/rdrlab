#!/bin/bash
# login into hubcluster
# Credentials Hub Cluster
HUB_USER=ocadmin
HUB_PWD=ibmrhocp
HUB_API=https://api.hub.ibm.edu:6443

#Credentials Cluster1 and Cluster2
CLUSTER1_USER=ocadmin
CLUSTER1_PWD=ibmrhocp
CLUSTER1_API=https://api.ocp.ibm.edu:6443

CLUSTER2_USER=ocadmin
CLUSTER2_PWD=ibmrhocp
CLUSTER2_API=https://api.ocp2.ibm.edu:6443

# log into hub cluster
oc login -u $HUB_USER -p $HUB_PWD $HUB_API --insecure-skip-tls-verify

# wait for MCH to be created
echo "get init state"
STATE=`oc get mch -n open-cluster-management -o=jsonpath='{.items[0].status.phase}{"\n"}'`
echo "enter while"
while [ $STATE != "Running" ]
do
 echo "sleep 2"
 sleep 2
 echo "1 MCH state = $STATE"
 STATE=`oc get mch -n open-cluster-management -o=jsonpath='{.items[0].status.phase}{"\n"}'`
 echo "2 MCH state = $STATE"
done
echo "MCH state = $STATE"

