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
