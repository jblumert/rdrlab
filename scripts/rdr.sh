#!/bin/bash

## Check that ODF is installed on managed clusters
## Login to hub cluster
## Create MCO Subscription
cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  labels:
    operators.coreos.com/odf-multicluster-orchestrator.openshift-operators: ""
  name: odf-multicluster-orchestrator
  namespace: openshift-operators
spec:
  channel: stable-4.13
  installPlanApproval: Automatic
  name: odf-multicluster-orchestrator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: odf-multicluster-orchestrator.v4.13.0-rhodf
EOF

sleep 60

## Enable MCO odf-multicluster-console dynamic plugin
oc patch console.v1.operator.openshift.io cluster --type=json -p="[{'op': 'add', 'path': '/spec/plugins', 'value':[odf-multicluster-console]}]"

## Create first DRPolicy
cat <<EOF | oc apply -f -
apiVersion: ramendr.openshift.io/v1alpha1
kind: DRPolicy
metadata:
  labels:
    cluster.open-cluster-management.io/backup: resource
  name: cluster1-cluster2-5m
spec:
  drClusters:
  - cluster1
  - cluster2
  replicationClassSelector: {}
  schedulingInterval: 5m
  volumeSnapshotClassSelector: {}
EOF

## Create MirrorPeer
cat <<EOF | oc apply -f -
apiVersion: multicluster.odf.openshift.io/v1alpha1
kind: MirrorPeer
metadata:
  labels:
    cluster.open-cluster-management.io/backup: resource
  name: mirrorpeer-cluster1-cluster2
spec:
  items:
  - clusterName: cluster1
    storageClusterRef:
      name: ocs-storagecluster
      namespace: openshift-storage
  - clusterName: cluster2
    storageClusterRef:
      name: ocs-storagecluster
      namespace: openshift-storage
  manageS3: true
  overlappingCIDR: false
  type: async
EOF

## Wait for ExchangedSecret status
while true
do
    yourvalue=$(oc get mirrorpeer mirrorpeer-cluster1-cluster2 -o jsonpath='{.status.phase}')
    if [ "x${yourvalue}" == "xExchangedSecret" ]
    then
        echo "Secrets are exchanged and DRClusters created"
        break
    else
        echo "Waiting for secrets to be exchanged"
        sleep 60
    fi
done
