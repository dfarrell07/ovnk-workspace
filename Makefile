.PHONY: help fetch update clone-all sync lint shellcheck

.DEFAULT_GOAL := help

SHELLCHECK_ARGS := $(shell find scripts -type f -name '*.sh')
export SHELLCHECK_ARGS

help:
	@echo "OVN-Kubernetes workspace management"
	@echo ""
	@echo "Targets:"
	@echo "  make fetch       - git fetch --all --prune for every repo"
	@echo "  make update      - fetch + fast-forward pull (happy path only, warns otherwise)"
	@echo "  make clone-all   - clone any repos from repos.txt that aren't present"
	@echo "  make sync        - clone-all + regenerate .gitignore from repos.txt"
	@echo "  make lint        - run all linters"
	@echo "  make shellcheck  - lint shell scripts"

fetch:
	@./scripts/fetch.sh

update:
	@./scripts/update.sh

clone-all:
	@./scripts/clone-all.sh

sync:
	@./scripts/sync.sh

lint: shellcheck

shellcheck:
ifneq (,$(SHELLCHECK_ARGS))
	shellcheck -S warning $(SHELLCHECK_ARGS)
else
	@echo 'No shell scripts found.'
endif
