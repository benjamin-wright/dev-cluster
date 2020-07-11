#!/bin/bash

set -o errexit

KIND_CLUSTER_NAME="local-dev"

kind delete cluster --name $KIND_CLUSTER_NAME
docker rm $(docker stop registry-$KIND_CLUSTER_NAME)