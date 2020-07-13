.PHONY: push push-image push-chart

ID_RSA=$(shell cat ~/.ssh/id_rsa.pub | base64)

build:
	docker build -t localhost:5000/git-server ./code

push: build push-image push-chart

push-image:
	docker push localhost:5000/git-server

push-chart:
	helm push ./chart local --force