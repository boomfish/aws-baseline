# Stack Set Organization Security Audit Role

For split account management setups with a separate security account, we need different roles for running security audits from the main account or from the security account.

The `AssumableSecurityAuditRole` set up in the `assumable-roles` stack set is for security audits run from the security account. It allows fine-grained control over which sub-accounts a user can audit.

The `OrganizationSecurityAuditRole` set up here is for security audits run from the main account. The `SecurityAudit` group there grants permissions for assuming the role in all sub-accounts, and combined with the `ListAccounts` group a user can scan and audit all sub-accounts ensuring none are missed.

To run a security audit across all accounts using this role you must specify the role name when running the make target, as follows:

```bash
make security-audit-all SecurityAuditRole=OrganizationSecurityAuditRole
```

This stack set is excluded by default as the role is redundant when all management is being done through the main account. To include it, remove the directory name from the `Excluded` file.