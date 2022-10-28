include ../.env

environment = jaho
service_dir = $(shell pwd)/../resolver
service_repository_name = vajeh-user-$(environment)
service_repository_url = $(AWS_ACCOUNT_ID).dkr.ecr.eu-west-2.amazonaws.com/$(service_repository_name)

test:
	echo $(service_repository_url)

docker-login:
	aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin $(service_repository_url)

docker-build-service:
	docker build --platform linux/amd64 -t $(service_repository_name):$(environment) -f $(service_dir)/Dockerfile $(service_dir)

docker-tag-service: docker-build-service
	docker tag $(service_repository_name):$(environment) $(service_repository_url):$(environment)

docker-push-service: docker-tag-service docker-login
	docker push $(service_repository_url):$(environment)
