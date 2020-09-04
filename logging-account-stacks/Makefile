include ../scripts/Helpers.mk

Region=us-east-1
MainAccount=$(shell aws sts get-caller-identity --query Account --output text)
SecurityAccount=$(shell aws sts get-caller-identity --query Account --output text)
LoggingAccount=$(shell aws sts get-caller-identity --query Account --output text)

diff:
	$(call FOR_ALL_DIRS,formica diff -c stack.config.yaml --region $(Region) --vars MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount))

rollout:
	$(call FOR_ALL_DIRS,formica change -c stack.config.yaml --region $(Region) --vars MainAccount=$(MainAccount) SecurityAccount=$(SecurityAccount) LoggingAccount=$(LoggingAccount) --create-missing && formica deploy -c stack.config.yaml --region $(Region))
