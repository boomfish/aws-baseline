# Rolling Out the AWS Baseline

Rolling out the Baseline into AWS can be done fully automated through the `make rollout` command. Before running the Rollout there are a few things to consider.

## Storing your customisations

It is highly recommended that you fork this repository and commit all chagnes you're doing to the infrastructure to your own repository. This will make sure that you can redeploy your infrastructure easily anytime and selectively update the Baseline from upstream.

## Single Main Account or Split Management Accounts

When deciding on your Account Setup one thing to consider is if you want to have a single Main Account managing all others or if you want to split up your Accounts into separate Logging, Security or other Management Accounts.

The advantage of a single Main Account is that it makes the whole infrastructure easier to understand and use. All configuration and deployment metadata is stored in one account, so tight security over that one Account is easier to implement and understand for most teams. As the Main Account in the Org is also the only one that can access the list of Sub Accounts it's easier to automate various deployments as AccountIDs don't have to be hardcoded.

The downsides in this approach are the limits in scale this provides as any sufficiently large organization with dozens of accounts will potentially run into issues with one main account. Different teams will want to be able to have more control over their Accounts, e.g. the Security team might want to be able to have more control over a dedicated Security Account which is organizationally harder to do with one Main Account. Service Control Policies also don't work in the Main Account of an Organization so limiting access thoroughly is harder to achieve.

For most organizations, especially those that only need a handful of accounts going with one central Account should be the best option as it limits complexity and needs no customization in this baseline. For companies that require (or already have) a more complex setup having multiple accounts dealing with the Baseline might be a good option.

In the end because the whole setup is fully automated switching from one mode to another can always be done, although with a varying amount of effort.

## Configuration to change when setting up multiple Management Accounts

The management account configuration stacks have been divided into 3 folders:

- main-account-stacks
- logging-account-stacks
- security-account-stacks

The default setup is to roll out the stacks in all 3 folders to the account of the currently active credentials. However you may roll out the logging and/or security stacks into different accounts. The recommended way of doing this is to set the following variables in the top-level Makefile to their corresponding account numbers:

- MainAccount
- LoggingAccount
- SecurityAccount

The MainAccount variable *must* be set to the AWS organization main account. LoggingAccount and SecurityAccount may be set to any AWS account; they may be members of the AWS organization but they need not be.

These variables are passed down to other Makefiles when they are called from the top-level Makefile. As long as you run all your make targets from the top-level Makefile there is no need to set these variables in the other Makefiles.

The security account stack requires a list of subaccounts to set up IAM groups. When the security account is the organization main account, the stack uses the organization API to get this list, but if you are using a different account then you need to provide the list explicitly. See the [security-account-stacks README](../../security-account-stacks/README.md) for details.

## Configuring the Regions

The top-level Makefile has a `Region` variable that specifies the target region for all management account stacks and stacksets. The default value is `us-east-1` but may be changed before the initial rollout. Do not change this after rollout as it will result in an inconsistent configuration.

## Excluding Stacks or StackSets

If you want to exclude a Stack or StackSet from the automated rollout add the directory name into the `Excluded` file in the `main-account-stacks` or `stack-sets` directories. It has to be an exact match. Make sure to not add an empty line as it will interfere with grep. 

To check which directories are excluded run `make excluded` either in the main directory or the `main-account-stacks` or `stack-sets` directories.

By default the `Excluded` file in the `stack-sets` folder lists `02a-org-security-audit-role`. You should remove or comment out this entry only if your security account is not the organization main account.

## Required Tools

When using the toolbox all required tools are already installed. In case you do not want to or can't use the Docker container you need to install Formica with `pip install formica-cli` and make sure you have `make` installed on your System.

Rolling out from Microsoft Windows requires Docker Desktop and GNU Make, and uses modified versions of the rollout commands. See [Running aws-baseline from Microsoft Windows](./MS-Windows.md) for details.

## Rolling out the Baseline with a Single Management Account

Now finally after we've made all the adjustments we need we can roll out the Baseline. Make sure you have local credentials that have Admin Access into your Main Account. If you're in the Toolbox Docker Container (start it with `make shell`) or have [`awsinfo`](https://theserverlessway.com/tools/awsinfo/) installed you can run `awsinfo me` and `awsinfo credentials` to see which User you're logged into and what the currently used credentials and region are.

After that run `make rollout` in the root folder of the repository. That task will first switch into each management account stacks folder and run `make rollout` in each to deploy all management account stacks. After that it will switch into the `stack-sets` folder and deploy the StackSets. In case any issues come up during the deployment you can rerun `make rollout` again as it will update existing stacks in case they already exist.

## Rolling out the Baseline with Multiple Management Accounts

If you are using multiple management accounts, you must roll out the stacks for each account separately. When rolling out the account stacks be sure to use the admin credentials for the corresponding account. If you have set the account variables, the rollout targets will check that the account for the active credentials corresponds to the stacks being rolled out and stop with an error if they do not match.

Begin by activating the logging account admin credentials and running `make logging-rollout` to deploy the logging account stacks. Next, activate the security account admin credentials and run `make security-rollout` to deploy the security account stacks. Following that, activate the main account admin credentials and run `make main-rollout` to deploy the main account stacks. Finally, with the main account credentials still active, run `make stacksets-rollout` to deploy the StackSets.

## Rolling out the StackSets to a single Region

Some of the StackSets deploy stack instances to many regions by default. This can be a very slow process. If you are editing or troubleshooting these StackSets it is recommended to first test the StackSets by limiting their deployment to the main region only. This can be done by running `make stacksets-rollout SingleRegion=1`.

After the test rollout is successful, perform the full stacksets rollout by running `make stacksets-rollout`.

Note that rolling out a stackset to a single region does not change the stackset validation tags. If you do not perform a full stackset rollout by the next evaluation of the stacksets validation custom Config Rule, the stackset will be flagged as non-compliant.

## Adding new Accounts

After rolling out the Baseline for the first time you might want to add Accounts in the future. Before creating these Accounts make sure you use the same Role name you used for all other Accounts (or leave it at the default `OrganizationAccountAccessRole`).

After the account is created run `make diff` first in the root of the repository to see all changes that will be done. Then run `make rollout` so the Baseline will go through the `main-account-stacks` and `stack-sets` folders and roll out all the Stacks and StackSets. You can run `make diff` or `make rollout` in the `main-account-stacks` and `stack-sets` subfolders as well to deploy them independently.

## Updating the Baseline and Debugging issues

Whenever you want to update the baseline either by customising it or adding features from the upstream repository run `make rollout` again after updating repository.

In case there are ever errors when rolling out the Baseline open an issue (in case it's a bug) and look into [`Formica`](https://theserverlessway.com/tools/formica/) the underlying tool deploying all Stacks and StackSets of the Baseline.