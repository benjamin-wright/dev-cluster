# Local Development Cluster

Self-container startup script and basic infrastructure chart for running a local development kubernetes cluster. This cluster is heavily inspired (mostly ripped off from) the [tilt.dev](https://github.com/tilt-dev/kind-local) example.

## Dependencies:

> Only tested on OSX (Catalina)

- [docker](https://docs.docker.com/docker-for-mac/install/)
- kind (`brew install kind`)
- kubectl (`brew install kubectl`)
- jq (`brew install jq`)

## Includes:
- nginx ingress
- metrics server
- prometheus
- grafana
- verdaccio (NPM repository)
- shared docker registry running on `localhost:5000` for easily pushing images to the cluster
- git server

## To use:

Chart museum listens on localhost:5007
Git server ssh on localhost:2222