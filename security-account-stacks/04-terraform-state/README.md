# Terraform

This CloudFormation stack creates resources for storing and accesing the shared state of Terraform projects in AWS.

It creates an S3 bucket for remote state storage, a DynamoDB table for remote state locking, and groups for access control.

# Adding custom IAM groups for Terraform workspaces

You can add your own IAM groups to limit users to specific workspaces by key prefix. To do this, copy an existing group and change the key part at the end of the resource name for the state policy (called `TerraformReadState` for ReadOnly groups and `TerraformReadWriteState` for ReadWrite groups).

