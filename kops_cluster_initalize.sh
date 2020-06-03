#!/bin/bash

set -e

# EDIT THIS:
#------------------------------------------------------------------------------#
NUM_MASTER_NODES=1
NUM_NODES=2
STACK_NAME=kops-cluster-stack
CLUSTER_NAME=kops.cluster.kubernetes-aws.io
BUCKET_NAME=bucket.cluster.kubernetes-aws.io
MASTER_INSTANCE_TYPE=t2.medium
NODES_INSTANCE_TYPE=t2.medium
REGION=us-east-1e,us-east-1b,us-east-1d,us-east-1a
HOSTED_ZONE=cluster.kubernetes-aws.io
MASTER_NODE_REGION=us-east-1a
NODES_REGION=us-east-1b
CLOUD=aws
#------------------------------------------------------------------------------#

# Output colours
COL='\033[1;34m'
NOC='\033[0m'

echo -e  "$COL> Deploying CloudFormation stack to create Route53 private Hosted Zone and S3Bucket (may take up to 15 minutes)...$NOC"
aws cloudformation deploy \
 "$@" \
 --template-file kops-cluster.yml \
 --stack-name "$STACK_NAME" \
 --parameter-overrides \
    BucketName="$BUCKET_NAME" \
    HostedZone="$HOSTED_ZONE"

echo -e "\n$COL> Exporting the state of cluster to s3bucket...$NOC"
export KOPS_STATE_STORE=s3://"$BUCKET_NAME"

echo -e "\n$COL> Generating public SSH key..$NOC"
ssh-keygen -t rsa -f ~/.ssh/id_rsa <<< y

echo -e "\n$COL> Kops cluster creation started(it may take 5-10 minutes)...!!$NOC"

kops create cluster \
 "$@" \
 --cloud="$CLOUD" \
 --zones="$REGION" \
 --name="$CLUSTER_NAME" \
 --dns-zone="$HOSTED_ZONE" \
 --dns private \
 --master-size="$MASTER_INSTANCE_TYPE" \
 --node-size="$NODES_INSTANCE_TYPE" \
 --node-count="$NUM_NODES" \
 --state=s3://"$BUCKET_NAME" \
 --yes 

echo -e "\n$COL> Almost done! Cluster will be ready when all nodes have a 'Ready' status."
echo -e "> Check it with: kubectl get nodes --watch$NOC"
