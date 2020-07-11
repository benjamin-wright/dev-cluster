#!/bin/bash

set -o errexit

KIND_CLUSTER_NAME="local-dev"

function start-kind() {
  local kind_network='kind'
  local reg_name="registry-${KIND_CLUSTER_NAME}"
  local reg_port='5000'

  # create registry container unless it already exists
  local running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
  if [ "${running}" != 'true' ]; then
    docker run \
      -d --restart=always -p "${reg_port}:5000" --name "${reg_name}" \
      registry:2
  fi

  local reg_host="${reg_name}"
  echo "Registry Host: ${reg_host}"

  # create a cluster with the local registry enabled in containerd
  cat <<EOF | kind create cluster --name "${KIND_CLUSTER_NAME}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 80
    protocol: TCP
  - containerPort: 30443
    hostPort: 443
    protocol: TCP
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_host}:${reg_port}"]
EOF

  for node in $(kind get nodes --name "${KIND_CLUSTER_NAME}"); do
    kubectl annotate node "${node}" tilt.dev/registry=localhost:${reg_port};
  done

  local containers=$(docker network inspect ${kind_network} -f "{{range .Containers}}{{.Name}} {{end}}")
  local needs_connect="true"
  for c in $containers; do
    if [ "$c" = "${reg_name}" ]; then
      needs_connect="false"
    fi
  done
  if [ "${needs_connect}" = "true" ]; then
    docker network connect "${kind_network}" "${reg_name}" || true
  fi
}

function wait-for-kind() {
  local ready="false";
  echo 'waiting for kind to spin up...';

  while [ "$ready" == "false" ]; do
    sleep 0.5;
    ready="true"

    local podStatuses=$(kubectl get pods --namespace=kube-system -o=json | jq ".items[].status.containerStatuses[0].ready")
    local numPods=$(kubectl get pods --namespace=kube-system -o=json | jq ".items | length")

    if [ "$numPods" != "8" ]; then
      ready="false";
    fi

    for status in $podStatuses; do
      if [ "$status" != "true" ]; then
        ready="false";
      fi
    done
  done

  echo "finished!";
}

function deploy-infra() {
  echo 'deploying standard infrastructure...';
  kubectl get ns | grep infra || kubectl create ns infra
  helm dep update ./infra
  helm upgrade --install \
    --wait \
    --namespace infra \
    --set mongo.tls.cacert=$(cat ssl/cert.crt | base64) \
    --set mongo.tls.cakey=$(cat ssl/cert.key | base64) \
    infra ./infra
  echo 'done';
}

##############################################################################
#                                   Main                                     #
##############################################################################
if !(kind get clusters | grep $KIND_CLUSTER_NAME -q); then
  start-kind
  wait-for-kind
fi

deploy-infra