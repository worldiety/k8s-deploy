#!/bin/bash

# Check if all variables exist
for VARIABLE in CI_DEPLOY_USER CI_DEPLOY_PASSWORD K8S_CLUSTER_NAME K8S_SERVER_URL K8S_CE_AUTH_DATA K8S_NAMESPACE K8S_USER_NAME K8S_USER_TOKEN
do
    value=$(printenv $VARIABLE)

    if [ -z "$value" ]
    then
        echo "Value2: $value"
        echo "$VARIABLE not available"
        exit 1
    else 
        echo "Found Variable: $VARIABLE=$value"
    fi
done

# count namespace name length
NAMESPACE_LENGTH=$(echo "${K8S_NAMESPACE}" | wc -c)

# Check if the length of the namespace name is to long. If true the ci will abort
if [ $NAMESPACE_LENGTH -ge 63 ]
then 
    echo "Namespace too long!"
    echo "Length must be lower than 63, currently: $NAMESPACE_LENGTH"
    echo "Namespace Name: $K8S_NAMESPACE"
    exit 1
fi

# All variables set - you are ready to go
echo "\nAll variables are set"
