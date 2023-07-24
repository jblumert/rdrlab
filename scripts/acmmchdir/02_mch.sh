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
oc login -u $HUB_USER -p $HUB_PWD $HUB_API

#Create MultiClusterHub on hub cluster:

cat <<EOF | oc apply -f -
---
apiVersion: operator.open-cluster-management.io/v1
kind: MultiClusterHub
metadata:
   namespace: open-cluster-management
   name: multiclusterhub
spec:
   disableHubSelfManagement: false
EOF

# wait for MCH to be created
STATE=`oc get mch -n open-cluster-management -o=jsonpath='{.items[0].status.phase}{"\n"}'`
while [x$STATE != "xRunning" ]
do
 sleep 1
 echo "MCH state = $STATE"
 STATE=`oc get mch -n open-cluster-management -o=jsonpath='{.items[0].status.phase}{"\n"}'`
done
echo "MCH state = $STATE"

