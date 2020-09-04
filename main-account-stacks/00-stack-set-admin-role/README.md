# StackSet Administration

This Stack creates the roles for CloudFormation to deploy stacksets across all accounts in the organization.

* `AWSCloudFormationStackSetAdministrationRole` in the main account is assumed by the CloudFormation service to deploy stacksets.
* `AWSCloudFormationStackSetExecutionRole` is an admin role in each member account to deploy AWS resources through the stackset admin role. The role is created for subaccounts by the `stack-set-execution-role` stackset. That stackset is deployed first through the default organization account admin role (see the `OrganizationAccountDefaultRoleName` parameter) before the other stacksets.

Note that these role names are fixed in CloudFormation and cannot be changed.
