# Note: we need to use keycloak to be able run run command with the aws-cli
#      aws-keycloak -p devx -- <aws-cli command>

# AWS cloudwatch
## Check a cloudwatch alarm
aws cloudwatch describe-alarms-for-metric --metric-name memory-usage --namespace ARM/Monitoring --dimensions Name=orgId,Value=739126a3-2e6f-48f7-a5f0-c6328256c237 Name=envId,Value=77ac2a16-70e0-40e6-b427-a18119ee8abc Name=resourceId,Value=798153 Name=environment,Value=prod Name=resourceType,Value=target --output json | jq

# AWS ROUTE 53
## Get a resource filtered by name
aws route53 list-resource-record-sets --hosted-zone-id Z1IPIX4N9ECZ3Q --query "ResourceRecordSets[?Name == 'arm-auth-proxy.devx.msap.io.']"

# AWS EC2
## List all instances with all states
aws ec2 describe-instances

## list all instances running
aws ec2 describe-instances --filters Name=instance-state-name,Values=running

## Print security groups for an instance
aws ec2 describe-instances --instance-ids i-0dae5d4daa47fe4a2 | jq -r '.Reservations[].Instances[].SecurityGroups[]|.GroupId+" "+.GroupName'

## Create new instance
aws ec2 run-instances \
    --image-id ami-f0e7d19a \	
    --instance-type t2.micro \
    --security-group-ids sg-00000000 \
    --dry-run

## stop an instance
aws ec2 terminate-instances \
    --instance-ids <instance_id>

## list status of a specific instance
aws ec2 describe-instance-status \
    --instance-ids <instance_id>

# AWS SECURITY GROUPS
## List all security groups
aws ec2 describe-security-groups | jq -r '.SecurityGroups[]|.GroupId+" "+.GroupName'

## Add rule to SG
aws ec2 authorize-security-group-ingress --group-id sg-02a63c67684d8deed --protocol tcp --port 443 --cidr 35.0.0.1

## Edit rule
aws ec2 update-security-group-rule-descriptions-ingress --group-id sg-02a63c67684d8deed --ip-permissions 'ToPort=443,IpProtocol=tcp,IpRanges=[{CidrIp=202.171.186.133/32,Description=Home}]'

## Delete rule
aws ec2 revoke-security-group-ingress --group-id sg-02a63c67684d8deed --protocol tcp --port 443 --cidr 35.0.0.1

## Delete SG
aws ec2 delete-security-group --group-id sg-02a63c67684d8deed

# AWS S3
## List buckets
aws s3 ls

## Create bucket
aws s3 mb s3://my-awesome-new-bucket

## Delete bucket
aws s3 rb s3://my-awesome-new-bucket --force

## Download S3 object to machine
aws s3 cp s3://my-awesome-new-bucket .

## Upload local file to S3
aws s3 cp backup.tar s3://my-awesome-new-bucket

## Delete S3 object
aws s3 rm s3://my-awesome-new-bucket/secret-file.gz .

## Download bucket to machine
aws s3 sync s3://my-awesome-new-bucket/ /media/test/backup

## Upload local bucket to S3
aws s3 sync /home/user/Downloads s3://my-awesome-new-bucket/

# AWS ELB
## List all target groups
aws elbv2 describe-target-groups

## List of ELB hostnames
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].DNSName'  | jq -r 'to_entries[] | .value'

## List of ELB ARNs
aws elbv2 describe-load-balancers | jq -r '.LoadBalancers[] | .LoadBalancerArn'

## Get instances for a target group
aws elbv2 describe-target-health --target-group-arn arn:aws:elasticloadbalancing:ap-southeast-1:987654321:targetgroup/wordpress-ph/88f517d6b5326a26 | jq -r '.TargetHealthDescriptions[] | .Target.Id'

# AWS RDS
## List of DB clusters
aws rds describe-db-clusters | jq -r '.DBClusters[] | .DBClusterIdentifier+" "+.Endpoint'

## List of DB instances
aws rds describe-db-instances | jq -r '.DBInstances[] | .DBInstanceIdentifier+" "+.DBInstanceClass+" "+.Endpoint.Address'

## Take DB instance snapshot
aws rds create-db-snapshot --db-snapshot-identifier backend-dev-snapshot-0001 --db-instance-identifier backend-dev
aws rds describe-db-snapshots --db-snapshot-identifier backend-dev-snapshot-0001 --db-instance-identifier general

## Take DB cluster snapshot
aws rds create-db-cluster-snapshot --db-cluster-snapshot-identifier backend-prod-snapshot-0002 --db-cluster-identifier backend-prod
aws rds describe-db-cluster-snapshots --db-cluster-snapshot-identifier backend-prod-snapshot-0002 --db-cluster-identifier backend-prod

# AWS LAMBDA
## List of lamda functions with runtime and memory
aws lambda list-functions | jq -r '.Functions[] | .FunctionName+" "+.Runtime+" "+(.MemorySize|tostring)'

## List lambda layers
aws lambda list-layers | jq -r '.Layers[] | .LayerName'

## List of source event for lambda
aws lambda list-event-source-mappings | jq -r '.EventSourceMappings[] | .FunctionArn+" "+.EventSourceArn'

## Download lambda code
aws lambda get-function --function-name DynamoToSQS | jq -r .Code.Location

# AWS SNS
## List of SNS topics
aws sns list-topics | jq -r '.Topics[] | .TopicArn'

## List of SNS topics and related subscriptions
aws sns list-subscriptions | jq -r '.Subscriptions[] | .TopicArn+" "+.Protocol+" "+.Endpoint'

## Publish to SNS topic
aws sns publish --topic-arn arn:aws:sns:ap-southeast-1:987654321:backend-api-monitoring \
    --message "Panic!!!" \
    --subject "The API is down!!!"

# AWS SQS
## List Queues
aws sqs list-queues | jq -r '.QueueUrls[]'

## Create Queue
aws sqs create-queue --queue-name public-events.fifo | jq -r .QueueUrl

## Send message
aws sqs send-message --queue-url https://ap-southeast-1.queue.amazonaws.com/987654321/public-events.fifo --message-body Hello

## Receive message
aws sqs receive-message --queue-url https://ap-southeast-1.queue.amazonaws.com/987654321/public-events.fifo | jq -r '.Messages[] | .Body'

## Delete message
aws sqs delete-message --queue-url https://ap-southeast-1.queue.amazonaws.com/987654321/public-events.fifo --receipt-handle "AQEBpqKLxNb8rIOn9ykSeCkKebNzn0BrEJ3Cg1RS6MwID2t1oYHCnMP06GnuVZGzt7kpWXZ5ieLQ=="

## Purge Queue
aws sqs purge-queue --queue-url https://ap-southeast-1.queue.amazonaws.com/987654321/public-events.fifo

## Delete Queue
aws sqs delete-queue --queue-url https://ap-southeast-1.queue.amazonaws.com/987654321/public-events.fifo



