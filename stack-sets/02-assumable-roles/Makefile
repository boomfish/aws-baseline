# Accounts can be overridden through environment variables and calling
MainAccount=$(shell aws sts get-caller-identity --query Account --output text)
SecurityAccount=$(shell aws sts get-caller-identity --query Account --output text)
LoggingAccount=$(shell aws sts get-caller-identity --query Account --output text)
Region=us-east-1

diff:
	formica stack-set diff -c stack-set.config.yaml --region $(Region) \
		--vars MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) \
		--tags ValidateRegions=$(Region) ValidateExcludedAccounts="$(MainAccount)/$(SecurityAccount)/$(LoggingAccount)"

add-instances:
	formica stack-set add-instances -c stack-set.config.yaml --region $(Region) --yes \
	--regions $(Region) --excluded-accounts $(MainAccount) $(SecurityAccount) $(LoggingAccount)

update:
	formica stack-set update -c stack-set.config.yaml --region $(Region) --yes --regions $(Region) \
		--vars MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) \
		--tags ValidateRegions=$(Region) ValidateExcludedAccounts="$(MainAccount)/$(SecurityAccount)/$(LoggingAccount)"

create:
	formica stack-set create -c stack-set.config.yaml --region $(Region) \
		--vars MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) \
		--tags ValidateRegions=$(Region) ValidateExcludedAccounts="$(MainAccount)/$(SecurityAccount)/$(LoggingAccount)"

rollout: create add-instances

remove-instances:
	formica stack-set remove-instances -c stack-set.config.yaml --region $(Region) --yes \
	--regions $(Region) --excluded-accounts $(MainAccount) $(SecurityAccount) $(LoggingAccount)

remove-stackset:
	formica stack-set remove -c stack-set.config.yaml --region $(Region)

destroy: remove-instances remove-stackset
