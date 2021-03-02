ACCOUNT_ID=$(shell aws sts get-caller-identity --output text --query Account)

# Accounts can be overridden through environment variables and calling
MainAccount=$(shell aws sts get-caller-identity --query Account --output text)
SecurityAccount=$(shell aws sts get-caller-identity --query Account --output text)
Region=us-east-1

ifdef SingleRegion
InstanceRegions=--regions $(Region)
else
#InstanceRegions--all-regions
InstanceRegions=--excluded-regions ap-northeast-3
endif

diff:
	formica stack-set diff -c stack-set.config.yaml --region $(Region) \
		--vars MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount)

add-instances:
	formica stack-set add-instances -c stack-set.config.yaml --region $(Region) --yes $(InstanceRegions)

update:
	formica stack-set update -c stack-set.config.yaml --region $(Region) --yes $(InstanceRegions) \
		--vars MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount)

create:
	formica stack-set create -c stack-set.config.yaml --region $(Region) \
		--vars MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount)

rollout: create add-instances

remove-instances:
	formica stack-set remove-instances -c stack-set.config.yaml --region $(Region) --yes $(InstanceRegions)
remove-stackset:
	formica stack-set remove -c stack-set.config.yaml --region $(Region)

destroy: remove-instances remove-stackset

accounts-config:
	aws organizations list-accounts --output json --query "Accounts[?Id!='$(ACCOUNT_ID)'].{Id: Id, Email: Email}" | jq '{"vars": {"Accounts": .}}' > accounts.config.json
