.PHONY: push push-image push-chart

push: push-image push-chart

push-image:
	docker build -t localhost:5000/git-repo ./code
	docker push localhost:5000/git-repo

push-chart:
	helm push ./chart local --force