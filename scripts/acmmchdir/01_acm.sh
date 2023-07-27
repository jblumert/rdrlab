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

# get API token
HUB_TOKEN=`oc whoami -t`

# create ACM on hub cluster
cat <<EOF | oc apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: open-cluster-management
spec: {}
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: open-cluster-management-og
  namespace: open-cluster-management
spec:
  targetNamespaces:
  - open-cluster-management
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: acm
  namespace: open-cluster-management
spec:
  channel: release-2.7
  installPlanApproval: Automatic
  name: advanced-cluster-management
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
