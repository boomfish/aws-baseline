include ../scripts/Helpers.mk

LIST_STACK_SETS_COMMAND=@aws cloudformation list-stack-sets --status ACTIVE --query "Summaries[].StackSetName" --output text

TAG_VALUE=Tags[?Key=='$(1)'].Value|[0]||''

MainAccount=$(shell aws sts get-caller-identity --query Account --output text)
SecurityAccount=$(shell aws sts get-caller-identity --query Account --output text)
LoggingAccount=$(shell aws sts get-caller-identity --query Account --output text)
Region=us-east-1

ifdef SingleRegion
SingleRegionOption=SingleRegion=1
endif
StacksetOptions=Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount) $(SingleRegionOption)

stack-sets:
	$(LIST_STACK_SETS_COMMAND) | (xargs -n 1 -P 15 aws cloudformation describe-stack-set --query "StackSet.{\"1.Name\":StackSetName, \"2.Tags\":join(', ', Tags[].join('=', [Key,Value]))}" --stack-set-name) | jq -s -c 'sort_by(."1.Name")' | python3 ../scripts/json_table.py StackSets

stack-set-instances:
	$(LIST_STACK_SETS_COMMAND) | (xargs -n 1 -P 15 aws cloudformation list-stack-instances --query "Summaries.{\"1.ID\":[0].StackSetId,\"2.Current\":[?Status=='CURRENT'] | length(@), \"3.Other\":[?Status!='CURRENT'] | length(@)}" --stack-set-name) | sed 's/:[a-z0-9][a-z0-9-]*//g' | jq -s -c 'sort_by(."1.ID")' | python3 ../scripts/json_table.py StackSetInstances

diff:
	$(call FOR_ALL_DIRS,$(MAKE) diff $(StacksetOptions))

add-instances:
	@echo ----------- Adding Missing StackSet Instances -----------
	$(call FOR_ALL_DIRS,$(MAKE) add-instances $(StacksetOptions))

create:
	@echo ----------- Creating Stack Sets -----------
	$(call FOR_ALL_DIRS,$(MAKE) create $(StacksetOptions))

update:
	@echo ----------- Updating Stack Sets -----------
	$(call FOR_ALL_DIRS,$(MAKE) update $(StacksetOptions))

remove-instances:
	@echo ----------- Removing StackSet Instances -----------
	$(call FOR_ALL_DIRS,$(MAKE) remove-instances $(StacksetOptions))

remove-stacksets:
	@echo ----------- Removing Stack Sets -----------
	$(call FOR_ALL_DIRS,$(MAKE) remove-stackset $(StacksetOptions))

rollout: create add-instances

destroy: remove-instances remove-stacksets