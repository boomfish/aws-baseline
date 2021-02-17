# Single Sign-On Permissions

This stack sets up some SSO Permission Sets that correspond to some of the IAM groups set up by the baseline.

## Requirements

This stack requires an SSO instance in the main account. The ARN of the instance must be specified in the `SSOInstanceArn` parameter.

## Permission Sets

The stack creates the following permission sets:

- `AdminAccess`: Equivalent to the `AssumableAdminRole` IAM role in subaccounts

- `DeveloperAccess`: Equivalent to the `AssumableDeveloperRole` IAM role in subaccounts

- `BillingReadAccess`: Equivalent to the `BillingReadAccess` IAM group in the main account

- `LoggingReadAccess`: Equivalent to the `LoggingReadAccess` IAM group in the logging account

- `SecurityAuditAccess`: Equivalent to the `AssumableSecurityAudit` IAM role in subaccounts

- `OperationsAccess`: Equivalent to the `AssumableOperationsRole` IAM role in subaccounts

The maximum duration of `AdminAccess` sessions is controlled by the `AdminSessionDuration` parameter (1 hour by default). The maximum duration of sessions from the other permission sets is controlled by the `SessionDuration` parameter (8 hours by default).

## Region Restrictions

The `DeveloperAccess` permission set can be restricted to specific regions by setting the `AllowedRegions` variable. The value is a comma-separated list of region names. If it is not set, the permission set is not restricted by region.

## Limitations of SSO Permission Sets

There are some limitations of SSO permission sets compared with IAM group and role policies:

- SSO MFA is different to IAM MFA, and SSO MFA sessions do not pass MFA conditions in IAM policy statements. Currently there are no IAM policy statement conditions for checking SSO MFA.

- SSO permission sets do not support IAM permission boundaries.

- SSO Permission sets are created at the organization level and permission set policy statements cannot use variables such as `${AWS::AccountId}`. If slightly different permissions are required for specific accounts, a separate SSO permission set is required.
