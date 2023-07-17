#!/bin/bash

## Login to hub cluster
## Create submariner ManagedClusterSet
cat <<EOF | oc apply -f -
apiVersion: cluster.open-cluster-management.io/v1beta2
kind: ManagedClusterSet
metadata:
  name: submariner
EOF

sleep 15

## Create submariner Broker
cat <<EOF | oc apply -f -
apiVersion: submariner.io/v1alpha1
kind: Broker
metadata:
  name: submariner-broker
  namespace: submariner-broker
  labels:
    cluster.open-cluster-management.io/backup: submariner
spec:
  globalnetEnabled: false
EOF

sleep 30

## Label ManagedClusters to add to submariner ClusterSet
oc label managedclusters cluster1 "cluster.open-cluster-management.io/clusterset=submariner" --overwrite
oc label managedclusters cluster2 "cluster.open-cluster-management.io/clusterset=submariner" --overwrite

## Create SubmarinerConfig for cluster1
cat <<EOF | oc apply -f -
apiVersion: submarineraddon.open-cluster-management.io/v1alpha1
kind: SubmarinerConfig
metadata:
    name: submariner
    namespace: cluster1
spec:
  gatewayConfig:
    gateways: 1
  IPSecIKEPort: 500
  IPSecNATTPort: 4500
  NATTDiscoveryPort: 4900
  NATTEnable: false
  airGappedDeployment: false
  cableDriver: libreswan
  insecureBrokerConnection: false
  loadBalancerEnable: false
EOF

## Create SubmarinerConfig for cluster2
cat <<EOF | oc apply -f -
apiVersion: submarineraddon.open-cluster-management.io/v1alpha1
kind: SubmarinerConfig
metadata:
    name: submariner
    namespace: cluster2
spec:
  gatewayConfig:
    gateways: 1
  IPSecIKEPort: 500
  IPSecNATTPort: 4500
  NATTDiscoveryPort: 4900
  NATTEnable: false
  airGappedDeployment: false
  cableDriver: libreswan
  insecureBrokerConnection: false
  loadBalancerEnable: false
EOF

sleep 15

## Create submariner ManagedClusterAddOn for cluster1
cat <<EOF | oc apply -f -
apiVersion: addon.open-cluster-management.io/v1alpha1
kind: ManagedClusterAddOn
metadata:
  name: submariner
  namespace: cluster1
spec:
  installNamespace: submariner-operator
EOF

## Create submariner ManagedClusterAddOn for cluster2
cat <<EOF | oc apply -f -
apiVersion: addon.open-cluster-management.io/v1alpha1
kind: ManagedClusterAddOn
metadata:
  name: submariner
  namespace: cluster2
spec:
  installNamespace: submariner-operator
EOF
     
