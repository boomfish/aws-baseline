# Auditing Account Access

This stack sets up an `AuditBucketsReadAccessPolicy` IAM policy for reading the S3 buckets used for audit logs. If the security account is different from the logging account, it also sets up an `AssumableAuditRole` IAM role for users in the security account to read the audit logs.
