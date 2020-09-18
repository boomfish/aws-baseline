# Main Makefile

# This Makefile provides tasks to create accounts, roll out the Baseline and run security auditing tools to these
# accounts automatically. For detailed instructions on rolling out the Baseline check out docs/Rollout.md.
# To start the container including all tools run `make shell`.

# Main AWS region for deploying stacks and stacksets; you can override this value with make arguments
Region=us-east-1

# Current account ID in effect
thisAccount:=$(shell aws sts get-caller-identity --query Account --output text)

# Default is to assume a single main management account; you can override these values with make arguments
MainAccount=$(thisAccount)
SecurityAccount=$(thisAccount)
LoggingAccount=$(thisAccount)

## Account Creation

# Run with make create-account Name=ACCOUNT_NAME Email=ACCCOUNT_EMAIL
# Will wait until the Account is in Active State
create-account:
ifndef Email
	$(error Email is undefined)
endif
ifndef Name
	$(error Name is undefined)
endif
	aws organizations create-account --email $(Email) --account-name $(Name) --iam-user-access-to-billing ALLOW
	@sleep 5
	@echo "Waiting for Account creation to finish"
	@while [[ $$(aws organizations list-accounts --query "Accounts[?Name=='$(Name)'].Status" --output text) != 'ACTIVE' ]]; do (echo -n '.' && sleep 2) done
	@echo "Account $(Name) with Email $(Email) created successfully"

create-account-alias:
ifndef Alias
	$(error Alias is undefined)
endif
	aws iam create-account-alias --account-alias $(Alias)

list-accounts:
	awsinfo orgs



## Baseline Rollout

StacksetOptions=
ifdef SingleRegion
StacksetOptions=$(StacksetOptions) SingleRegion=1
endif

# Target for single management account deployment
rollout:
	@$(MAKE) logging-rollout
	@$(MAKE) security-rollout
	@$(MAKE) main-rollout

main-rollout:
ifneq ($(thisAccount),$(MainAccount))
	$(error You must use admin credentials for account ID $(MainAccount) to roll out the main stacks and stacksets)
endif
	@cd main-account-stacks && $(MAKE) rollout Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount)
	@cd stack-sets && $(MAKE) rollout Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount) $(StacksetOptions)

security-rollout:
ifneq ($(thisAccount),$(SecurityAccount))
	$(error You must use admin credentials for account ID $(SecurityAccount) to roll out the security stacks)
endif
	@cd security-account-stacks && $(MAKE) rollout Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount)

logging-rollout:
ifneq ($(thisAccount),$(LoggingAccount))
	$(error You must use admin credentials for account ID $(LoggingAccount) to roll out the logging stacks)
endif
	@cd logging-account-stacks && $(MAKE) rollout Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount)

diff:	logging-diff security-diff main-diff

main-diff:
	@cd main-account-stacks && $(MAKE) diff Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount)
	@cd stack-sets && $(MAKE) diff Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount)

security-diff:
	@cd security-account-stacks && $(MAKE) diff Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount)

logging-diff:
	@cd logging-account-stacks && $(MAKE) diff Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount)

LIST_STACKSETDIRS_CMD="echo $(StacksetDirs) | tr ' ' '\n'"

stacksets-update:
ifdef StacksetDirs
	@cd stack-sets && $(MAKE) update Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount) $(StacksetOptions) LIST_DIRS=$(LIST_STACKSETDIRS_CMD)
else
	@cd stack-sets && $(MAKE) update Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount) $(StacksetOptions)
endif

stacksets-destroy:
ifdef StacksetDirs
	@cd stack-sets && $(MAKE) destroy Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount) $(StacksetOptions) LIST_DIRS=$(LIST_STACKSETDIRS_CMD)
else
	$(error You must set the StacksetDirs variable to specify which stack sets you wish to destroy)
endif

excluded:
	@cd main-account-stacks && $(MAKE) excluded -i
	@cd security-account-stacks && $(MAKE) excluded -i
	@cd logging-account-stacks && $(MAKE) excluded -i
	@cd stack-sets && $(MAKE) excluded -i

list-stack-sets:
	@cd stack-sets && $(MAKE) stack-sets

stack-set-instances:
	@cd stack-sets && $(MAKE) stack-set-instances

## Development Tooling

test-python:
	py.test --cov-branch --cov-report html --cov-report term-missing ./

build:
	touch .bash_history
	docker-compose build --pull aws-baseline

rebuild-baseline:
	docker-compose build --pull --no-cache aws-baseline

shell: build

	docker-compose run aws-baseline bash



# Security Audit

SecurityAuditRole=AssumableSecurityAuditRole

security-audit-accounts:
ifndef Accounts
	$(error Accounts is undefined)
endif
	echo $(Accounts)
	docker-compose build aws-baseline
	docker-compose run aws-baseline ./scripts/security-audit -p -r $(SecurityAuditRole) $(Accounts)

clean-reports:
	rm -fr reports

security-audit-all: build clean-reports
	docker-compose run aws-baseline ./scripts/security-audit -p -r $(SecurityAuditRole)

security-audit-docker-with-rebuild: rebuild-baseline security-audit-all

# Delete Default VPC

delete-default-vpcs: build
	docker-compose run aws-baseline ./scripts/delete-default-vpc
