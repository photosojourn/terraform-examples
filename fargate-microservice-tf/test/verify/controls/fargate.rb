title 'verify'

content = inspec.profile.file("terraform.json")
params = JSON.parse(content)

VPC_ID = params['vpc_id']['value']
CLUSTER_NAME = params['ecs_cluster_name']['value']
ALB_ARN = params['alb_arn']['value']

describe aws_vpc(vpc_id: VPC_ID ) do
  its('cidr_block') { should cmp '10.0.0.0/16' }
end

describe aws_ecs_cluster(cluster_name: CLUSTER_NAME) do
  its ( 'status' )  { should eq 'ACTIVE' }
  its ( 'active_services_count' ) { should eq 2}
  its ( 'running_tasks_count' ) { should eq 4}
end

describe aws_alb(load_balancer_arn: ALB_ARN) do
  its ( 'zone_names.count' ) { should be > 1 }
  its ( 'vpc_id') { should cmp VPC_ID }
end