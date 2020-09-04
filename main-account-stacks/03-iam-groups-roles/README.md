# Main Account Groups and Roles

This CloudFormation stack creates groups and roles for managing access to management functions in the main account.

## Billing Access

The group `BillingReadAccess` provides access to view the Billing console and Cost Explorer. For split management setups a role `AssumableBillingViewRole` is also created to access billing from the security account.

## Split-Management Groups

For setups where the security account is separate from the main account, this stack defines the following groups to manage the master account:

- `OrganizationAdminGroup` grants full permissions to the organisation similar to the built-in `AdministratorAccess` policy except for requiring MFA.
- `SecurityAudit` grants permissions required to run Prowler scans on the main account and any subaccounts through the `OrganizationSecurityAuditRole`.
- `ListAccounts` grants permissions to list the subaccounts in the organisation.
- `UserCredentialsManagement` is similar to the group of the same name in the security account stacks, and is required for IAM users to login and use the permissions provided by the other groups.
