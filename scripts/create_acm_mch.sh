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
  channel: release-2.8
  installPlanApproval: Automatic
  name: advanced-cluster-management
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

# Wait for ACM
echo "waiting 30 seconds for ACM....."
sleep 30
echo "ACM Done."


#Create MultiClusterHub on hub cluster:

cat <<EOF | oc apply -f -
---
apiVersion: operator.open-cluster-management.io/v1
kind: MultiClusterHub
metadata:
   namespace: open-cluster-management
   name: multiclusterhub
spec:
   disableHubSelfManagement: true
EOF

# wait for MCH to be created
STATE=`oc get mch -n open-cluster-management -o=jsonpath='{.items[0].status.phase}{"\n"}'`
while [ $STATE != "Running" ]
do
 sleep 1
 echo "MCH state = $STATE\n"
 STATE=`oc get mch -n open-cluster-management -o=jsonpath='{.items[0].status.phase}{"\n"}'`
done
echo "MCH state = $STATE\n"



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


#Create KlusterletAddonConfig for cluster1 on hub cluster:
cat <<EOF | oc apply -f -
---
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

#Create KlusterletAddonConfig for cluster2 on hub cluster:
cat <<EOF | oc apply -f -
---
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


#Create auto-import-secret for cluster1 
#need current API URL and tocken for managed cluster 
#to import cluster1 into ACM on hub cluster:

# log into cluster1
oc login -u $CLUSTER1_USER -p $CLUSTER1_PWD $CLUSTER1_API
# Get API Key for cluster1
CLUSTER1_TOKEN=`oc whoami -t`

# re-log into HUB cluster
oc login -u $HUB_USER -o $HUB_PWD $HUB_API

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

# re-log into HUB cluster
oc login -u $HUB_USER -o $HUB_PWD $HUB_API

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


# Validation of clusters of clusters
# oc get managedclusters
#NAME       HUB ACCEPTED   MANAGED CLUSTER URLS                     JOINED   AVAILABLE   AGE
#
#cluster1   true           https://api.bos5.vmw.ibmfusion.eu:6443                 True         True               10m
#cluster2   true           https://api.bos6.vmw.ibmfusion.eu:6443                 True         True                9m41s
#
# check cluster1 state
STATE1=`oc get managedclusters cluster1|grep True|awk '{print $5}'``
while [ $STATE1 != "True" ]
do
 sleep 1
 echo "cluster1 state = $STATE1\n"
STATE1=`oc get managedclusters cluster1|grep True|awk '{print $5}'``
done
 echo "cluster1 state = $STATE1\n"
#
# check cluster2 state
STATE2=`oc get managedclusters cluster2|grep True|awk '{print $5}'``
while [ $STATE2 != "True" ]
do
 sleep 1
 echo "cluster2 state = $STATE2\n"
STATE1=`oc get managedclusters cluster2|grep True|awk '{print $5}'``
done
 echo "cluster2 state = $STATE2\n"

#
#Create Submariner ManagedClusterSet on hub cluster:
#

cat <<EOF | oc apply -f -
---
apiVersion: cluster.open-cluster-management.io/v1beta2
kind: ManagedClusterSet
metadata:
  name: submariner
EOF
