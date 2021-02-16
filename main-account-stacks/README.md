# Main Account Stacks

The main account stacks are deployed with [`formica`](https://theserverlessway.com/tools/formica/). You can either update all stacks with `make main-rollout` or update a stack individually by going into the respective directory and run `formica change -c stack.config.yaml`. This will create a change set that you can then deploy with `formica deploy -c stack.config.yaml`.

Before deploying the stacks you should run `make diff` to get a diff on all stacks or `formica diff -c stack.config.yaml` in a stack directory to get a complete diff of the changes about to be deployed. ChangeSets and a Diff together provide a secure way of knowing what is about to change before deploying changes.

## Stack Summaries:

Following a short summary for each stack. For individual documentation on each stack please consult the `README.md` in each of the stack directories. 

* `00-stack-set-admin-role`: Roles to allow CloudFormation to deploy stacks to subaccounts. [00-stack-set-admin-role README](./00-stack-set-admin-role/README.md)
* `01-config`: AWS Config aggregator for the organization. [01-config README](./01-config/README.md)
* `02-budget`: Account Budget with MaxBudget set and alerts sent to Account Email by default. [02-budget README](./02-budget/README.md)
* `03-iam-groups-roles`: IAM groups and roles to manage access to the main account.[03-iam-groups-roles README](./03-iam-groups-roles/README.md)
* `04-service-control-policies`: Service Control Policies deployed as a StackSet. [04-service-control-policies README](./04-service-control-policies/README.md)
* `05-validate-stack-set-deployments`: Validates deployed StackSet instances against the tags set on the StackSets. Records AWS Config Evaluations to see missing StackSet Instances. [05-validate-stack-set-deployments README](./05-validate-stack-set-deployments/README.md)
* `06-sso-permission`: SSO permission sets that provide an alternative to IAM roles for accessing subaccounts. These are only applicable if SSO is being used. Excluded by default. [04-service-control-policies README](./06-sso-permissions/README.md)

## Excluding Stacks

If you want to exclude a Stack from the automated rollout add the directory name into the `Excluded` file. It has to be an exact match. Make sure to not add an empty line as it will interfere with grep. 

To check which directories are excluded run `make excluded`.