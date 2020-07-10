#!/bin/bash

# README
#
# This script can be used to fetch all logs in one namespace.
# The a `.env` file is required, that should look like this:
# 
# K8S_CLUSTER_NAME=CHANGEME
# K8S_SERVER_URL=CHANGEME
# K8S_CE_AUTH_DATA=CHANGEME
# K8S_NAMESPACE=CHANGEME
# K8S_USER_NAME=CHANGEME
# K8S_USER_TOKEN=CHANGEME
# 
# It can be used like this:
#   docker run --env-file .env test ./fetch-logs.sh


# Check if all variables exist
for VARIABLE in K8S_CLUSTER_NAME K8S_SERVER_URL K8S_CE_AUTH_DATA K8S_NAMESPACE K8S_USER_NAME K8S_USER_TOKEN
do
    value=$(printenv $VARIABLE)

    if [ -z "$value" ]
    then
        echo "$VARIABLE not available"
        exit 1
    fi
done

# Prepare the kubectl config
kubectl config set-cluster $K8S_CLUSTER_NAME --server="${K8S_SERVER_URL}" 
kubectl config set clusters.$K8S_CLUSTER_NAME.certificate-authority-data ${K8S_CE_AUTH_DATA}  
kubectl config set-credentials $K8S_USER_NAME --token="${K8S_USER_TOKEN}"
kubectl config set-context --cluster=$K8S_CLUSTER_NAME --user=$K8S_USER_NAME $K8S_USER_NAME --namespace=$K8S_NAMESPACE
kubectl config use-context $K8S_USER_NAME

# print all logs
for PODNAME in $(kubectl get pods | grep -v 'NAME' | cut -f 1 -d ' ')
do 
    echo --------------------------- 
    echo $PODNAME 
    echo --------------------------- 
    kubectl logs $PODNAME
done
