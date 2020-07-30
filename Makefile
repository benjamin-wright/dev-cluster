.PHONY: start stop

start-full:
	@./scripts/start-cluster.sh

start:
	@./scripts/start-cluster.sh minimal

stop:
	@./scripts/stop-cluster.sh