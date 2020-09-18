# User and Group Management

This CloudFormation stack creates Groups for managing access to management functions in the main account and access through AssumeRole in the subaccounts.

By default the template will iterate over all Accounts and for every type of Role configured and every Account it will create a separate IAM group that can be used to manage access to that role in that specific account.

This makes changing users access rights quickly easy so in cases of issues user can be given access to production resources quickly, without them need constant access during times without issues. A good practice is to get ReadOnly acces for general use and only escalate to Developer or Admin access once a situation arises that requires these rights.

# Providing an explicit Account List

If you are not using the main account for the security account stacks, the template will not be able to generate the account list itself. Instead you must disable the `organization-variables` setting and provide the account list in the `AWSSubAccounts` variable as in this example

```yaml
organization-variables: false
vars:
  AWSSubAccounts:
    - Name: SubAccount1
      Id: 123456789012
    - Name: SubAccount2
      Id: 234567890123
```

## MFA limitations

