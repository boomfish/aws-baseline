# Logging Account Stacks

The logging account stacks are deployed with [`formica`](https://theserverlessway.com/tools/formica/). You can either update all stacks with `make logging-rollout` or update a stack individually by going into the respective directory and run `formica change -c stack.config.yaml`. This will create a change set that you can then deploy with `formica deploy -c stack.config.yaml`.

Before deploying the stacks you should run `make diff` to get a diff on all stacks or `formica diff -c stack.config.yaml` in a stack directory to get a complete diff of the changes about to be deployed. ChangeSets and a Diff together provide a secure way of knowing what is about to change before deploying changes.

## Stack Summaries:

Following a short summary for each stack. For individual documentation on each stack please consult the `README.md` in each of the stack directories. 

* `01-auditing`: S3 Buckets and configuration to store CloudTrail, Config and FlowLogs data

## Excluding Stacks

If you want to exclude a Stack from the automated rollout add the directory name into the `Excluded` file. It has to be an exact match. Make sure to not add an empty line as it will interfere with grep. 

To check which directories are excluded run `make excluded`.