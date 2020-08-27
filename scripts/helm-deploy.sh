#!/bin/bash

# This script mimics the cluster deployment of the GitLab CI pipeline
# and therefore can be used for further development and testing the
# helm-chart templates without the necessity of the pipeline.
#
# Usage:
#   create an environment file (e.g. deploy.env) with following necessary variables:

# NAMESPACE=test
# PROJECT_NAME=<some-project-name>
# CI_ENVIRONMENT_SLUG=dev
# CI_REGISTRY=<registry>
# CI_REGISTRY_IMAGE=<an-image-path/an-image-name>
# CI_COMMIT_REF_NAME=master
# CI_DEPLOY_USER=<gitlab+deploy-token-N>
# CI_DEPLOY_PASSWORD=<deploy-token-password>
# DEPLOYMENT_VALUES=<local-path>/deployment-values.yaml
# TEMPLATES=<local-path>/helm-charts/project-template/.
#
# Afterwards run this script, with your environment file as parameter, example:
#
#   helm-deploy.sh deploy.env

if [ -z $1 ] 
then
    echo "Missing configuration file parameter"
    exit 1
fi

if [ ! -e $1 ] 
then
    echo "Missing configuration file"
    exit 1
fi

source $1

envsubst "$(printf '${%s} ' $(env | sed 's/=.*//'))" < $DEPLOYMENT_VALUES > /tmp/final-deployment-values.yaml

helm upgrade --install --cleanup-on-fail --atomic \
            --namespace "${NAMESPACE}" \
            -f/tmp/final-deployment-values.yaml \
            --set name=${PROJECT_NAME} \
            --set namespace=${NAMESPACE} \
            --set buildtype=${CI_ENVIRONMENT_SLUG} \
            --set gitlabImage.registry=${CI_REGISTRY} \
            --set gitlabImage.repository=${CI_REGISTRY_IMAGE} \
            --set gitlabImage.tag=${CI_COMMIT_REF_NAME} \
            --set gitlabImage.user=${CI_DEPLOY_USER} \
            --set gitlabImage.password=${CI_DEPLOY_PASSWORD} \
            "${PROJECT_NAME}" $TEMPLATES

