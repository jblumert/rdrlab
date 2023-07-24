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

oc project open-cluster-management

#Create KlusterletAddonConfig for cluster1 on hub cluster:
cat <<EOF | oc apply -f -
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: cluster1
  namespace: cluster1
spec:
  applicationManager:
    enabled: true
  certPolicyController:
    enabled: true
  iamPolicyController:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
EOF


oc project open-cluster-management

#Create KlusterletAddonConfig for cluster2 on hub cluster:
cat <<EOF | oc apply -f -
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: cluster2
  namespace: cluster2
spec:
  applicationManager:
    enabled: true
  certPolicyController:
    enabled: true
  iamPolicyController:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
EOF
