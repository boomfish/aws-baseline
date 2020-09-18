# AWS Account Baseline

This repository contains configuration to roll out your AWS Baseline (also known as a Landing Zone). The result will be a flexible setup to give you a basis to build your specific infrastructure on. 

The Baseline is implemented through a mix of CloudFormation Stacks and StackSets with individual parts being optional so you can decide the setup of your infrastructure.

Following is a selection of features implemented in this Baseline

* Various Roles and Access Management through Groups for all Subaccounts
* Auditing with CloudTrail, GuardDuty and Config
* Security Review with [Prowler](https://github.com/toniblyx/prowler) and [ScoutSuite](https://github.com/nccgroup/ScoutSuite) 
* Service Control Policies to prevent access to auditing resources
* Flexible VPC Configuration
* AWS Athena Setup to quickly search through FlowLogs and CloudTrail across accounts
* Budgets so you don't get any expensive surprises at the end of the month
* and more ...

## Customisations and Consulting

For any custom features or help with rolling out the Baseline in your Account please send an email to [consulting@theserverlessway.com](mailto:consulting@theserverlessway.com) and check out the [Consulting Page](https://theserverlessway.com/consulting/).

For more information on tools and guides for AWS and Serverless Infrastructure take a look at [The Serverless Way](https://theserverlessway.com/).

## Comparison to AWS Control Tower and Landing Zone

With the launch of Control Tower (and previously Landing Zone) AWS has their own Multi Account Organization Setup in place. Control Tower is a great service for new infrastructure, but at the time of this writing not available for existing Organizations. One further issue with Control Tower is its limited flexibility in how to set up accounts and roll out further customizations. In the future this should be resolved by more customisation options in Control Tower, but isn't yet implemented or released.  

The plan for this Baseline is in the future to be compatible with Control Tower and provide features on top of it when that makes sense and is possible. 

## General Baseline Info

There are 3 folders containing ClouldFormation Stacks for management accounts:

* main-account-stacks (CloudWatch StackSet roles, Config aggregator, budget policy, Organization controls)
* logging-account-stacks (CloudTrail and FlowLog aggregation and analysis)
* security-account-stacks (IAM groups for cross-account role assumption)

These folders should deployed first but may be deployed in any order. In a standard setup they are all deployed to your main account. In a multi management account setup, the logging and security account stacks may be deployed into separate accounts.

The `stack-sets` folder contains StackSets that should be created in your main account and then deployed
into your member accounts. For more information on the StackSets check out the README in the `stack-sets` folder.

Various stacks are based on or derived from the wonderful [Widdix Templates](http://templates.cloudonaut.io/en/stable/). Check them out they do an amazing job!

## AWS Baseline Toolbox

As the AWS Baseline needs a few different tools and dependencies to be set up the easiest way to get started is the toolbox that comes built-in. With `make shell` you can start a Docker Container that includes all necessary tools. It forwards all AWS Environment Variables you've set and make the `~/.aws` folder accessible in the toolbox. This means you can use all your AWS credentials the same way as outside of the container.

Through this Toolbox you should have a much easier time to get started with rolling out the toolbox, so check it out.

## Rolling out the Baseline

Rolling out and updating the Baseline can in essence be done by running `make rollout`. Before you do this make sure to read the whole [`Rolling Out the AWS Baseline`](docs/Rollout.md) Documentation to set all necessary config values correctly.

After the rollout of the baseline you need your local credentials to be MFA secured for interacting with the AWS API. Use the `assume-token` script in the `scripts` subfolder to get those mfa secured credentials. Typically you would run something like `./scripts/assume-token -m -d 8 -p my-profile` to get MFA signed credentials lasting for 8 hours for the profile `my-profile`. The tool needs JQ to be installed on your System. 

Following are all options of the script:

* -p: For setting the AWS Profile to use
* -m: For using an MFA device and asking for the token
* -d: For setting the expiration of the token
* -t: For directly setting the MFA token code (will be asked for if not set)
* -s: For setting the MFA device serial number directly 


### Auditing and Security

The Stacks and StackSets deployed to both the main and sub accounts set up a best practice auditing and security solution. That includes CloudTrail, Config and GuardDuty across all accounts and regions. For easy auditing of the current status of your accounts it also includes various AWS Security auditing tools that can be run with just one `make` command.

For all the details check out the [Auditing Documentation](docs/Auditing.md) and the [Security Documentation](docs/Security.md).

Make sure to familiarize yourself with the specific services so you have a good understanding of the auditing setup and understand how to detect issues in your Organization.

## User and Access Management

In the security account we're creating several `assume-role` groups which allow users to assume roles in sub-accounts. They are created automatically for any account found in the current organization. When you add new accounts you have to redeploy the stack so it picks up the new accounts and creates groups accordingly. For more information on assuming roles in another account check out the [Assume Role Documentation](docs/Assume.md)

The stacks in the security account also create various groups for User Management. This allows you to add new users to groups to for example create new users or manage group membership. For more information on User Management check out the [User Management Documentation](docs/UserManagement.md)

For more detail on each stack that gets deployed to the management accounts, check out the READMEs:

* [main-account-stacks README](./main-account-stacks/README.md)
* [logging-account-stacks README](./logging-account-stacks/README.md)
* [security-account-stacks README](./security-account-stacks/README.md)

## Tooling

The Baseline comes with its own Docker based toolbox that you can start with `make shell`. It includes different tools to manage the baseline as well as interacting with the AWS APIs. Check out the files in the toolbox Folder to see all the tools that are installed.

The only required tool to roll out your infrastructure is [`Formica`](https://theserverlessway.com/tools/formica/). If you do not want to or can't use the Docker based toolbox you need to install this tool.


## Deleting default VPCs

Deleting all default VPCs from your account should be one of the first steps you take. The make task `delete-default-vpcs` will remove them across all regions with the currently exported credentials. So either set the credentials or the profile through [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html) and start the command. It will run inside of the baseline docker container so you don't need any tools installed on your system.

## License

The AWS Baseline is published under the Apache License Version 2.0.

## Contributing
If you want to Contribute features, propose changes or report bugs please open an issue and fill out the issue template. The more context the better. Make sure that before you implement a specific enhancement to create an issue to discuss it first so we can get on the same page before any time is spent on implementing it. Thanks for helping out!