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

#Create ManagedCluster for cluster1 on hub cluster:---

cat <<EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: cluster1
spec: {}
---
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: cluster1
  labels:
    cloud: auto-detect
    vendor: auto-detect
spec:
  hubAcceptsClient: true
EOF

#Create ManagedCluster for cluster2 on hub cluster:
cat <<EOF | oc apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: cluster2
spec: {}
---
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: cluster2
  labels:
    cloud: auto-detect
    vendor: auto-detect
spec:
  hubAcceptsClient: true
EOF


