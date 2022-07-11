#!/bin/bash -eux

projectArray=(address user)
projectVersion=v1
namespace=dev-kube

function note() {
  local GREEN NC
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color
  printf "\n${GREEN}$@  ${NC}\n" >&2
}

set -e

function getEnvironmentVariables() {
    # set key value pair from arguments
    if [[ "$#" -eq "0" ]]; then
        echo "Error! Usage: Remind me how this works again ..."
        exit 1
    fi

    while [[ "$#" > "0" ]]
    do
        case $1 in
        (*=*) eval $1;;
        esac
        shift
    done
}

getEnvironmentVariables $@
podNumber=${scale-1}

function runRole() {
  note "Setting role"
  kubectl apply -f k8/istio/role/
}

function runConfig() {
  note "Setting configs"
  kubectl apply -f k8/istio/config/
}

function startDestinationRule() {
  note "Starting virtual services"
  kubectl apply -f k8/istio/destination-rule/
}

function startVirtualService() {
  note "Starting virtual services"
  kubectl apply -f k8/istio/virtual-service/
}

function removeConfig() {
  note "Deleting configs"
  kubectl delete -f k8/istio/config/
}

function startInfrastructure() {
  note "Starting Infrastructures"
  kubectl apply -f k8/istio/infrastructure/
  sleep 2
}

function startIntegration() {
  note "Starting Integrations"
  kubectl apply -f k8/istio/integration/
  sleep 2
}

function startDeployment() {
  note "Starting deployments"
  awk 'FNR==1{print "---"}1' k8/istio/deployment/* | IMAGE_TAG=${projectVersion} POD=${podNumber} envsubst | kubectl apply -f -
}

function startService() {
  note "Starting services"
  kubectl apply -f k8/istio/service/
  sleep 2
}

if [[ $@ == *"compile"* ]]; then
  note "Compiling projects..."
  mvn clean install

  for project in ${projectArray[*]}; do
    note "Building docker image for $project..."
    cd $project
    cp ../Dockerfile ./target
    docker build -f ./target/Dockerfile -t ${project}:$projectVersion .
    cd -
  done
fi

if [[ $@ == *"apply-config-k8"* ]]; then
  runConfig
fi

if [[ $@ == *"remove-config-k8"* ]]; then
  removeConfig
fi

if [[ $@ == *"start-k8"* ]]; then
  note "Starting building yaml files...",
  runRole
  runConfig
  startIntegration
  startInfrastructure
  startDeployment
  startService
  startDestinationRule
  startVirtualService
fi

if [[ $@ == *"stop-k8"* ]]; then
  eval $(minikube docker-env)
  note "Stopping kubernetes..."
  note "Stopping role"
  kubectl delete -f k8/istio/role
  note "Stopping deployment"
  kubectl delete -f k8/istio/deployment
  note "Stopping configs"
  kubectl delete -f k8/istio/config/
  note "Stopping infrastructures"
  kubectl delete -f k8/istio/infrastructure/
  note "Stopping services"
  kubectl delete -f k8/istio/service/
  note "Stopping destination rules"
  kubectl delete -f k8/istio/destination-rule/
  note "Stopping virtual services"
  kubectl delete -f k8/istio/virtual-service/
  note "Stopping integrations"
  kubectl delete -f k8/istio/integration/
fi
