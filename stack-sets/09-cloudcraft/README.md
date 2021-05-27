# Cloudcraft

StackSet to create a role in each accounts in the organisation that Cloudcraft can use to scan for resources to visualise.

Cloudcraft provides free accounts for drawing AWS diagrams, however AWS live sync is a feature only available with a paid subscription.

## Variables

This stackset requires 2 variables. You can find the correct values for them by selecting "Add AWS Account" from your Cloudcraft account.

`CloudcraftAccount`: This is the ID of Cloudcraft's AWS account.

`CloudcraftExternalId`: This is the External ID that Cloudcraft assigns to your subscription. This is required to ensure that other Cloudcraft customers cannot browse your AWS accounts.
