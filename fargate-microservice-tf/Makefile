init:
	terraform init

plan:
	terraform plan

apply: 
	terraform apply

.PHONY: test
test: init apply
	terraform output --json > test/verify/files/terraform.json
	inspec vendor test/verify --overwrite
	inspec exec test/verify -t aws://
	terraform destroy