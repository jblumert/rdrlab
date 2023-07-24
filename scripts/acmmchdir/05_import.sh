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
#oc login -u $HUB_USER -p $HUB_PWD $HUB_API

#Create auto-import-secret for cluster1 
#need current API URL and tocken for managed cluster 
#to import cluster1 into ACM on hub cluster:

# log into cluster1
oc login -u $CLUSTER1_USER -p $CLUSTER1_PWD $CLUSTER1_API
# Get API Key for cluster1
CLUSTER1_TOKEN=`oc whoami -t`
echo "Cluster1 Token $CLUSTER1_TOKEN"

# re-log into HUB cluster
oc login -u $HUB_USER -p $HUB_PWD $HUB_API

oc project open-cluster-management


# apply auto-import-secret for cluster1
cat <<EOF | oc apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: auto-import-secret
  namespace: cluster1
stringData:
  autoImportRetry: "5"
  token: $CLUSTER1_TOKEN
  server: $CLUSTER1_API
type: Opaque
EOF

#Create auto-import-secret for cluster2 
#need current API URL and tocken for managed cluster 
#to import cluster2 into ACM on hub cluster:

# log into cluster2
oc login -u $CLUSTER2_USER -p $CLUSTER2_PWD $CLUSTER2_API
# Get API Key for cluster2
CLUSTER1_TOKEN=`oc whoami -t`
echo "Cluster2 Token $CLUSTER2_TOKEN"

# re-log into HUB cluster
oc login -u $HUB_USER -p $HUB_PWD $HUB_API

oc project open-cluster-management

# apply auto-import-secret for cluster2
cat <<EOF | oc apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: auto-import-secret
  namespace: cluster2
stringData:
  autoImportRetry: "5"
  token: $CLUSTER2_TOKEN
  server: $CLUSTER2_API
type: Opaque
EOF
