#!/bin/bash

# README
#
# This script contains the wdy standard deployment.
# It assumes a docker file in the root of the repository.
# All environment variables from the `validate-default-env-vars.sh` script are required.


PROJECT_NAME=${CI_PROJECT_NAME}-${CI_ENVIRONMENT_SLUG}
NAMESPACE=${K8S_NAMESPACE}

# Print the namespace and domain in the console
echo "deployment namespace '${NAMESPACE}'"
DOMAIN_PREFIX=${NAMESPACE}-${CI_PROJECT_NAME}-${CI_ENVIRONMENT_SLUG}
echo "The service can be found (if publiclyAvaible == true) at 'http://${DOMAIN_PREFIX}.delta.k8s-wdy.de'"

# get helm charts
curl -L https://github.com/worldiety/helm-charts/archive/master.zip --output master.zip 
unzip master.zip
rm master.zip
mv helm-charts-master helm-charts

# Replace environment variables in deployment values file
envsubst "$(printf '${%s} ' $(env | sed 's/=.*//'))" < deployment-values.yaml > final-deployment-values.yaml

# Prepare the kubectl config
kubectl config set-cluster $K8S_CLUSTER_NAME --server="${K8S_SERVER_URL}" 
kubectl config set clusters.$K8S_CLUSTER_NAME.certificate-authority-data ${K8S_CE_AUTH_DATA}  
kubectl config set-credentials $K8S_USER_NAME --token="${K8S_USER_TOKEN}"
kubectl config set-context --cluster=$K8S_CLUSTER_NAME --user=$K8S_USER_NAME $K8S_USER_NAME
kubectl config use-context $K8S_USER_NAME

# Deploy the application
helm upgrade --install --cleanup-on-fail --atomic
    --namespace "${NAMESPACE}"
    -f final-deployment-values.yaml
    --set name=${PROJECT_NAME}
    --set namespace=${NAMESPACE}
    --set buildtype=${CI_ENVIRONMENT_SLUG}
    --set gitlabImage.registry=${CI_REGISTRY}
    --set gitlabImage.repository=${CI_REGISTRY_IMAGE}
    --set gitlabImage.tag=${CI_COMMIT_REF_NAME}
    --set gitlabImage.user=${CI_DEPLOY_USER}
    --set gitlabImage.password=${CI_DEPLOY_PASSWORD}
    "${PROJECT_NAME}" helm-charts/project-template/