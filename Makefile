# Main Makefile

# This Makefile provides tasks to create accounts, roll out the Baseline and run security auditing tools to these
# accounts automatically. For detailed instructions on rolling out the Baseline check out docs/Rollout.md.
# To start the container including all tools run `make shell`.

# BuildKit is a faster method for building Docker images, but requires Docker 18.09 or later. Set to 0 to disable
UseBuildKit=1

# Docker-compose command
DOCKER_COMPOSE=DOCKER_BUILDKIT=$(UseBuildKit) docker-compose

# If this variable is set, run awsinfo through Docker Compose instead of directly
ifdef ComposeAwsinfo
AWSINFO=$(DOCKER_COMPOSE) run --rm awsinfo
else
AWSINFO=awsinfo
endif

# Prefix to run commands in the aws-baseline Docker Compose environment
BASELINE=$(DOCKER_COMPOSE) run --rm aws-baseline

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
	@while [ $$(aws organizations list-accounts --query "Accounts[?Name=='$(Name)'].Status" --output text) != 'ACTIVE' ]; do (echo -n '.' && sleep 2) done
	@echo "Account $(Name) with Email $(Email) created successfully"

create-account-alias:
ifndef Alias
	$(error Alias is undefined)
endif
	aws iam create-account-alias --account-alias $(Alias)

list-accounts:
	$(AWSINFO) orgs

awsinfo:
ifndef Args
	$(error Args is undefined)
endif
	$(AWSINFO) $(Args)


## Baseline Rollout

SingleRegionOption=
ifdef SingleRegion
SingleRegionOption="SingleRegion=1"
endif

# Target for single management account deployment
rollout: logging-rollout security-rollout main-rollout
	@$(MAKE) stacksets-rollout

main-rollout:
ifneq ($(thisAccount),$(MainAccount))
	$(error You must use admin credentials for account ID $(MainAccount) to roll out the main stacks and stacksets)
endif
	@cd main-account-stacks && $(MAKE) rollout Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount)

stacksets-rollout:
ifneq ($(thisAccount),$(MainAccount))
	$(error You must use admin credentials for account ID $(MainAccount) to roll out the main stacks and stacksets)
endif
ifdef StacksetDirs
	@cd stack-sets && $(MAKE) rollout Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount) $(SingleRegionOption) LIST_DIRS=$(LIST_STACKSETDIRS_CMD)
else
	@cd stack-sets && $(MAKE) rollout Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount) $(SingleRegionOption)
endif

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
	@cd stack-sets && $(MAKE) update Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount) $(SingleRegionOption) LIST_DIRS=$(LIST_STACKSETDIRS_CMD)
else
	@cd stack-sets && $(MAKE) update Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount) $(SingleRegionOption)
endif

stacksets-destroy:
ifdef StacksetDirs
	@cd stack-sets && $(MAKE) destroy Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount) $(SingleRegionOption) LIST_DIRS=$(LIST_STACKSETDIRS_CMD)
else
	$(error You must set the StacksetDirs variable to specify which stack sets you wish to destroy)
endif

stacksets-template:
ifdef StacksetDirs
	@cd stack-sets && $(MAKE) template Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount) LIST_DIRS=$(LIST_STACKSETDIRS_CMD)
else
	@cd stack-sets && $(MAKE) template Region=$(Region) MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount)
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
	$(DOCKER_COMPOSE) build --pull aws-baseline

rebuild-baseline:
	$(DOCKER_COMPOSE) build --pull --no-cache aws-baseline

shell: build
	$(BASELINE) bash

# For Windows users: run make targets and comnands through Docker Compose
# (Note that we cannot use the MAKE variable here as it points to make in the local environment not in the container)

compose-make: build
ifndef Args
	$(error Args is undefined)
endif
	$(BASELINE) make $(Args)

# Invoke this target before using ComposeAwsinfo=1
pull-awsinfo:
	$(DOCKER_COMPOSE) pull awsinfo

# Security Audit

SecurityAuditRole=AssumableSecurityAuditRole

security-audit-accounts:
ifndef Accounts
	$(error Accounts is undefined)
endif
	echo $(Accounts)
	$(DOCKER_COMPOSE) build aws-baseline
	$(BASELINE) ./scripts/security-audit -p -r $(SecurityAuditRole) $(Accounts)

clean-reports:
	rm -fr reports

security-audit-all: build clean-reports
	$(BASELINE) ./scripts/security-audit -p -r $(SecurityAuditRole)

security-audit-docker-with-rebuild: rebuild-baseline security-audit-all

# Delete Default VPC

delete-default-vpcs: build
	$(BASELINE) ./scripts/delete-default-vpc
