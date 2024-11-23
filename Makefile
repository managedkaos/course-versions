MARKDOWN_FILES := $(shell find . -type f -name '*.md' -not -path './.git/*')

TEMP_DIR := /tmp/TMP_DIRS/$(shell date +%F)

all: lint spellcheck

stats: wordcount todos

requirements:
	@echo "### Installing requirements..."
	brew install detox rename
	docker pull ghcr.io/managedkaos/summarize-markdown-lint:main
	docker pull davidanson/markdownlint-cli2:v0.13.0

files:
	@for file in $(MARKDOWN_FILES); do \
		echo "\t$$file"; \
	done

lint:
	@echo "### Linting Markdown files..."
	@docker run --rm -v $(PWD):/workdir davidanson/markdownlint-cli2:v0.13.0 $(CONTENT_FILES) 2>&1 | \
		docker run --rm --interactive ghcr.io/managedkaos/summarize-markdown-lint:main
	@echo

rawlint:
	-@docker run --rm -v $(PWD):/workdir davidanson/markdownlint-cli2:v0.13.0 $(CONTENT_FILES) 2>&1

spellcheck:
	@echo "### Spell checking Markdown files..."
	@for file in $(MARKDOWN_FILES); do \
		aspell check --mode=markdown --lang=en $$file; \
	done
	@echo "### Spell checking prompt generation files..."
	@find . -type f -name ./80-prompts/generation\*txt -exec aspell check --mode=markdown {} \; -print
	@echo

wordcount:
	@echo "### Word count..."
	@echo "#### Content:"
	@find . -type f -name \*.md  -exec wc -w {} \; | sort -k2

todos:
	@echo "### Searching for TODOs..."
	@for file in $(MARKDOWN_FILES); do \
		grep -nH "TODO" $$file; \
	done || true
	@echo

clean:
	@echo "### Cleaning up .bak and .zip files..."
	@find . -type f -name \*.bak -exec rm -vf {} \;
	@find . -type f -name \*.zip -exec rm -vf {} \;

.PHONY: all stats requirements files lint rawlint spellcheck wordcount todos clean
