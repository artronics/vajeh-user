include .env

aws_cred := -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)
tf := docker run --rm -it $(aws_cred) -v $(shell pwd):/app  -v "/var/run/docker.sock:/var/run/docker.sock:rw"

ws = jaho

.SILENT:
terraform-deploy:
	$(tf) artronics/terraform-flow --path=/app/terraform --workspace=$(ws) --options="" --dryrun=false --destroy=false --destroy-workspace=false
	#make -C terraform docker-push-service
terraform-destroy:
	$(tf) artronics/terraform-flow --path=/app/terraform --workspace=$(ws) --options="" --dryrun=false --destroy=true --destroy-workspace=false

tf-apply:
	terraform -chdir=terraform apply -auto-approve
seed:
	go run db/seed.go
